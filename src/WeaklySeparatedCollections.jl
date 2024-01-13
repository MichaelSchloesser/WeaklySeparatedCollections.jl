
module WeaklySeparatedCollections

export  is_weakly_separated, checkboard_label, rectangle_labels, checkboard_labels, dual_rectangle_labels, dual_checkboard_labels, 
        WSCollection, hash, in, getindex, setindex!, length, cliques_missing, intersect, setdiff, union, is_frozen, is_mutable, get_mutables, mutate!, mutate, 
        checkboard_collection, rectangle_collection, 
        dual_checkboard_collection, dual_rectangle_collection, rotate_collection!, reflect_collection!, complement_collection!, 
        swaped_colors_collection!, rotate_collection, reflect_collection, complement_collection, swaped_colors_collection, 
        extend_weakly_separated!, extend_to_collection, compute_cliques, compute_adjacencies, compute_boundaries, super_potential_labels,
        BFS, DFS, generalized_associahedron, number_wrong_labels, min_label_dist, min_label_dist_experimental, HEURISTIC, Astar, find_label

export  drawTiling, drawPLG_straight, drawPLG_smooth, drawPLG_poly
        
export  visualizer!

export  Seed, grid_Seed, extended_checkboard_seed, get_superpotential_terms, checkboard_potential_terms,
        dihedral_perm_group, cyclic_perm_group, standard_form, get_orbit, get_stabilizer

using Graphs
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
- `backgroundColor::Union{String, ColorTypes.Colorant} = ""`
- `drawLabels::Bool = true`
- `adjustAngle::Bool = false`
- `highlightMutables::Bool = true`
- `scale::Float64 = 0.0`
"""
function drawTiling end

@doc raw"""
    drawPLG_straight(collection::WSCollection, title::String, width::Int = 500, height::Int = 500)

Draw the plabic graph of the provided weakly separated `collection` and save it as an 
image file of specified size. All inner edges are drawn as straight line.
Both the name as well as the resulting file type of the image are controlled via `title`.

Inside a Jupyter sheet drawing without saving an image is possible by omitting the title argument i.e. via
`drawPLG_straight(collection::WSCollection, width::Int = 500, height::Int = 500)`. 

# Keyword Arguments
- `backgroundColor::Union{String, ColorTypes.Colorant} = ""`
- `drawLabels::Bool = true`
- `adjustAngle::Bool = false`
- `highlightMutables::Bool = true`
- `scale::Float64 = 0.0`
"""
function drawPLG_straight end

@doc raw"""
    drawPLG_smooth(collection::WSCollection, title::String, width::Int = 500, height::Int = 500)

Draw the plabic graph of the provided weakly separated `collection` and save it as an 
image file of specified size. All inner edges are drawn as smooth curves.
Both the name as well as the resulting file type of the image are controlled via `title`.

Inside a Jupyter sheet drawing without saving an image is possible by omitting the title argument i.e. via
`drawPLG_smooth(collection::WSCollection, width::Int = 500, height::Int = 500)`. 

# Keyword Arguments
- `backgroundColor::Union{String, ColorTypes.Colorant} = ""`
- `drawLabels::Bool = true`
- `adjustAngle::Bool = false`
- `scale::Float64 = 0.0`
"""
function drawPLG_smooth end

@doc raw"""
    drawPLG_poly(collection::WSCollection, title::String, width::Int = 500, height::Int = 500)

Draw the plabic graph of the provided weakly separated `collection` and save it as an 
image file of specified size. All inner edges are drawn as polygonal curves.
Both the name as well as the resulting file type of the image are controlled via `title`.

Inside a Jupyter sheet drawing without saving an image is possible by omitting the title argument i.e. via
`drawPLG_poly(collection::WSCollection, width::Int = 500, height::Int = 500)`. 

# Keyword Arguments
- `backgroundColor::Union{String, ColorTypes.Colorant} = ""`
- `drawLabels::Bool = true`
- `adjustAngle::Bool = false`
- `scale::Float64 = 0.0`
"""
function drawPLG_poly end

@doc raw"""
    visualizer!(collection::WSCollection = rectangle_collection(4, 9))

Start the graphical user interface to visualize the provided `collection`.
"""
function visualizer! end

# TODO somehow restrict type of variables
mutable struct Seed 
    n_frozen::Int
    variables
    quiver::SimpleDiGraph{Int}
end

function Seed end

function grid_Seed end

function extended_checkboard_seed end

function get_superpotential_terms end

function checkboard_potential_terms end

function dihedral_perm_group end

function cyclic_perm_group end

function standard_form end

function get_orbit end

function get_stabilizer end

end