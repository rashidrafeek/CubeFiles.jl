using CubeFiles
using Documenter

DocMeta.setdocmeta!(CubeFiles, :DocTestSetup, :(using CubeFiles); recursive=true)

makedocs(;
    modules=[CubeFiles],
    authors="Rashid Rafeek <rashidrafeek@gmail.com> and contributors",
    sitename="CubeFiles.jl",
    format=Documenter.HTML(;
        canonical="https://rashidrafeek.github.io/CubeFiles.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/rashidrafeek/CubeFiles.jl",
    devbranch="main",
)
