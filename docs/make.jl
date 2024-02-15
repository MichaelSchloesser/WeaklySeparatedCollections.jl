using Documenter, WeaklySeparatedCollections, WeaklySeparatedCollections.OscarExt, Graphs

DocMeta.setdocmeta!(WeaklySeparatedCollections, :DocTestSetup, :(using WeaklySeparatedCollections, Graphs); recursive=true)

makedocs(;
    modules = [
        WeaklySeparatedCollections, 
        WeaklySeparatedCollections.OscarExt
    ],
    pages = [
        "Home" => "index.md" 
        "User guide" => "usage.md" # TODO split this up
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
