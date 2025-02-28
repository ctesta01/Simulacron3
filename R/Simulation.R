#' Simulation R6Class
#'
#' Takes a specification for a data generating process (`dgp`),
#' list of `estimators`, `config`, list of `summary_statistics` to compute, and
#' provides a `get_results` method.
#'
#' The core idea is that a statistical simulation study consists of
#' specifying a repeatable data generating process, some functions (estimators)
#' to run on each generated data sample, and some summary statistics to compute
#' from the simulation results (typically that indicate aspects of the performance
#' of the estimators considered). This is represented by the following pipeline:
#'
#'       dgp
#'       estimators    ->  Simulation$new( ... ) -> sim$run() -> sim$get_results()
#'       config
#'       summary_fns
#'
#' @export
#' @importFrom future.apply future_lapply
#'
#' @field dgp A function that takes a single argument \code{n} for sample size and generates synthetic data.
#' @field estimators A list of estimators that each can be called on the data
#' @field config A list containing at least the number of \code{replications} to
#'   perform, the \code{sample_size} to use, whether or not the simulation
#'   should be \code{quiet}, and whether or not to run in \code{parallel}.
#' @field summary_stats A list of summary statistic functions that can be called on the estimates produced
#' @field results A data.frame of results from running the simulation
#' @field initialize Method to initialize the simulation object (does nothing)
#' @field set_dgp Method to set the data generating process
#' @param dgp_func A data generating process function (of one argument,
#'   \code{n}) that produces a dataset for simulation purposes of the sample
#'   size given.
#' @field set_estimators Method to set the estimators
#' @param estimator_list A list of functions that can be evaluated on the data
#' output from the data generating process \code{self$dgp}.
#' @field set_config Method to set the configuration
#' @param config_list A list of configuration settings for the simulation.
#' The following are used by \code{Simulacron3::Simulation} by default:
#' \code{replications} (integer), \code{sample_size}, \code{quiet}
#' and \code{parallel}.
#' @field get_results Method to retrieve results
#' @field set_summary_stats Method to set summary statistics
#' @param summary_func The summary function to set for the simulation. \code{summary_func} should take
#' as arguments \code{i, est_results, data}.
#'
#' @examples
#' \dontrun{
#' # Example Usage
#' # Define a data generating process
#' dgp <- function(n) data.frame(x = rnorm(n), y = rnorm(n))
#'
#' # Define some estimators
#' estimators <- list(
#'   mean_estimator = function(data) mean(data$x),
#'   var_estimator = function(data) var(data$x)
#' )
#'
#' # Define a summary statistics function
#' summary_func <- function(iter = NULL, est_results, data = NULL) {
#'   data.frame(
#'     mean_est = est_results$mean_estimator,
#'     var_est = est_results$var_estimator
#'   )
#' }
#'
#' # Create a simulation object
#' sim <- Simulation$new()
#'
#' # Set up the simulation
#' sim$set_dgp(dgp)
#' sim$set_estimators(estimators)
#' sim$set_config(list(replications = 500, sample_size = 50))
#' sim$set_summary_stats(summary_func)
#'
#' # Run the simulation
#' sim$run()
#'
#' # Retrieve results
#' results <- sim$get_results()
#' head(results)
#' }
Simulation <- R6::R6Class("Simulation",
  public = list(

    dgp = NULL,
    estimators = NULL,
    config = list(replications = 100, sample_size = 100, quiet = FALSE, parallel = FALSE),
    summary_stats = NULL,
    results = NULL,

    initialize = function() {},

    set_dgp = function(dgp_func) {
      if (!is.function(dgp_func)) {
        stop("dgp must be a function.")
      }
      self$dgp <- dgp_func
    },

    set_estimators = function(estimator_list) {
      if (!is.list(estimator_list) || !all(sapply(estimator_list, is.function))) {
        stop("estimators must be a list of functions.")
      }
      self$estimators <- estimator_list
    },

    set_config = function(config_list) {
      if (!is.list(config_list)) {
        stop("config must be a list.")
      }
      self$config <- modifyList(self$config, config_list)
    },

    set_summary_stats = function(summary_func) {
      if (!is.function(summary_func)) {
        stop("summary_stats must be a function.")
      }
      self$summary_stats <- summary_func
    },

    #' @field run Method to run the simulation
    run = function() {
      if (is.null(self$dgp) || is.null(self$estimators) || is.null(self$summary_stats)) {
        stop("Please set dgp, estimators, and summary_stats before running the simulation.")
      }

      if (! self$config$quiet) {
        message("Running simulation...")
      }

      replications <- self$config$replications
      sample_size <- self$config$sample_size
      sim_results <- vector("list", replications)

      if (! isTRUE(self$config$parallel)) {
        for (i in seq_len(replications)) {
          data <- self$dgp(sample_size)
          est_results <- lapply(self$estimators, function(estimator) estimator(data))
          sim_results[[i]] <- self$summary_stats(i, est_results, data)
        }
      } else if (isTRUE(self$config$parallel)) {
        sim_results <- future_lapply(seq_len(replications), function(i) {
          data <- self$dgp(sample_size)
          est_results <- lapply(self$estimators, function(estimator) estimator(data))
          return(self$summary_stats(i, est_results, data))
        }, future.seed = TRUE)
      }

      self$results <- do.call(rbind, sim_results)
      return(invisible(NULL))
    },

    get_results = function() {
      if (is.null(self$results)) {
        stop("No results available. Run the simulation first.")
      }
      return(self$results)
    }
  )
)
