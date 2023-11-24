
module WeaklySeparatedCollections

export  is_weakly_separated, rectangle_labels, checkboard_labels, dual_rectangle_labels, dual_checkboard_labels, 
        WSCollection, isequal, is_frozen, is_mutable, mutate!, mutate, checkboard_collection, rectangle_collection, 
        dual_checkboard_collection, dual_rectangle_collection, rotate_collection!, reflect_collection!, complement_collection!, 
        swaped_colors_collection!, rotate_collection, reflect_collection, complement_collection, swaped_colors_collection, 
        extend_weakly_separated!, extend_to_collection, compute_cliques, compute_adjacencies, compute_boundaries, super_potential_labels

export  drawTiling, drawPLG_straight, drawPLG_smooth, drawPLG_poly
        
export  visualizer!

using Graphs
using IterTools

include("Combinatorics.jl")

@doc raw"""
    drawTiling(collection::WSCollection, title::String, width::Int = 500, height::Int = 500)

Draw the plabic tiling of the provided weakly separated `collection` and save it as an 
image file of specified size. 
Both the name as well as the resulting file type of the image are controlled via `title`.

# Keyword Arguments
- `backgroundColor::Union{String, ColorTypes.Colorant} = ""`
- `drawLabels::Bool = true`
- `adjustAngle::Bool = false`
- `highlightMutables::Bool = true`
- `scale::Float64 = 0.0`

# Examples

"""
function drawTiling end

@doc raw"""
    drawPLG_straight(collection::WSCollection, title::String, width::Int = 500, height::Int = 500)

Draw the plabic graph of the provided weakly separated `collection` and save it as an 
image file of specified size. All inner edges are drawn as straight line.
Both the name as well as the resulting file type of the image are controlled via `title`.

# Keyword Arguments
- `backgroundColor::Union{String, ColorTypes.Colorant} = ""`
- `drawLabels::Bool = true`
- `adjustAngle::Bool = false`
- `highlightMutables::Bool = true`
- `scale::Float64 = 0.0`

# Examples

"""
function drawPLG_straight end

@doc raw"""
    drawPLG_smooth(collection::WSCollection, title::String, width::Int = 500, height::Int = 500)

Draw the plabic graph of the provided weakly separated `collection` and save it as an 
image file of specified size. All inner edges are drawn as smooth curves.
Both the name as well as the resulting file type of the image are controlled via `title`.

# Keyword Arguments
- `backgroundColor::Union{String, ColorTypes.Colorant} = ""`
- `drawLabels::Bool = true`
- `adjustAngle::Bool = false`
- `scale::Float64 = 0.0`

# Examples

"""
function drawPLG_smooth end

@doc raw"""
    drawPLG_smooth(collection::WSCollection, title::String, width::Int = 500, height::Int = 500)

Draw the plabic graph of the provided weakly separated `collection` and save it as an 
image file of specified size. All inner edges are drawn as polygonal curves.
Both the name as well as the resulting file type of the image are controlled via `title`.

# Keyword Arguments
- `backgroundColor::Union{String, ColorTypes.Colorant} = ""`
- `drawLabels::Bool = true`
- `adjustAngle::Bool = false`
- `scale::Float64 = 0.0`

# Examples

"""
function drawPLG_poly end

@doc raw"""
    visualizer!(collection::WSCollection = rectangle_collection(4, 9))

Start the graphical user interface to visualize the provided `collection`.
"""
function visualizer! end

end
