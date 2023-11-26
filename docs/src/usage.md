# User guide

## Mathematical background

### Weakly separated Collections

For any integer $n \geq 1$ we use the notation $[n]:= \{1, 2, \ldots, n\}$. 

Let $I, J$ be $k$-subsets of $[n]$, then we call $I$ and $J$ \textbf{weakly separated} if we cannot find elements $a, c \in I \setminus J$ and $b, d \in J \setminus I$ such that $(a, b, c, d)$ is strictly cyclically ordered. In this case we write $I \parallel J$. 
		
A subset $\mathcal{C} \subseteq$ Pot$(k,n)$ is called a \textbf{weakly separated collection} (abbreviated by wsc) if its elements are pairwise weakly separated.

Intuitively two $k$-subsets are weakly separated if after can arranging $I \setminus J$ and $J \setminus I$ clockwise on a circle, they can be separated by a line.

### Plabic Tilings




### Plabic Graphs


## Combinatorics

In this section we will learn how to use the combinatorial part of WeaklySeparatedCollections.

```@docs
is_weakly_separated
```

```@docs
rectangle_labels
checkboard_labels
dual_rectangle_labels
dual_checkboard_labels
```

```@docs
WSCollection
```

```@docs
isequal
Base.:(==)
```

```@docs
is_frozen
is_mutable
```

```@docs
mutate!
mutate
```

```@docs
checkboard_collection
rectangle_collection
dual_checkboard_collection
dual_rectangle_collection
```

```@docs
rotate_collection!
rotate_collection
```

```@docs
reflect_collection!
reflect_collection
```

```@docs
complement_collection!
complement_collection
```

```@docs
swaped_colors_collection!
swaped_colors_collection
```

```@docs
extend_weakly_separated!
extend_to_collection
```

<!-- TODO
compute_cliques, compute_adjacencies, compute_boundaries, super_potential_labels -->

## Plotting

```@docs
drawTiling
```

```@docs
drawPLG_straight
```

```@docs
drawPLG_smooth
```

```@docs
drawPLG_poly
```

## Graphical user interface

```@docs
visualizer!
```
