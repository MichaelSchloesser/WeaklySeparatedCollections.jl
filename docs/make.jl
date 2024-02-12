using Documenter, WeaklySeparatedCollections
import Graphs: SimpleGraph, SimpleDiGraph, nv, edges, src, dst, has_edge, add_edge!, add_vertex!, rem_edge!, inneighbors, outneighbors, degree

makedocs(;
    modules = [WeaklySeparatedCollections],
    pages = [
        "Home" => "index.md"
        "User guide" => "usage.md"
        "References" => "reference.md"
    ],
    sitename = "WeaklySeparatedCollections",
    format = Documenter.HTML(;
        repolink = "https://github.com/MichaelSchloesser/WeaklySeparatedCollections.jl",
        assets = ["assets/favicon.ico"],
        sidebar_sitename = false
    ),
    authors = "Michael Schlößer",
    warnonly = true,
)

deploydocs(; repo = "github.com/MichaelSchloesser/WeaklySeparatedCollections.jl", push_preview = true)
