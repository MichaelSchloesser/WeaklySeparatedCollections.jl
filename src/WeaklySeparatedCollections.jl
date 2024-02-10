
module WeaklySeparatedCollections

export  is_weakly_separated, frozen_label, super_potential_label, checkboard_label, rectangle_label, checkboard_label, dual_rectangle_label,
        frozen_labels, super_potential_labels, rectangle_labels, checkboard_labels, dual_rectangle_labels, dual_checkboard_labels, 
        WSCollection, hash, in, getindex, setindex!, length, cliques_missing, intersect, setdiff, union, is_frozen, is_mutable, get_mutables, mutate!, mutate, 
        checkboard_collection, rectangle_collection, dual_checkboard_collection, dual_rectangle_collection, 
        rotate!, reflect!, complement!, swap_colors!, rotate, reflect, complement, swap_colors, 
        extend_weakly_separated!, extend_to_collection

export  BFS, DFS, generalized_associahedron, number_wrong_labels, min_label_dist, min_label_dist_experimental, HEURISTIC, Astar, find_label

export  drawTiling, drawPLG
        
export  visualizer!

export  Seed, grid_Seed, extended_rectangle_seed, extended_checkboard_seed,
        get_superpotential_terms, rectangle_potential_terms, checkboard_potential_terms,
        dihedral_perm_group, cyclic_perm_group, standard_form, get_orbit, get_stabilizer,
        newton_okounkov_inequalities, checkboard_inequalities, checkboard_body, newton_okounkov_body

import Graphs: SimpleDiGraph, edges, src, dst, has_edge, add_edge!, rem_edge!, inneighbors, outneighbors, degree

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

mutable struct Seed
    n_frozen::Int
    variables
    quiver::SimpleDiGraph{Int}
end

function Seed end

function grid_Seed end

function extended_checkboard_seed end

function extended_rectangle_seed end

function get_superpotential_terms end

function checkboard_potential_terms end

function rectangle_potential_terms end

function newton_okounkov_inequalities end

function checkboard_inequalities end

function newton_okounkov_body end

function checkboard_body end

function dihedral_perm_group end

function cyclic_perm_group end

function standard_form end

function get_orbit end

function get_stabilizer end

end