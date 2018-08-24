$missing_value = :'?'

class AbstractAttribute
  attr_reader :attr_name, :values
  def initialize(attr_name)
    @attr_name, @values = attr_name, ['abstract']
  end
  def to_n(v)
    return nil if v.to_sym == $missing_value
    v
  end
  def to_s(n)
    return $missing_value.to_s if n == nil
    n
  end
  def hash
    @attr_name.hash
  end
  def eql?(o)
    return nil unless o.kind_of?(AbstractAttribute)
    @attr_name == o.attr_name
  end
  def ==(o)
    return nil unless o.kind_of?(AbstractAttribute)
    @attr_name == o.attr_name
  end
  def <=>(o)
    return nil unless o.kind_of?(AbstractAttribute)
    @attr_name <=> o.attr_name
  end  
end

class RealAttribute < AbstractAttribute
  def initialize(attr_name)
    @attr_name, @values = attr_name, ['real']
  end
  def to_n(v)
    return nil if v.to_sym == $missing_value
    v.to_f
  end
  def to_s(n)
    return $missing_value.to_s if n == nil
    n.to_s
  end
  def dist(v1,v2)
    return nil if v1.to_sym == $missing_value || v2.to_sym == $missing_value
    return (v1.to_f-v2.to_f).abs
  end
end

class IntegerAttribute < AbstractAttribute
  def initialize(attr_name)
    @attr_name, @values = attr_name, ['integer']
  end
  def to_n(v)
    return nil if v.to_sym == $missing_value
    v.to_i
  end
  def to_s(n)
    return $missing_value.to_s if n == nil
    n.to_s
  end
  def dist(v1,v2)
    return nil if v1.to_sym == $missing_value || v2.to_sym == $missing_value
    return (v1.to_i-v2.to_i).abs
  end
end

class StringAttribute < AbstractAttribute
  def initialize(attr_name)
    @attr_name, @values = attr_name, ['string']
  end
  def to_n(v)
    return nil if v.to_sym == $missing_value
    v.to_sym
  end
  def to_s(n)
    return $missing_value.to_s if n == nil
    n.to_s
  end
  def dist(v1,v2)
    return nil if v1.to_sym == $missing_value || v2.to_sym == $missing_value
    return (v1.to_s == v2.to_s ? 0 : 1)
  end
end

class DiscreteAttribute < AbstractAttribute
  def initialize(attr_name,values)
    @attr_name, @values = attr_name, values
  end
  def to_n(v)
    return nil if v.to_sym == $missing_value
    (0...@values.size).find{|i| values[i] == v.to_sym}
  end
  def to_s(n)
    return $missing_value.to_s if n == nil
    values[n].to_s
  end
  def dist(v1,v2)
    return nil if v1.to_sym == $missing_value || v2.to_sym == $missing_value
    return (v1.to_s == v2.to_s ? 0 : 1)
  end
end

def read_attr(file_name)
  file = File.open(file_name)

  attributes = []
  file.each{|l|
    l.strip!
    if l == '' then next end
    items = l.split(':').map{|s| s.strip}
    if items[1] == nil then p 'error in attr file: ' + l; exit(1) end
    if items[1] == 'real'
      a = RealAttribute.new(items[0].to_sym)
    elsif items[1] == 'integer'
      a = IntegerAttribute.new(items[0].to_sym)
    elsif items[1] == 'string'
      a = StringAttribute.new(items[0].to_sym)
    else
      values = items[1].split(/\s+/).map{|s| s.to_sym}
      a = DiscreteAttribute.new(items[0].to_sym,values)
    end
    attributes << a
  }

  return attributes
end

def read_data(file_name)
  file = File.open(file_name)

  header = []
  file.each{|l|
    l.strip!
    if l != '' 
      header = l.split(/\s+/).map{|s| s.to_sym}
      break
    end
  }

  if file.eof? then p 'error in the data file: EOF.'; exit(1) end

  objects = []
  file.each{|l|
    l.strip!
    if l == '' then next end
      items = l.split(/\s+/)
      if items.size == header.size
        objects << items
      else
        p 'error in the data file: row.size != header.size: ' + l; exit(1)
      end
  }
  file.close

  if objects.size == 0 then p 'error in the data file: no objects.'; exit(1) end

  return header,objects
end

def to_h_attributes(attributes,header)
  h_attributes = header.map{|h| attributes.find{|a| a.attr_name == h}}
  if h_attributes.include?(nil) then p 'there are unknown attributes in data.' + "\n"; exit(1) end
  return h_attributes
end

def to_numeric(h_attributes,objects)
  return objects.map{|o| (0...o.size).map{|i| [h_attributes[i],h_attributes[i].to_n(o[i])]}.to_h}
end

def to_proximity(h_attributes,objects,ignore_attr)
  matrix = []
  m = objects.size
  l = h_attributes.size

  ranges = (0...l).map{|k| 
    if h_attributes[k].instance_of?(RealAttribute) || h_attributes[k].instance_of?(IntegerAttribute) 
      vals = objects.map{|o| h_attributes[k].to_n(o[k])}.sort
      [vals[0],vals[-1]]
    else
      [0,1]
    end
  }

  h_attr_ind = (0...l).reject{|k| ignore_attr.map{|a| a.to_sym}.include?(h_attributes[k].attr_name)}

  (0...m).each{|i|
    r = []
    (i+1...m).each{|j|
      r[j] = h_attr_ind.map{|k| 
        v = h_attributes[k].dist(objects[i][k],objects[j][k])
        v/(ranges[k][1]-ranges[k][0])
      }.inject(:+).to_f / h_attr_ind.size.to_f
    }
    matrix[i] = r
  }

  (0...m).each{|i|
    (0...i).each{|j| matrix[i][j] = matrix[j][i]}
    matrix[i][i] = 0
  }

  return matrix
end