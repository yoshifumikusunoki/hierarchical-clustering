require_relative './clustering_common'
require_relative './linkage'
require 'optparse'

attr_file = 'a.attr'
data_file = 'a.data'
ignore_attr = []
linkage = method('single_linkage')
seed = 0

opt = OptionParser.new
opt.on('-a ATTRIBUTE_FILE',String){|v| attr_file = v}
opt.on('-i INPUT_FILE',String){|v| data_file = v}
opt.on('-g IGNORE_ATTRIBUTES',Array){|v| ignore_attr = v}
opt.on('-l LINKAGE',String){|v| linkage = method(v)}
opt.on('-s SEED',Integer){|v| seed = v}

opt.parse!(ARGV)

print 'induce clustering from ', data_file, " by ", linkage.name.to_s, " without ", ignore_attr, ".\n\n"

# read attr
attributes = read_attr(attr_file)

# read data
header,pre_objects = read_data(data_file)

# covert numerical table
h_attributes = to_h_attributes(attributes,header)
start = Time.now
proximity = to_proximity(h_attributes,pre_objects,ignore_attr)
print 'to_proximity: time ', (Time.now - start).to_s, "\n"

m = proximity[0].size

f = 'clustering_results/'; if !File.directory?(f) then Dir.mkdir(f); end
f = f + File.basename(data_file,".*") + '_' + linkage.name.to_s + '/'; if !File.directory?(f) then Dir.mkdir(f); end
base = f
f = f + ('%d') % seed + '/'; if !File.directory?(f) then Dir.mkdir(f); end
base_clst = f

output = File.open(base + 'proximity', 'w')
proximity.each{|x| 
  output.print x[0]; (1...x.size).each{|i| output.print ',',x[i]}; output.print "\n"
}
output.close

clusters = (0...m).map{|i| [i]}

coph_matrix = (0...m).map{|i| (0...m).map{|j| 0.0}}

prev_prox = 0

digits = Math.log10(clusters.size).to_i + 1

while(clusters.size > 1) do

  p clusters.size

  output = File.open(base_clst + ('%0' + digits.to_s + 'd') % clusters.size, 'w')

  start = Time.now
  output.puts start

  output.print 'all_clusters'
  clusters.each{|c| output.print ' / '; output.print c[0]+1; (1...c.size).each{|i| output.print ',',c[i]+1}}
  output.print "\n"

  # output.print "proximity\n"; matrix.each{|x| output.print x[0]; (1...x.size).each{|i| output.print ',',x[i]}; output.print "\n"}

  opt_pairs = []; opt_prox = proximity[0][1]

  (0...clusters.size).each{|i|
    (i+1...clusters.size).each{|j|
      if opt_prox > proximity[i][j]
        opt_pairs = [[i,j]]; opt_prox = proximity[i][j]
      elsif opt_prox == proximity[i][j]
        opt_pairs << [i,j]
      end
    }
  }

  output.print "opt_pairs\n"
  opt_pairs.each{|i| 
    output.print clusters[i[0]][0]+1; (1...clusters[i[0]].size).each{|j| output.print ',',clusters[i[0]][j]+1}
    output.print ' / '
    output.print clusters[i[1]][0]+1; (1...clusters[i[1]].size).each{|j| output.print ',',clusters[i[1]][j]+1}
    output.print "\n"
  }

  opt_pair = opt_pairs[rand(opt_pairs.size)]
  c1 = clusters[opt_pair[0]]; c2 = clusters[opt_pair[1]]

  out = 'selected pair / '
  out += (c1[0]+1).to_s; (1...c1.size).each{|i| out += ',' + (c1[i]+1).to_s}
  out += " / "
  out += (c2[0]+1).to_s; (1...c2.size).each{|i| out += ',' + (c2[i]+1).to_s}
  out += ' / ' + (opt_prox).to_s + ' / ' + (opt_prox - prev_prox).to_s + "\n"
  output.print out; print out
    
  prev_prox = opt_prox

  coph_dis = opt_prox
  c1.each{|i| c2.each{|j| coph_matrix[i][j] = coph_dis; coph_matrix[j][i] = coph_dis }}

  linkage.call(opt_pair[0],opt_pair[1],proximity,clusters)

  output.print 'real time ', (Time.now - start).to_s, "\n"

  output.close
end

output = File.open(base_clst + '/cophenetic', 'w')

coph_matrix.each{|x| output.print x[0]; (1...x.size).each{|i| output.print ',',x[i]}; output.print "\n"}

output.close
