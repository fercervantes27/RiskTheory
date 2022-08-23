### Exercises 1.3 and 1.4

using Distributions, Statistics, Plots 


## 1.3 Consider a random vector (X,Y) with joint probability density:
##          f(x,y) = exp(-y) * (0 < x < y)
##     Calculate level 0.995 VaR(X), VaR(Y), VaR(X+Y), and VaR(X)+VaR(Y).

# Define marginal distributions 

X = Exponential(1)
Y = Gamma(2, 1)
α = 0.995

# VaR(X)

VaR_X = quantile(X, α) # theoretical VaR(X)
-log(1-α) # theoretical VaR(X)
cdf(X, VaR_X) # checking that P(X ≤ VaR_X) = α
quantile(rand(X, 1_000_000), α) # approximate VaR(X) by simulation of X

# VaR(Y)

VaR_Y = quantile(Y, α) # theoretical VaR(Y)
cdf(Y, VaR_Y) # checking that P(Y ≤ VaR_Y) = α
1 - exp(-VaR_Y)*(1 + VaR_Y) # checking that P(Y ≤ VaR_Y) = α
quantile(rand(Y, 1_000_000), α) # approximate VaR(Y) by simulation of Y


# (X,Y) simulators

function simXYver1(n)
    # n = number of simulations of (X,Y)
    rX = rand(X, n)
    rY = rand(Exponential(1), n) .+ rX # conditional simulations Y|X=x
    return hcat(rX, rY)
end

function simXYver2(n)
    # n = number of simulations of (X,Y)
    rY = rand(Y, n)
    rX = rY .* rand(Uniform(0, 1), n) # conditional simulations of X|Y=y  
    return hcat(rX, rY)
end

# testing simulators

sample1 = simXYver1(10_000)
sample2 = simXYver2(10_000)

begin # scatterplots
  p1 = scatter(sample1[1:3000, 1], sample1[1:3000, 2], xlabel = "X", ylabel = "Y", legend = false)
  p2 = scatter(sample2[1:3000, 1], sample2[1:3000, 2], xlabel = "X", ylabel = "Y", legend = false)
  plot(p1, p2, layout = (1, 2), size = (600, 300))
end

begin # theoretical versus estimated marginal X
    p3 = histogram(sample1[:, 1], normalize = true, color = :gray, label = "simulated", xlabel = "X", ylabel = "density")
    xx1 = range(minimum(sample1[:, 1]), maximum(sample1[:, 1]), length = 1_000)
    plot!(xx1, pdf.(X, xx1), lw = 3, color = :red, label = "theoretical")
    p4 = histogram(sample2[:, 1], normalize = true, color = :gray, label = "simulated", xlabel = "X", ylabel = "density")
    xx2 = range(minimum(sample2[:, 1]), maximum(sample2[:, 1]), length = 1_000)
    plot!(xx2, pdf.(X, xx2), lw = 3, color = :red, label = "theoretical")
    plot(p3, p4, layout = (1, 2), size = (600, 300))
end

begin # theoretical versus estimated marginal Y
    p5 = histogram(sample1[:, 2], normalize = true, color = :gray, label = "simulated", xlabel = "Y", ylabel = "density")
    yy1 = range(minimum(sample1[:, 2]), maximum(sample1[:, 2]), length = 1_000)
    plot!(yy1, pdf.(Y, yy1), lw = 3, color = :red, label = "theoretical")
    p6 = histogram(sample2[:, 2], normalize = true, color = :gray, label = "simulated", xlabel = "Y", ylabel = "density")
    yy2 = range(minimum(sample2[:, 2]), maximum(sample2[:, 2]), length = 1_000)
    plot!(yy2, pdf.(Y, yy2), lw = 3, color = :red, label = "theoretical")
    plot(p5, p6, layout = (1, 2), size = (600, 300))
end

# VaR(X + Y) ≠ VaR(X) + VaR(Y)

sampleXY = simXYver1(1_000_000)
S = sampleXY[:, 1] .+ sampleXY[:, 2] # S = X + Y
VaR_S = quantile(S, α)
VaR_X + VaR_Y
begin
    histogram(S, normalize = true, color = :black, label = "S = X + Y")
    xaxis!("S"); yaxis!("density")
    vline!([VaR_S], color = :red, lw = 2, label = "VaR_S($α)")
end


## 1.4 The same as in 1.3, but considering X and Y independent.

# VaR(X) and VaR(Y) are exactly the same

begin
    rX = rand(X, 1_000_000)
    rY = rand(Y, 1_000_000)
    scatter(rX[1:3000], rY[1:3000], legend = false, xlabel = "X", ylabel = "Y", title = "X and Y independent")
end

Sindep = rX .+ rY
VaR_Sindep = quantile(Sindep, α);
VaR_Sindep, VaR_S, VaR_X + VaR_Y

begin
    histogram(Sindep, normalize = true, color = :black, label = "S = X + Y")
    xaxis!("S = X + Y, with X and Y independent"); yaxis!("density")
    vline!([VaR_Sindep], color = :red, lw = 2, label = "VaR_S($α)")
end
