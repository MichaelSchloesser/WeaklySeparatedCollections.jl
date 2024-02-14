
module WeaklySeparatedCollections

export  WSCollection,

        frozen_label, checkboard_label, rectangle_label, checkboard_label, dual_rectangle_label,
        frozen_labels, rectangle_labels, checkboard_labels, dual_rectangle_labels, dual_checkboard_labels,
        checkboard_collection, rectangle_collection, dual_checkboard_collection, dual_rectangle_collection,

        getindex, setindex!, length, in,
        intersect, setdiff, union, 

        is_frozen, is_mutable, get_mutables, mutate!, mutate,
        rotate!, reflect!, complement!, swap_colors!, rotate, reflect, complement, swap_colors, 

        extend_weakly_separated!, extend_to_collection,
        is_weakly_separated, hash, cliques_missing

export  BFS, DFS, generalized_associahedron, number_wrong_labels, min_label_dist, min_label_dist_experimental, 
        HEURISTIC, NUMBER_WRONG_LABELS, MIN_LABEL_DIST, MIN_LABEL_DIST_EXPERIMENTAL, Astar, find_label

export  drawTiling, drawPLG
        
export  visualizer!

export  Seed, grid_Seed, extended_rectangle_seed, extended_checkboard_seed,
        get_superpotential_terms, rectangle_potential_terms, checkboard_potential_terms,
        newton_okounkov_inequalities, checkboard_inequalities, checkboard_body, newton_okounkov_body

import Graphs: SimpleGraph, SimpleDiGraph, nv, edges, src, dst, has_edge, add_edge!, add_vertex!, rem_edge!, inneighbors, outneighbors, degree

using IterTools
using DataStructures

include("Combinatorics.jl")
include("Searching_algorithms.jl")

@doc raw"""
    drawTiling(collection::WSCollection, title::String, width::Int = 500, height::Int = 500)

Draw the plabic tiling of the provided weakly separated `collection` and save it as an 
image file of specified size. 
Both the name as well as the resulting file type of the image are controlled via `title`.

Inside a Jupyter sheet drawing without saving an image is possible by omitting the title argument i.e. via
`drawTiling(collection::WSCollection, width::Int = 500, height::Int = 500)`.

# Keyword Arguments
- `topLabel = nothing`
- `backgroundColor::Union{String, ColorTypes.Colorant} = ""`
- `drawLabels::Bool = true`
- `highlightMutables::Bool = true`
- `labelDirection = "left"`

`toplabel` controls the rotation of the drawing by drawing the specified label at the top.
`labelDirection` controls whether the "left" (i.e. the usual ones) or "right" (complements)
labels are drawn.
"""
function drawTiling end

@doc raw"""
    drawPLG(collection::WSCollection, title::String, width::Int = 500, height::Int = 500)

Draw the plabic graph of the provided weakly separated `collection` and save it as an 
image file of specified size.
Both the name as well as the resulting file type of the image are controlled via `title`.

Inside a Jupyter sheet drawing without saving an image is possible by omitting the title argument i.e. via
`drawPLG(collection::WSCollection, width::Int = 500, height::Int = 500)`. 

# Keyword Arguments
- `topLabel = nothing`
- `drawmode::String = "straight"`
- `backgroundColor::Union{String, ColorTypes.Colorant} = ""`
- `drawLabels::Bool = true`
- `highlightMutables::Bool = false`
- `labelDirection = "left"`

`toplabel` controls the rotation of the drawing by drawing the specified label at the top.
`drawmode` controls how edges are drawn and may be choosen as `"straight"`, `"smooth"` or `"polygonal"`.
`labelDirection` controls whether the "left" (i.e. the usual ones) or "right" (complements) labels 
are drawn.
"""
function drawPLG end

@doc raw"""
    visualizer!(collection::WSCollection = rectangle_collection(4, 9))

Start the graphical user interface to visualize the provided `collection`.
"""
function visualizer! end

@doc raw"""
    Seed

Seed in the rational function field of a multivariate polynomial ring over the
integers.

# Attributes
- `n_frozen::Int`
- `variables`
- `quiver::SimpleDiGraph{Int}`

# Constructors
    Seed(n_frozen::Int, variables, quiver::SimpleDiGraph{Int})
    Seed(cluster_size::Int, n_frozen::Int, quiver::SimpleDiGraph{Int})
    Seed(collection::WSCollection)
"""
mutable struct Seed
    n_frozen::Int
    variables
    quiver::SimpleDiGraph{Int}
end

function Seed end

@doc raw"""
    grid_Seed(n::Int, height::Int, width::Int, quiver::SimpleDiGraph{Int})
    grid_Seed(collection::WSCollection, height, width)

Return a seed with `n` respectively `collection.n` frozen variables and mutable
variables arranged on a grid with specified `height` and `width`. 
"""
function grid_Seed end

@doc raw"""
    extended_checkboard_seed(k::Int, n::Int)

Return the seed associated to the checkboard graph with variables on a grid
and a Matrix containing the variables in a naturally extended grid.
"""
function extended_checkboard_seed end

@doc raw"""
    extended_rectangle_seed(k::Int, n::Int)

Return the seed associated to the rectangle graph with variables on a grid
and a Matrix containing the variables in a naturally extended grid.
"""
function extended_rectangle_seed end

@doc raw"""
    get_superpotential_terms(collection::WSCollection, seed::Seed = Seed(collection))

Return the terms of the superpotential written in the cluster corresponding to
the specified `collection`. A seed can optionally be specified. 
"""
function get_superpotential_terms end

@doc raw"""
    checkboard_potential_terms(k::Int, n::Int)

Return the terms of the superpotential written in the cluster corresponding to
the checkboard graph.
"""
function checkboard_potential_terms end

@doc raw"""
    rectangle_potential_terms(k::Int, n::Int)

Return the terms of the superpotential written in the cluster corresponding to
the rectangle graph.
"""
function rectangle_potential_terms end

@doc raw"""
    newton_okounkov_inequalities(collection::WSCollection, r::Int = 1)

Return the `A` and `b` of the system `Ax <= b` describing the `r-th` 
dilation of the newton okounkov body of the specified `collection`.
"""
function newton_okounkov_inequalities end

@doc raw"""
    checkboard_inequalities(k::Int, n::Int, r::Int = 1)

Return the `A` and `b` of the system `Ax <= b` describing the `r-th` 
dilation of the newton okounkov body of the checkboard graph.
"""
function checkboard_inequalities end

@doc raw"""
    newton_okounkov_body(collection::WSCollection)

Return the newton okounkov body of the specified `collection`.
"""
function newton_okounkov_body end

@doc raw"""
    checkboard_body(k::Int, n::Int)

Return the newton okounkov body of the checkboard graph.
"""
function checkboard_body end

# not exported:
function dihedral_perm_group end

function cyclic_perm_group end

end