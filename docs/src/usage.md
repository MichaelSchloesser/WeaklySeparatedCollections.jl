# User guide

## Introduction

We start off by giving some mathematical background, or rather by defining the needed language.

### Weakly separated Collections

For any integer $n \geq 1$ we use the notation $[n]:=$ \{ $1, 2, \ldots, n$ \} and denote by $\text{Pot}(k,n)$ the set of $k$-subsets of $[n]$.

#### Definition (weak separation)
Let $I, J$ be $k$-subsets of $[n]$, then we call $I$ and $J$ $\textbf{weakly separated}$ if we cannot find elements $a, c \in I \setminus J$ and $b, d \in J \setminus I$ such that 
$(a, b, c, d)$ is strictly cyclically ordered. In this case we write $I \parallel J$. 

Intuitively two $k$-subsets are weakly separated if after can arranging $I \setminus J$ and $J \setminus I$ clockwise on a circle, they can be separated by a line.

#### Definition (weakly separated collection)
A subset $\mathcal{C} \subseteq \text{Pot}(k,n)$ is called a $\textbf{weakly separated collection}$ (abbreviated by WSC) if its elements are pairwise weakly separated. 
We often referr to elements of a WSC as labels.

#### Definition (mutation)
If $\mathcal{C}$ is a WSC that includes sets of the form $Iab, Ibc, Icd, Iad$ and $Iac$, where $(a,b,c,d)$ is strictly cyclically ordered. 
Then $$\mathcal{C'} = (\mathcal{C} \setminus \{Iac\}) \cup \{Ibd\}$$ is also a weakly separated collection, and we call the exchange of $Iac$ by $Ibd$ a $\textbf{mutation}$.

### Plabic Tilings

#### Definition (plabic tiling)
Any WSC can be given the structure of an abstract $2$-dimensional cell complex, which in turn may be embedded into the plane.
This construction will be called an (abstract) $\textbf{plabic tiling}$, and we referr to 
TODO for the mathematical details.

Intuitively a plabic tiling is a tiling of a convex $n$-gon into convex polygons, colored either black or white, and with vertices labelled by the elements of the underlying WSC.
Plabic tilings are in bijective correspondance with WSC's that are maximal with respect to inclusion.

### Plabic Graphs

#### Definition (plabic graph)
A $\textbf{plabic graph}$ is a finite simple connected plane graph $G$ whose interior is bounded by a vertex disjoint cycle containing $n$ $\textbf{boundary vertices}$ 
$b_1, \ldots, b_n$. Here the labelling is chosen in clockwise order.

We only consider $\textbf{reduced}$ plabic graphs which can be also seen to be in one to one correspondance to WSC's that are maximal with respect to inclusion. 
For more details we referr to TODO.

## Weakly separated collections

In this section we will learn how to create and use a WSC.

!!! compat "Vectors instead of sets"
    In this package we use vecors in place of sets, although WSC's are by definition sets of $k$-sets. 
    We always assume such vectors to be increasingly ordered and not contain double elements. 
    None of the below methods check these properties and unforseen behavior may arise if they are not fulfilled.

The data type for WSC's or rather (abstract) plabic tilings is given by `WSCollection`.

```@docs
WSCollection
```

```@docs
WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}; computeCliques::Bool = true)
```

```jldoctest
julia> a = 1

julia> b = 2;

julia> c = 3;  # comment

julia> a + b + c
```


To see if two or more $k$-subsets are weakly separated, we use the function `is_weakly_separated`.

```@docs
is_weakly_separated
```

## predefined collections

The labels of some known weakly separated collections are available via

```@docs
rectangle_labels
checkboard_labels
dual_rectangle_labels
dual_checkboard_labels
```

The above predefined sets of labels give rise to weakly separated collections which are available via

```@docs
checkboard_collection
rectangle_collection
dual_checkboard_collection
dual_rectangle_collection
```

Two WSC's are considered equal if their underlying labels are equal as sets. 

```@docs
Base.:(==)
```

WSC's usually contain `frozen` elements that never change. On the other hand some elements may be modified via mutation and are called `mutable`.
To figure out which elemnents of a WSC are frozen or mutable use the functions `is_frozen` or `is_mutable`.

```@docs
is_frozen
is_mutable
```

To mutate a WSC, the functions `mutate`and `mutate!` are available.

```@docs
mutate!
mutate
```

Apart from mutation, several other transformations of WSC's are available:

```@docs
rotate!
rotate
```

```@docs
reflect!
reflect
```

```@docs
complement!
complement
```

```@docs
swap_colors!
swap_colors
```

We often want to deal with maximal WSC's instead of their subsets. To extend a given WSC to a maximal one, the following functions may be used:

```@docs
extend_weakly_separated!
extend_to_collection
```

## Plotting
Plotting WSC's requires `Luxor` to be installed and loaded as detailed [here](https://michaelschloesser.github.io/WeaklySeparatedCollections.jl/stable/#Extensions).

In the introduction we learned about plabic tilings as well as plabic graphs as objects living in the plane which are in one to one correspndance to maximal WSC's.
Thus we can plot a maximal WSC using its corresponding plabic tiling or plabic graph. The functions to accomplish this are:

```@docs
drawTiling
```

```@docs
drawPLG
```

## Graphical user interface
This section is work in progress.

The graphical user interface requires both an installation of `Luxor` as well as `Mousetrap`. See [here](https://michaelschloesser.github.io/WeaklySeparatedCollections.jl/stable/#Extensions) for details.

While plotting WSC's enables us to visualize them, the resulting images lack interactivity. This is where the built in gui application comes in handy. To start it we use

```@docs
visualizer!
```

TODO:

[`WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}; computeCliques::Bool = true)`](@ref)

### settings
explain the non obvious options (or all) here.

- `adjust drawing angle`: If checked, the embeddings of the plabic graph (and tiling) will be rotated such that the boundary vertex `1` is drawn at a more consistant position.

### file: saving, loading, export

### edit
