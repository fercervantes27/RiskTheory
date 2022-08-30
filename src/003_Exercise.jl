### Exercise 1.7

# Consider a portfolio of 1-year term life insurance independent policies
# from the file LIFEinsurance.csv that specifies age and insured amount for
# each policy, with the additional benefit of twice the insured amount in case
# of accidental death, assuming that 1 out of 10 deaths is accidental
# (regardless of the age). Use the mortality table in the file mortality.csv
# and do the following:

## a) Make use of the Julia packages CSV.jl and DataFrames.jl to read the data,
##    and the package Plots.jl for the histogram.

using CSV, DataFrames, Distributions, Statistics, Plots

begin
    mort = DataFrame(CSV.File("mortality.csv"))
    display(mort) # check what happens if `println(mort)` is used instead of `display(mort)`
    k = 1/10
    q = Dict(mort.AGE .=> mort.qx); # Dictionary: a function that maps age -> qx
    policy = DataFrame(CSV.File("LIFEinsurance.csv"))
    display(policy)
end


## b) Calculate the theoretical mean and variance for total claims.

begin
    ES = 0.0
    VS = 0.0
    n = nrow(policy) # or: length(policy.AGE)
    for j ∈ 1:n # or: for j in 1:n 
        qj = q[policy.AGE[j]]
        cj = policy.INSAMOUNT[j]
        ES += (1 + k)*cj*qj # Same as ES = ES + (1 + k)*cj*qj
        VS += qj*(1-qj)*((1+k)*cj)^2 + qj*(1-k)k*(cj^2)
    end
    println("E(S) = ", ES)
    println("V(S) = ", VS)
end


## c) Through 1 million simulations of the portfolio in Julia, estimate mean
##    and variance of total claims, and compare to the theoretical values
##    obtained in the previous item.

# First we check time with less simulations: m = 10,000

@time begin # The macro @time measures time execution (may change each time is called)
    m = 10_000
    S = zeros(m) 
    for j ∈ 1:n
        Accident = rand(Bernoulli(k), m) # vector of size m        
        Death = rand(Bernoulli(q[policy.AGE[j]]), m) # vector of size m
        S = S .+ (policy.INSAMOUNT[j] .* Death .* (1 .+ Accident))
    end
    println("sim M(S) = ", median(S))
    println("sim E(S) = ", mean(S))
    println("sim V(S) = ", var(S))
end

# 1,000,000 simulations will approx take 100x more time

@time begin
    m = 1_000_000
    S = zeros(m)
    for j ∈ 1:n
        Accident = rand(Bernoulli(k), m) # vector of size m
        Death = rand(Bernoulli(q[policy.AGE[j]]), m) # vector of size m
        S = S .+ (policy.INSAMOUNT[j] .* Death .* (1 .+ Accident))
    end
    println("sim M(S) = ", median(S))
    println("sim E(S) = ", mean(S), "   → E(S) = ", ES)
    println("sim V(S) = ", var(S), "   → V(S) = ", VS)
end


## d) Also from c) estimate a non-parametric Value at Risk (VaR)
##    of level 99.5% for total claims.

begin
    simVaR = quantile(S, 0.995)
    println("sim VaR(0.995) = ", simVaR)
end

# Just as additional comments:

begin
    println("E(S) = ", ES, " ← BEL ≡ Best Estimate of Liabilities")
    println("SCR = VaR(S) - E(S) = ", simVaR - ES, " ← Solvency Capital Requirement")
    println("Worst case scenario = ", 2 * sum(policy.INSAMOUNT), " ← All policyholders die in an accident")
end


## e) Using item b) results, calculate normal approximation of VaR of
## level 99.5% for total claims, and compare to the VaR obtained in item d).

begin
    normalModel = Normal(ES, sqrt(VS))
    normalVaR = quantile(normalModel, 0.995)
    println("Normal VaR = ", normalVaR)
    println("Simulated VaR = ", simVaR)
    underestimation = round(100 * (normalVaR / simVaR - 1), digits = 2)
    println("Normality under estimation = ", underestimation, "%")
end


## f) Graph a histogram of the simulations of total claims from item c) and
##    add to the same graph the approximated normal density.

begin
    histogram(S, label = "simulations of S", color = :yellow, normalize = true, bins = 50)
    xaxis!("s")
    yaxis!("density")
    x = range(100, 700, length = 1000)
    plot!(x, pdf.(Normal(mean(S), √var(S)), x), lw = 3, color = :red, label = "Normal approx")
end
