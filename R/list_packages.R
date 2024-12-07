#' List Packages Installed Inside Environment
#' @inheritParams run
#' @return A tibble containing all the packages installed in the specified environment,
#' with the following columns:
#' \describe{
#'   \item{base_url}{The base URL of the package source.}
#'   \item{build_number}{The build number of the package.}
#'   \item{build_string}{The build string describing the package build details.}
#'   \item{channel}{The channel from which the package was installed.}
#'   \item{dist_name}{The distribution name of the package.}
#'   \item{name}{The name of the package.}
#'   \item{platform}{The platform for which the package is built.}
#'   \item{version}{The version of the package.}
#' }
#' @examples
#' \dontrun{
#' # Creates a Conda environment with the CLI `fastqc`
#' condathis::create_env(packages = "fastqc",
#'                       env_name = "fastqc_env"
#'                       )
#' # Lists the packages in env `fastqc_env`
#' dat <- condathis::list_packages("fastqc_env")
#' dim(dat)
#' #> [1] 34  8
#' }
#' @export
list_packages <- function(env_name = "condathis-env", verbose = "silent") {
  px_res <- native_cmd(
    conda_cmd = "list",
    conda_args = c(
      "-n",
      env_name,
      "--quiet",
      "--json"
    ),
    verbose = verbose
  )
  if (isTRUE(px_res$status == 0)) {
    pkgs_df <- jsonlite::fromJSON(px_res$stdout)
    pkgs_df <- tibble::as_tibble(pkgs_df)
    if (isTRUE(length(pkgs_df) == 0)) {
      pkgs_df <- tibble::tibble(
        "base_url" = character(0L),
        "build_number" = integer(0L),
        "build_string" = character(0L),
        "channel" = character(0L),
        "dist_name" = character(0L),
        "name" = character(0L),
        "platform" = character(0L),
        "version" = character(0L)
      )
    }
  }
  return(pkgs_df)
}
