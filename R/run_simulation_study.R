#' Simulation Study
#'
#' Often we are interested in seeing how estimators perform as we vary the
#' sample size. Additionally, support through `...` is allowed for passing any
#' extra configuration options to the simulation
#'
#' @param sim A \code{Simulacron3::Simulation} object
#' @param sample_sizes Sample sizes (integers) to simulate
#' @param extra_config_changes Any additional config changes that are needed during
#' simulation; should be iterable and of the same length as sample_sizes.
#' the ith extra_config_changes
#' @export
run_simulation_study <- function(sim, sample_sizes, extra_config_changes = NULL) {

  if (! all(c("Simulation", "R6") %in% class(sim))) {
    stop("run_simulation_study() is only designed to run on Simulacron3::Simulation objects.")
  }

  # setup a data frame to store results in across sample sizes
  results <- vector('list', length = length(sample_sizes))

  # run the simulation over a variety of sample sizes
  for (i in 1:length(sample_sizes)) {
    # update the simulation settings
    sim$set_config(c(list(sample_size = sample_sizes[i]), extra_config_changes[[i]]))
    # run the simulation
    sim$run()
    # record the results as the ith element in a list()
    results[[i]] <-
      cbind.data.frame(sample_size = sample_sizes[i], sim$get_results())
      # we make sure to record the sample_size with the simulation results
  }

  # combine our results together into one data.frame (stacking them)
  results <- do.call(rbind, results)
  return(results)
}
