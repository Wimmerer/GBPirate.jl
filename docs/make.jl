using GBPirate
using Documenter

DocMeta.setdocmeta!(GBPirate, :DocTestSetup, :(using GBPirate); recursive=true)

makedocs(;
    modules=[GBPirate],
    authors="Wimmerer <kimmerer@mit.edu> and contributors",
    repo="https://github.com/Wimmerer/GBPirate.jl/blob/{commit}{path}#{line}",
    sitename="GBPirate.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Wimmerer.github.io/GBPirate.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Wimmerer/GBPirate.jl",
    devbranch="main",
)
