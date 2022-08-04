using Sedlex
using Documenter

DocMeta.setdocmeta!(Sedlex, :DocTestSetup, :(using Sedlex); recursive=true)

makedocs(;
    modules=[Sedlex],
    authors="thautwarm <twshere@outlook.com> and contributors",
    repo="https://github.com/thautwarm/Sedlex.jl/blob/{commit}{path}#{line}",
    sitename="Sedlex.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://thautwarm.github.io/Sedlex.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/thautwarm/Sedlex.jl",
    devbranch="main",
)
