
import Mousetrap # can be removed after mousetrap reaches version 0.3.1
module WeaklySeparatedCollections

export  is_weakly_separated, checkboard_labels, rectangle_labels, WSCollection, is_frozen, 
        is_mutable, mutate!, mutate, checkboard_collection, rectangle_collection, rotate_collection,
        reflect_collection, complement_collection, swaped_colors_collection, dual_checkboard_collection, 
        dual_rectangle_collection, compute_cliques, compute_cliques, compute_adjacencies

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

include("Combinatorics.jl")
include("Plotting.jl")  
include("Gui.jl")      

end
