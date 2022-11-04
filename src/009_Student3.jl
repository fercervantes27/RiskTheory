### Exercise 4.3: The 3-parameter t-Student distribution

println("Warning: `Student3` requires the package `Distributions` previously installed")

using Distributions;

"""
    Student3(μ::Float64, λ::Float64, δ::Float64)

3-paramenter Student Distribution with location parameter `μ`, precision parameter `λ > 0`,
and `δ > 0` degrees of freedom. If `Z` is a standard t-Student distribution with single
parameter `δ` then `T = μ + Z / √λ` is a `Student3(μ, λ, δ)` where:

- `T.name` = name of the probability distribution
- `T.μ` =  value of the location parameter
- `T.λ` =  value of the precision parameter
- `T.δ` =  value of the degrees of freedom parameter (greek letter δ, not latin v)
- `T.param` = tuple of all the parameters
- `T.pdf(x)` =  probability density function evaluated at `x`
- `T.cdf(x)` = cumulative distribution function evaluated at `x`
- `T.qf(u)` = quantile function evaluated at `0 ≤ u ≤ 1`
- `T.sim(n)` = vector with a simulated sample of size `n`
- `T.mean` = theoretical mean, returns `NaN` if it does not exist
- `T.med` = theoretical median
- `T.var` = theoretical variance, returns `NaN` if it does not exist

> Required previously installed packages: `Distributions` and `SpecialFunctions`

## Examples
```
T = Student3(-2.1, 3.5, 4.2)
keys(T)
T.name
T.med # theoretical median
T.cdf(T.med) # checking the median
T.qf(0.5) # checking the theoretical median quantile
tsim = T.sim(1_000); # simulate sample of size 1_000
median(tsim) # sample median
mean(tsim) # sample mean
T.mean # theoretical mean
var(tsim) # sample variance
T.var # theoretical variance
```
"""
function Student3(μ::Float64, λ::Float64, δ::Float64)
    if λ ≤ 0.0
        error("parameter λ must be positive")
    elseif δ ≤ 0.0
        error("parameter δ must be positive")
    else
        Z = TDist(δ)
        dSt3(t) = √λ * pdf(Z, √λ * (t - μ)) # pdf
        pSt3(t) = cdf(Z, √λ * (t - μ)) # cdf
        qSt3(u) = μ + quantile(Z, u) / √λ # quantiles
        rSt3(n) = qSt3.(rand(n)) # random generator
        mediana = μ
        media = δ > 1.0 ? μ : NaN
        varianza = δ > 2.0 ? δ / ((δ-2)*λ) : NaN
        return (name = "Student3(μ = $μ, λ = $λ, δ = $δ)",
            μ = μ, λ = λ, δ = δ, param = (μ, λ, δ),
            pdf = dSt3, cdf = pSt3, qf = qSt3, sim = rSt3,
            mean = media, med = mediana, var = varianza
        )
    end
end
