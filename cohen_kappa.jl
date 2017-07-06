# BUG: The current result does not align with R's psych package
using Distributions



function kappa(x, α = 0.05)
    tot = sum(x)
    x = x ./ tot        # convert to probabilities
    rs = sum(x, 2)      # row sum
    cs = sum(x, 1)      # column sum

    prob = rs * cs
    po = trace(x)
    pc = trace(prob)
    kappa = (po - pc)/(1 - pc)

    var_kappa = (1 / (tot*(1-pc)^4)) * (trace(x * (I * (1-pc) - (rs .+ (cs))*(1-po))^2 ) + (1-po)^2 * (sum(x * (cs .+ (rs))^2) - trace(x * (cs .+ (rs))^2))  -(po*pc - 2*pc +po)^2)

    lower_ci = kappa + quantile(Normal(0, 1), (α/2)) * sqrt(var_kappa)
    upper_ci = kappa - quantile(Normal(0, 1), (α/2)) * sqrt(var_kappa)

    return (kappa, var_kappa, lower_ci, upper_ci)
end


# kappa(cm1.matrix)

# a = cm1.matrix
