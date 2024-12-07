% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_install_dir.R
\name{get_condathis_path}
\alias{get_condathis_path}
\title{Retrieve System-Dependent Data Path for condathis}
\usage{
get_condathis_path()
}
\value{
A character string representing the path to the user data directory for \code{condathis}.
}
\description{
Determines the appropriate user data directory for the \code{condathis} package based on the operating system. On macOS, it avoids using paths with spaces due to issues with \verb{micromamba run} failing when there are spaces in the path.
}
\details{
This function uses the \code{rappdirs} package to determine the user data directory.
On macOS, it specifies \code{os = "unix"} to avoid paths like \verb{~/Library/Application Support/condathis}, which contain spaces.
}
\keyword{internal}
