
import Mousetrap # can be removed after mousetrap reaches version 0.3.1
module WeaklySeparatedCollections

export visualizer

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
