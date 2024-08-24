#=

    Install some external packages needed for the Risk Theory course using a loop. 
    They can also be installed one by one from the package mode in the terminal 
    using the `add` command followed by the package name.

=#

using Pkg # calling the Julia installer package

begin
    package = ["QuadGK", "HCubature", "Optim",
               "SpecialFunctions", "LaTeXStrings", 
               "Distributions", "StatsBase",
               "Plots", "StatsPlots", "CSV", "DataFrames"
    ]
    for p in package
        println("*** Installing package: ", p)
        Pkg.add(p)
    end
    println("*** End of list of packages.")
end
