module WeaklySeparatedCollections

# export, using, import statements are usually here; we discuss these below

using Graphs
using Luxor
using Colors
using Mousetrap
using NativeFileDialog
using JLD2
using FileIO

root_path = dirname(@__DIR__) # path to WeaklySeparatedCollections

include("Combinatorics.jl")
include("Visualization.jl")
include("VisualizerGui.jl")

Point = Luxor.Point




end
