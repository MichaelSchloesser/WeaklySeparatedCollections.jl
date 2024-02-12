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


