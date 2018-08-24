require 'optparse'

coph_file = 'coph'
out_file = 'dendro_tikz'
line_width = 0.01
font_scale = 0.05

opt = OptionParser.new
opt.on('-c COPHENETIC_FILE',String){|v| coph_file = v}
opt.on('-o OUTPUT_FILE',String){|v| out_file = v}
opt.on('-l LINE_WIDTH',Float){|v| line_width = v}
opt.on('-f FONT_SCALE',Float){|v| font_scale = v}

opt.parse!(ARGV)

cophenetic = []

input = File.open(coph_file)
input.each{|l|
  row = l.split(',')
  if row.size > 1
    cophenetic << row.map{|v| v.to_f}
  end
}
input.close

m = cophenetic.size

max_level = cophenetic.flatten.uniq.sort[-1]

output = File.open(out_file, 'w')

output.print("\\begin{tikzpicture}\n")
output.print("\\tikzset{dendro_line/.style={line width=#{line_width}mm}};\n")
output.print("\\tikzset{dendro_label/.style={rotate=90,left,scale=#{font_scale}}};\n")
output.print("\\tikzset{dendro_label2/.style={left,scale=#{font_scale}}};\n")
output.print("\\draw [dendro_line] (-0.05,0) -- (-0.05,-1);\n")
output.print("\\node at (-0.05,-1) [dendro_label2] {0};\n")
output.printf("\\node at (-0.05,-0.75) [dendro_label2] {%.2e};\n",max_level/4.0)
output.printf("\\node at (-0.05,-0.5) [dendro_label2] {%.2e};\n",max_level/2.0)
output.printf("\\node at (-0.05,-0.25) [dendro_label2] {%.2e};\n",max_level/4.0*3)
output.printf("\\node at (-0.05,-0.0) [dendro_label2] {%.2e};\n",max_level)

# line_style = "[line width=#{line_width}mm]"
# node_style = "[rotate=90,left,scale=#{font_scale}]"

def gen_tree(submat,ind,pos,max_level,num_node,par_count,count,output)

  m = submat.size
  maxv = submat.flatten.uniq.sort[-1]

  if m == 1
    output.print("\\node (n#{count}) at (#{pos*1.4},#{-1}) [dendro_label] {#{ind[0]}};\n")
    output.print("\\draw [dendro_line] (n#{count}) |- (n#{par_count}.center);\n")
    return count;
  else
    output.print("\\node (n#{count}) at (#{pos*1.4},#{(maxv/max_level.to_f-1.0)}) {};\n")
    output.print("\\draw [dendro_line] (n#{count}.center) |- (n#{par_count}.center);\n")
  end

  if maxv == 0
    g1 = [0]
  else
    g1 = (0...m).to_a.select{|i| submat[0][i] < maxv}
  end
  submat1 = g1.map{|i| g1.map{|j| submat[i][j]}}
  ind1 = g1.map{|i| ind[i]}
  m1 = g1.size
  pos1 = pos - (m-m1)/2.0/(num_node-1).to_f
  count1 = gen_tree(submat1,ind1,pos1,max_level,num_node,count,count+1,output)

  g2 = (0...m).to_a - g1
  submat2 = g2.map{|i| g2.map{|j| submat[i][j]}}
  ind2 = g2.map{|i| ind[i]}
  m2 = g2.size
  pos2 = pos + (2*m1+m2-m)/2.0/(num_node-1).to_f
  count2 = gen_tree(submat2,ind2,pos2,max_level,num_node,count,count1+1,output)

  return count2;

end

gen_tree(cophenetic,(0...m).to_a,0.5,max_level,m,0,0,output)

output.print("\\end{tikzpicture}\n")


