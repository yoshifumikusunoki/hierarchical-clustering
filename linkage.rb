def single_linkage(i,j,matrix,clusters)
  if i > j then tmp = i; i = j; j = tmp end

  mi = []; mj = []
  (0...i).each{|k| mi[k] = matrix[k][i]; mj[k] = matrix[k][j]}
  (i+1...j).each{|k| mi[k-1] = matrix[i][k]; mj[k-1] = matrix[k][j]}
  (j+1...clusters.size).each{|k| mi[k-2] = matrix[i][k]; mj[k-2] = matrix[j][k]}

  matrix.each{|m| m.delete_at(j); m.delete_at(i)}
  matrix.delete_at(j);
  matrix.delete_at(i);

  cj = clusters.delete_at(j);
  ci = clusters.delete_at(i);
  clusters << (ci | cj).sort

  (0...clusters.size-1).each{|k|
    matrix[k][clusters.size-1] = (mi[k] < mj[k]) ? mi[k] : mj[k]
  }
  matrix[clusters.size-1] = []
end

def complete_linkage(i,j,matrix,clusters)
  if i > j then tmp = i; i = j; j = tmp end

  mi = []; mj = []
  (0...i).each{|k| mi[k] = matrix[k][i]; mj[k] = matrix[k][j]}
  (i+1...j).each{|k| mi[k-1] = matrix[i][k]; mj[k-1] = matrix[k][j]}
  (j+1...clusters.size).each{|k| mi[k-2] = matrix[i][k]; mj[k-2] = matrix[j][k]}

  matrix.each{|m| m.delete_at(j); m.delete_at(i)}
  matrix.delete_at(j);
  matrix.delete_at(i);

  cj = clusters.delete_at(j);
  ci = clusters.delete_at(i);
  clusters << (ci | cj).sort

  (0...clusters.size-1).each{|k|
    matrix[k][clusters.size-1] = (mi[k] > mj[k]) ? mi[k] : mj[k]
  }
  matrix[clusters.size-1] = []
end

def average_linkage(i,j,matrix,clusters)
  if i > j then tmp = i; i = j; j = tmp end

  mi = []; mj = []
  (0...i).each{|k| mi[k] = matrix[k][i]; mj[k] = matrix[k][j]}
  (i+1...j).each{|k| mi[k-1] = matrix[i][k]; mj[k-1] = matrix[k][j]}
  (j+1...clusters.size).each{|k| mi[k-2] = matrix[i][k]; mj[k-2] = matrix[j][k]}

  matrix.each{|m| m.delete_at(j); m.delete_at(i)}
  matrix.delete_at(j);
  matrix.delete_at(i);

  cj = clusters.delete_at(j);
  ci = clusters.delete_at(i);
  clusters << (ci | cj).sort

  (0...clusters.size-1).each{|k|
    matrix[k][clusters.size-1] = (ci.size*mi[k] + cj.size*mj[k])/(ci.size+cj.size).to_f
  }
  matrix[clusters.size-1] = []
end