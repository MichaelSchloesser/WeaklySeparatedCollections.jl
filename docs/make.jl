using Documenter, WeaklySeparatedCollections

makedocs(;
    modules = [WeaklySeparatedCollections],
    pages = [
        "Installation" => "index.md"
        "User guide" => "usage.md"
    ],
    sitename = "WeaklySeparatedCollections.jl",
    format = Documenter.HTML(;
        repolink = "https://github.com/MichaelSchloesser/WeaklySeparatedCollections.jl",
        # assets = ["assets/favicon.ico"],
    ),
    authors = "Michael Schlößer",
    warnonly = true,
)

deploydocs(; repo = "github.com/MichaelSchloesser/WeaklySeparatedCollections.jl", push_preview = true)
