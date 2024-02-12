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

## Creating a weakly separated collection

!!! compat "Vectors instead of sets"
    In this package we use vecors in place of sets, although WSC's are by definition sets of $k$-sets. 
    We always assume such vectors to be increasingly ordered and not contain double elements. 
    None of the below methods check these properties and unforseen behavior may arise if they are not fulfilled.

The data type for WSC's or rather (abstract) plabic tilings is given by `WSCollection`.

```@docs
WSCollection
```

There are three different constructors to create a WSC:

```@docs
WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}; computeCliques::Bool = true)
WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}, quiver::SimpleDiGraph{Int}; computeCliques::Bool = true)
WSCollection(collection::WSCollection; computeCliques::Bool = true)
```

Thus to construct a WSC we only need to know its labels.
```@example 1
labels = [[1, 5, 6], [1, 2, 6], [1, 2, 3], [2, 3, 4], [3, 4, 5], 
        [4, 5, 6], [2, 5, 6], [2, 3, 6], [3, 5, 6], [3, 4, 6]]
is_weakly_separated(labels)
```


stuffi

```@example 1
C = WSCollection(3, 6, labels)
```

However, if the underlying quiver is already known it can be passed to the constructor to speed up computations.

```@example 1
Q = C.quiver
WSCollection(3, 6, labels, Q)
```

The last constructor is useful, if we already have a WSC but want to omit the 2-cells or if the 2-cells of our WSC are missing and we want to compute them.

```@example 1
D = WSCollection(C, computeCliques = false)
D.whiteCliques
```

```@example 1
D = WSCollection(D)
D.whiteCliques
```

## Predefined collections
Although any WSC may be constructed as explained above, this can be quite tedious. Thus we provide shortcuts for the construction of some well known WSC's:

```@docs
checkboard_collection
rectangle_collection
dual_checkboard_collection
dual_rectangle_collection
```

If we only want the underlying labels we may instead use

```@docs
rectangle_label
rectangle_labels
```

```@docs
checkboard_label
checkboard_labels
```

```@docs
dual_rectangle_label
dual_rectangle_labels
```

```@docs
dual_checkboard_label
dual_checkboard_labels
```

## Basic functionality
Armed with this plethora of examples, we are ready to discuss the basic functionalities of WSC's.

WSC's behave in many ways as their underlying arrays of labels would. In particular labels may be accessed directly.

```@example 2
rec = rectangle_collection(3, 6)
rec[3]
```

```@example 2
rec[7] = [1, 3, 6]
```

Caution is advised when modifying labels as above, as it is not checked if the resulting labels are still weakly separated nor is the associated data changed accordingly.

For convenience we also extend the following functions:

```@docs
in
length
intersect
setdiff
union
```

Examples:
```@example 3
rec = rectangle_collection(3, 6)
check = checkboard_collection(3, 6)

check[10] in rec 
```

```@example 3
length(check)
```

```@example 3
intersect(rec, check) # similar for union and setdiff
```

## Mutation

WSC's usually contain `frozen` elements that never change. On the other hand some elements may be modified via mutation and are called `mutable`.
To figure out which elemnents of a WSC are frozen or mutable use the functions `is_frozen` or `is_mutable`.

```@docs
is_frozen
is_mutable
```

```@example
rec = rectangle_collection(3, 6)
is_frozen(rec, 4), is_mutable(rec, 7), is_mutable(rec, 11)
```

The frozen labels contained in any (maximal) WSC can be obtained via

```@docs
frozen_label
frozen_labels
```

The indices of the mutable labels on a WSC can be obtained by using

```@docs
get_mutables
```

Finally, to mutate a WSC, the functions `mutate`and `mutate!` are available.

```@docs
mutate!
mutate
```

Examples

## other transformations

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

