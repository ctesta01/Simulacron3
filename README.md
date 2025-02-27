
# `{Simulacron3}` <img src='man/figures/logo.png' style="float:right; height:200px;" align='right' />

The purpose of the `{Simulacron3}` package is to provide easy-to-use
boilerplate functionality for simple simulation studies. The most
common, archetypal example of a usecase would be comparing the
performance of multiple estimators as the sample size of training data
increases.

A fundamental thesis of this package is that many simulation studies (of
the statistical performance of estimators) follow the following
workflow:

![](man/figures/DiagrammeR%20diagram-1.png)

``` r
library(Simulacron3)
# Example Usage
# Define a data generating process
dgp <- function(n) data.frame(x = rnorm(n), y = rnorm(n))

# Define some estimators
estimators <- list(
  mean_estimator = function(data) mean(data$x),
  var_estimator = function(data) var(data$x)
)

# Define a summary statistics function
summary_func <- function(iter = NULL, est_results, data = NULL) {
  data.frame(
    mean_est = est_results$mean_estimator,
    var_est = est_results$var_estimator
  )
}

# Create a simulation object
sim <- Simulation$new()

# Set up the simulation
sim$set_dgp(dgp)
sim$set_estimators(estimators)
sim$set_config(list(replications = 500, sample_size = 50))
sim$set_summary_stats(summary_func)

# Run the simulation
sim$run()
```

    ## Running simulation...

``` r
# Retrieve results
results <- sim$get_results()
head(results)
```

    ##       mean_est   var_est
    ## 1 -0.002687212 0.8894159
    ## 2  0.069246104 1.0495441
    ## 3  0.032473984 1.1679176
    ## 4  0.128928438 1.2523796
    ## 5 -0.170736066 1.1980035
    ## 6  0.118114638 1.2049654

## Other Related Works

`{Simulacron3}` is one of many attempts to standardize the workflow of
running simulations. A lot of inspiration was taken from:

- [simChef](https://github.com/Yu-Group/simChef)
- [SimEngine](https://avi-kenny.github.io/SimEngine/)
- [simcausal](https://www.jstatsoft.org/article/view/v081i02)
- [simulator](https://github.com/jacobbien/simulator)
