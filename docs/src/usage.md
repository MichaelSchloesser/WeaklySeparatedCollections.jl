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

## Creating WSC's

!!! compat "Vectors instead of sets"
    In this package we use vecors in place of sets, although WSC's are by definition sets of $k$-sets. 
    We always assume such vectors to be increasingly ordered and not contain double elements. 
    None of the below methods check these properties and unforseen behavior may arise if they are not fulfilled.

The data type for WSC's or rather (abstract) plabic tilings is given by `WSCollection`.

```@docs
WSCollection
```

### Constructors

There are three different constructors to create a WSC:

```@docs
WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}; computeCliques::Bool = true)
WSCollection(k::Int, n::Int, labels::Vector{Vector{Int}}, quiver::SimpleDiGraph{Int}; computeCliques::Bool = true)
WSCollection(collection::WSCollection; computeCliques::Bool = true)
```

Thus to construct a WSC we only need to know its labels.

#### Examples:
```@example constructors
using WeaklySeparatedCollections # hide
labels = [[1, 5, 6], [1, 2, 6], [1, 2, 3], [2, 3, 4], [3, 4, 5], 
          [4, 5, 6], [2, 5, 6], [2, 3, 6], [3, 5, 6], [3, 4, 6] ]
is_weakly_separated(6, labels) # checks for pairwise weak separation
```

```@example constructors
C = WSCollection(3, 6, labels)
```

However, if the underlying quiver is already known it can be passed to the constructor to speed up computations.

```@example constructors
Q = C.quiver
WSCollection(3, 6, labels, Q)
```

The last constructor is useful, if we already have a WSC but want to omit the 2-cells or if the 2-cells of our WSC are missing and we want to compute them.

```@example constructors
D = WSCollection(C, computeCliques = false)
cliques_missing(D) # checks if the cliques (i.e. the 2-cells) are missing
```

```@example constructors
D = WSCollection(D)
D.whiteCliques
```

### Extending to maximal collections

Sometimes we only want some maximal WSC containing one or more disired labels. To obtain such WSC's we simple add labels to our desired as long as possible.

```@docs
extend_weakly_separated!
extend_to_collection
```

#### Examples:

We may extend by brute force:

```@example extending
using WeaklySeparatedCollections # hide
label = [1, 3, 4]
extend_weakly_separated(3, 6, [label])
```
Or if we want to prefer labels from a known weakly separated set (and then fill up by brute force):

```@example extending
preferred_labels = [[1, 5, 6], [1, 2, 6], [1, 2, 3], [2, 3, 4], [3, 4, 5], 
                    [4, 5, 6], [2, 5, 6], [2, 3, 6], [3, 5, 6], [3, 4, 6]]
extend_weakly_separated(3, 6, [label], preferred_labels)
```

We could have just as well passed a WSC instead of `preferred_labels` above. Note that so far we only constructed arrays of labels.
To obtain a WSC containing these labels we use `extend_to_collection`.

```@example extending
extend_to_collection(3, 6, [label], preferred_labels)
```

## Predefined collections
We provide shortcuts for the construction of some well known WSC's:

```@docs
checkboard_collection
rectangle_collection
dual_checkboard_collection
dual_rectangle_collection
```

#### Examples:

```@example predefined
using WeaklySeparatedCollections # hide
rectangle_collection(3, 6)
```

If we only want the underlying labels we may instead use [`rectangle_labels(k::Int, n::Int)`](@ref) (similar for the other predefined collections).

```@example predefined
rectangle_labels(3, 6)
```

The labels of the rectangle collection can be arranged on a grid in a natural way. Specific labels in this grid are returned by [rectangle_label(k::Int, n::Int, i::Int, j::Int)](@ref)
where $i = 0, ..., n-k$ and $j = 0, ..., k$ (similar for the other collections, where for the dual ones $i = 0, ..., k$ and $j = 0, ..., n-k$ ).

```@example predefined
rectangle_label(3, 6, 1, 2)
```

## Basic functionality
Armed with this plethora of examples, we are ready to discuss the basic functionalities of WSC's.

WSC's behave in many ways as their underlying arrays of labels would. In particular labels may be accessed directly.

```@example access
using WeaklySeparatedCollections # hide
rec = rectangle_collection(3, 6)
rec[3]
```

```@example access
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

#### Examples:

```@example basics
using WeaklySeparatedCollections # hide
rec = rectangle_collection(3, 6)
check = checkboard_collection(3, 6)

check[10] in rec 
```

```@example basics
length(check)
```

```@example basics
intersect(rec, check) # similar for union and setdiff
```

## Mutation

WSC's usually contain `frozen` elements that never change. On the other hand some elements may be modified via mutation and are called `mutable`.
To figure out which elements of a WSC are frozen or mutable use the functions `is_frozen` or `is_mutable`.

```@docs
is_frozen
is_mutable
```

```@example
using WeaklySeparatedCollections # hide
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

Finally, to mutate a WSC in the direction of a mutable label, the functions `mutate`and `mutate!` are available.

```@docs
mutate!
mutate
```

#### Examples:

```@example mutation
using WeaklySeparatedCollections # hide
rec = rectangle_collection(3, 6)
get_mutables(rec)
```

```@example mutation
mutate!(rec, 7)
println(rec, full = true)
```

### Other transformations

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

### Searching

TODO:

BFS, DFS, generalized_associahedron, number_wrong_labels, min_label_dist, min_label_dist_experimental, HEURISTIC, Astar, find_label

#### Examples:

```@example transformations
using WeaklySeparatedCollections # hide
check = checkboard_collection(3, 6)
check.labels
```

```@example transformations
using WeaklySeparatedCollections # hide
check = checkboard_collection(3, 6)
rotate!(check, 1)
check.labels
```

```@example transformations
using WeaklySeparatedCollections # hide
reflect!(check, 1)
check.labels
```

## Oscar extension

TODO

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

#### Examples:

TODO

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

