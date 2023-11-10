module WeaklySeparatedCollections

# export, using, import statements are usually here; we discuss these below

using Graphs
using Luxor
using Colors
using Mousetrap
using NativeFileDialog
using JLD2
using FileIO

include("WSCollections.jl")
include("Visualization.jl")

Point = Luxor.Point

root_path = dirname(@__DIR__) # path to WSCollection-Visualizer


end
