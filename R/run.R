#' Run Command-Line Tools in a Conda Environment
#'
#' This function allows the execution of command-line tools within a specified Conda environment.
#' It runs the provided command in the designated Conda environment using the Micromamba binaries managed by the `condathis` package.
#'
#' @param cmd Character. The main command to be executed in the Conda environment.
#'
#' @param ... Additional arguments to be passed to the command. These arguments will be passed directly to the command executed in the Conda environment.
#'   File paths should not contain special characters or spaces.
#'
#' @param env_name Character. The name of the Conda environment where the tool will be run. Defaults to `"condathis-env"`.
#'   If the specified environment does not exist, it will be created automatically using `create_env()`.
#'
#' @param method Character string. The method to use for running the command. Options are `"native"`, `"auto"`. Defaults to `"native"`.
#'   This argument is **soft deprecated** as changing it don't really do anything.
#'
#' @param verbose Character string specifying the verbosity level of the function's output. Acceptable values are:
#'
#' - **"silent"**: Suppress all output from internal command-line tools. Equivalent to `FALSE`.
#' - **"cmd"**: Print the internal command(s) passed to the command-line tool.
#' - **"output"**: Print the standard output and error from the command-line tool to the screen. Note that the order of the standard output and error lines may not be correct, as standard output is typically buffered. If the standard output and/or error is redirected to a file or they are ignored, they will not be echoed.
#' - **"full"**: Print both the internal command(s) (`"cmd"`) and their standard output and error (`"output"`). Equivalent to `TRUE`.
#' Logical values `FALSE` and `TRUE` are also accepted for backward compatibility but are *soft-deprecated*. Please use `"silent"` and `"full"` respectively instead.
#'
#' @param error Character string. How to handle errors. Options are `"cancel"` or `"continue"`. Defaults to `"cancel"`.
#'
#' @param stdout Default: "|" keep stdout to the R object
#'   returned by `run()`.
#'   A character string can be used to define a file path to be used as standard output. e.g: "output.txt".
#'
#' @param stderr Default: "|" keep stderr to the R object
#'   returned by `run()`.
#'   A character string can be used to define a file path to be used as standard error. e.g: "error.txt".
#'
#' @return An object of class `list` representing the result of the command execution.
#'   Contains information about the standard output, standard error, and exit status of the command.
#'
#' @details
#' The `run()` function provides a flexible way to execute command-line tools within Conda environments.
#' This is particularly useful for reproducible research and ensuring that specific versions of tools are used.
#'
#' @examples
#' \dontrun{
#' ## Run a simple command in the default Conda environment
#' run("ls", "-l")
#'
#' ## Run a command in a specific Conda environment
#' run("python", "script.py", env_name = "my-python-env")
#'
#' ## Run a command with additional arguments
#' run("my-command", "--arg1", "--arg2=value", env_name = "my-python-env")
#' }
#' @seealso
#' \code{\link{install_micromamba}}, \code{\link{create_env}}
#'
#' @export
run <- function(cmd,
                ...,
                env_name = "condathis-env",
                method = c(
                  "native",
                  "auto"
                ),
                verbose = c(
                  "silent", "cmd", "output", "full", FALSE, TRUE
                ),
                error = c("cancel", "continue"),
                stdout = "|",
                stderr = "|") {
  rlang::check_required(cmd)

  if (is.null(cmd)) {
    cli::cli_abort(
      message = c(
        `x` = "{.field cmd} need to be a {.code character} string."
      ),
      class = "condathis_run_null_cmd"
    )
  }

  error <- rlang::arg_match(error)
  method <- rlang::arg_match(method)
  # verbose <- rlang::arg_match(verbose)
  invisible_res <- parse_strategy_verbose(strategy = verbose[1])

  method_to_use <- method[1]

  if (isTRUE(method_to_use %in% c("native", "auto"))) {
    px_res <- run_internal_native(
      cmd = cmd,
      ...,
      env_name = env_name,
      verbose = verbose,
      error = error,
      stdout = stdout,
      stderr = stderr
    )
  }
  return(invisible(px_res))
}

#' Run Command Using Native Method
#'
#' Internal function to run a command in a Conda environment using the native method.
#'
#' @inheritParams run
run_internal_native <- function(cmd,
                                ...,
                                env_name = "condathis-env",
                                verbose = FALSE,
                                error = c("cancel", "continue"),
                                stdout = "|",
                                stderr = "|") {
  if (isTRUE(base::Sys.info()["sysname"] == "Windows")) {
    micromamba_bat_path <- fs::path(get_install_dir(), "condabin", "micromamba", ext = "bat")
    if (isFALSE(fs::file_exists(micromamba_bat_path))) {
      catch_res <- rlang::catch_cnd(
        expr = {
          native_cmd(
            conda_cmd = "run",
            conda_args = c("-n", "condathis-env"),
            cmd = "dir", verbose = FALSE, stdout = NULL
          )
        }
      )
      mamba_bat_path <- fs::path(get_install_dir(), "condabin", "mamba", ext = "bat")
      if (isTRUE(fs::file_exists(mamba_bat_path)) &&
        isFALSE(fs::file_exists(micromamba_bat_path))) {
        fs::file_copy(mamba_bat_path, micromamba_bat_path, overwrite = TRUE)
      }
    }
  }
  px_res <- native_cmd(
    conda_cmd = "run",
    conda_args = c(
      "-n",
      env_name
    ),
    cmd = cmd,
    ...,
    verbose = verbose,
    error = error,
    stdout = stdout,
    stderr = stderr
  )
  return(invisible(px_res))
}
