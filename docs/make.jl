using Documenter, WeaklySeparatedCollections, Graphs, Oscar

DocMeta.setdocmeta!(WeaklySeparatedCollections, :DocTestSetup, :(using WeaklySeparatedCollections, Graphs, Oscar); recursive=true)

makedocs(;
    modules = [
        WeaklySeparatedCollections,
        isdefined(Base, :get_extension) ?
        Base.get_extension(WeaklySeparatedCollections, :OscarExt) :
        WeaklySeparatedCollections.OscarExt
    ],
    pages = [
        "Home" => "index.md" 
        "User guide" => "usage.md" # TODO split this up
        # "References" => "reference.md"
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
