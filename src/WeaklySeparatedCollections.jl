
import Mousetrap # can be removed after mousetrap reaches version 0.3.1
module WeaklySeparatedCollections

export  is_weakly_separated, rectangle_labels, checkboard_labels, dual_rectangle_labels, dual_checkboard_labels, 
        WSCollection, isequal, is_frozen, is_mutable, mutate!, mutate, checkboard_collection, rectangle_collection, 
        dual_checkboard_collection, dual_rectangle_collection, rotate_collection!, reflect_collection!, complement_collection!, 
        swaped_colors_collection!, rotate_collection, reflect_collection, complement_collection, swaped_colors_collection, 
        extend_weakly_separated!, extend_to_collection, compute_cliques, compute_adjacencies, compute_boundaries, super_potential_labels

export  drawTiling, drawPLG_straight, drawPLG_smooth, drawPLG_poly

export  visualizer

using Graphs
using Luxor
using Colors
using Mousetrap
using NativeFileDialog
using JLD2
using FileIO
using Scratch
using IterTools

include("Combinatorics.jl")
include("Plotting.jl")  
include("Gui.jl")      

end
