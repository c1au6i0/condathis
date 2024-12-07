#' Run a Binary from a Conda Environment Without Emvironment Activation
#'
#' Executes a binary command from a specified Conda environment without activating the environment or using its environment variables. This function temporarily clears Conda and Mamba-related environment variables to prevent interference, ensuring that the command runs in a clean environment.
#' Usually this is not what the user wants, check [run()] for the stable function to use.
#'
#' @inheritParams run
#'
#' @return An invisible list containing the results from `processx::run()`, including standard output and error.
#'
#' @examples
#' \dontrun{
#' # Example assumes that 'my_env' exists and contains 'python'
#' # Run 'python' with a script in 'my_env' environment
#' condathis::run_bin("python", "script.py", env_name = "my_env", verbose = "silent")
#'
#' # Run 'ls' command with additional arguments
#' condathis::run_bin("ls", "-la", env_name = "my_env")
#' }
#'
#' @export
run_bin <- function(
    cmd,
    ...,
    env_name = "condathis-env",
    verbose = "silent",
    error = c("cancel", "continue"),
    stdout = "|",
    stderr = "|") {
  error <- rlang::arg_match(error)
  if (isTRUE(identical(error, "cancel"))) {
    error_var <- TRUE
  } else {
    error_var <- FALSE
  }

  verbose_list <- parse_strategy_verbose(strategy = verbose)
  verbose_cmd <- verbose_list$cmd
  verbose_output <- verbose_list$output

  env_dir <- get_env_dir(env_name = env_name)
  cmd_path <- fs::path(env_dir, "bin", cmd)

  withr::local_envvar(
    .new = list(
      CONDA_SHLVL = 0,
      MAMBA_SHLVL = 0,
      CONDA_ENVS_PATH = "",
      CONDA_ROOT_PREFIX = "",
      CONDA_PREFIX = "",
      MAMBA_ENVS_PATH = "",
      MAMBA_ROOT_PREFIX = "",
      MAMBA_PREFIX = "",
      CONDARC = "",
      MAMBARC = "",
      CONDA_PROMPT_MODIFIER = "",
      MAMBA_PROMPT_MODIFIER = "",
      CONDA_DEFAULT_ENV = "",
      MAMBA_DEFAULT_ENV = "",
      R_HOME = ""
    )
  )
  px_res <- processx::run(
    command = fs::path_real(cmd_path),
    args = c(
      ...
    ),
    spinner = TRUE,
    echo_cmd = verbose_cmd,
    echo = verbose_output,
    stdout = stdout,
    stderr = stderr,
    error_on_status = error_var
  )
  return(invisible(px_res))
}
