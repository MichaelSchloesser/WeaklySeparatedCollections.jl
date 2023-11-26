# User guide

## Mathematical background

### Weakly separated Collections

For any integer $n \geq 1$ we use the notation $[n]:= \{1, 2, \ldots, n\}$ and denote by $\text{Pot}(k,n)$ the set of $k$-subsets of $[n]$.

Let $I, J$ be $k$-subsets of $[n]$, then we call $I$ and $J$ $\textbf{weakly separated}$ if we cannot find elements $a, c \in I \setminus J$ and $b, d \in J \setminus I$ such that 
$(a, b, c, d)$ is strictly cyclically ordered. In this case we write $I \parallel J$. 

Intuitively two $k$-subsets are weakly separated if after can arranging $I \setminus J$ and $J \setminus I$ clockwise on a circle, they can be separated by a line.

A subset $\mathcal{C} \subseteq \text{Pot}(k,n)$ is called a $\textbf{weakly separated collection}$ (abbreviated by WSC) if its elements are pairwise weakly separated. 
We often referr to elements of a WSC as labels.

### Plabic Tilings

Any WSC can be given the structure of an abstract $2$-dimensional cell complex, which in turn may be embedded into the plane.
This construction will be called an (abstract) $\textbf{plabic tiling}$, and we referr to #TODO for the mathematical details.

Intuitively a plabic tiling is a tiling of a convex $n$-gon into convex polygons, colored either black or white, and with vertices labelled by the elements of the underlying WSC.

### Plabic Graphs

A $\textbf{plabic graph}$ is a finite simple connected plane graph $G$ whose interior is bounded by a vertex disjoint cycle containing $n$ $\textbf{boundary vertices}$ 
$b_1, \ldots, b_n$. Here the labelling is chosen in clockwise order.

We only consider $\textbf{reduced}$ plabic graphs which can be seen to be in one to one correspondance to WSC's as well as plabic tilings. For more details we referr to #TODO.

## Combinatorics

In this section we will learn how to use the combinatorial part of WeaklySeparatedCollections. 

!!! compat "Vectors instead of sets"
    In this package we use vecors in place of sets, although WSC's are by definition sets of $k$-sets. 
    We always assume such vectors to be increasingly ordered and not contain double elements. 
    None of the below methods check these properties and unforseen behavior may arise if they are not fulfilled.

To see if two or more $k$-subsets are weakly separated, we use the function `is_weakly_separated`.

```@docs
is_weakly_separated
```

The labels of some known weakly separated collections are available via

```@docs
rectangle_labels
checkboard_labels
dual_rectangle_labels
dual_checkboard_labels
```

The data type for WSC's or rather (abstract) plabic tilings is given by

```@docs
WSCollection
```

We may easily compare two WSC's

```@docs
isequal
Base.:(==)
```

WSC's usually contain `frozen` elements that never change. On the other hand some elements may be modified via mutation and are called `mutable`.
To figure out which elemnents of a WSC are frozen or mutable we have the functions

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
