# Hierarchical Clustering

An implementation of [hierarchical clustering](https://en.wikipedia.org/wiki/Hierarchical_clustering).

## How to use

Specifying attribute information (`<attribute file>`), data file (`<data file>`) and linkage method (`<linkage>`),
run the following command.
```
ruby clustering.rb  -a <attribute file> -i <data file> -l <linkage> -g <ignored attributes>
```
where `<ignore attributes>` is an array of attributes ignored in clustering.
The clustering results are saved in `a_dir/` directory.

We have 3 linkage methods.
* single_linkage
* complete_linkage
* average_linkage

Next, we obtain a PGF/TikZ file of the dendrogram from the cophenetic matrix (`a_dir/cophenetic`).
```
ruby coph_to_tikz.rb -c a_dir/cophenetic 
```
A default output is `dendro_tikz`.
Copy the output in a figure environment of an LaTeX file.
We need `\usepackage{tikz}` in the preamble of the LaTeX file.

For `zoo.data`, we set
```
<attribute file> := datasets/iris.attr
<data file> := datasets/iris.data
<ignored attributes> := id,type
```

# Example
Run, the following.
```
ruby clustering.rb  -a datasets/zoo.attr -i datasets/zoo.data -l average_linkage -g id,type
ruby coph_to_tikz.rb -c a_dir/cophenetic
```
We obtain a dendrogram.

<img src="dendro.png" width="960">
