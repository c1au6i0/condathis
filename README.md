
# condathis

<!-- badges: start -->
<!-- badges: end -->

## `condathis` R package

Run any CLI tool that is available through conda environments.

### Get started

``` r
remotes::install_github("luciorq/condathis")
```

### Try it

#### General Command line tool

``` r
library(condathis)
create_env("python=3.8")
run("python3", "-c", "import os; print(os.getcwd())")
```

#### Bioinformatics example

``` r
create_env("samtools", env_name = "samtools-env")
run("samtools", "view", "--help", env_name = "samtools-env")
```

#### Example with Singularity containers

Singularity container backend is especially suited for HPC environments.

``` r
bam_file <- system.file("extdata", "example.bam", package = "condathis")
create_env("samtools", env_name = "samtools-env", method = "singularity")
run("samtools", "view", bam_file, env_name = "samtools-env", method = "singularity")
```

---

`condathis` is a powerful R package designed to simplify the execution of command line tools within isolated conda environments. Built with efficiency and flexibility in mind, `condathis` seamlessly integrates the world of conda environments with the versatility of R programming.

With Condathis, you can effortlessly create and manage isolated conda environments directly from your R scripts. These environments provide a controlled and reproducible setting where you can install and run various command line tools without worrying about conflicts or dependencies. Whether you need to execute bioinformatics pipelines, data processing tasks, or any other command line operation, `condathis` ensures a hassle-free experience.

## Key Features of `condathis`

Conda Environment Management: `condathis` allows you to easily create conda environments, empowering you to work with different tool configurations for each step of analysis or project.
This ensures that your workflows remain isolated and reproducible.

Command Line Tool Execution: The package offers a seamless interface for executing command line tools directly from your R code.
With a simple function call, you can run any command line tool installed within any conda environment, enabling you to leverage the vast ecosystem of command line tools in your R workflows.

Dependency Resolution: `condathis` automatically handles the resolution of dependencies required by the command line tools you want to execute. It ensures that the necessary libraries, packages, and binaries are properly installed within the isolated conda environment, eliminating the need for manual setup and ensuring smooth execution.

`condathis` brings intuitive API and efficient conda environment management, you can streamline your data analysis workflows, enhance reproducibility, and explore a vast range of command line tools — all within the familiar R environment.

## Motivation

Traditionally, [Conda Environments][conda-env-ref] have been designed to solve a problem related to Python Programming and specially tailored for interactive usage.

With `condathis` we want to leverage another great functionality of Conda environments that is running CLI software in isolated environments, without affecting (and also not being affected by) the main R environment.

This is especially relevant to the Bioinformatics and Computational Biology fields where most of the preprocessing of raw data files is made using Linux/Unix command line tools that benefit from running on isolation.
Where in the later step data is imported into R for interactive analysis.

The focus of this package is to support CLI tools installed inside Conda environments.

Providing an API to call those tools in isolation from the main R process.

Despite the name, the main interface we use to access software installed in Conda environments is actually [micromamba][micromamba-ref], a lightweight and open-source reimplementation of the Conda package manager.

Since this package **is not intended to solve the problem of running Python code**,
`micromamba` has a huge advantage, since it is lighter and does not come with a default version of Python.
If you intend to run Python code chunks or scripts side by side with R code in activate Conda environments,
check [reticulate][reticulate-ref] or [basilisk][basilisk-ref], as they were built to provide this exact solution.

This tool can even be used for running R scripts in separate environments.

## Known issues

Special characters in CLI commands are interpreted as literals and not expanded.

 - It is not supported the use of output redirections in commands, e.g. "|" or ">".
 - File paths should not use special characters for relative paths, e.g. "~", ".", "..".

---

[conda-env-ref]: https://conda.io/projects/conda/en/latest/user-guide/getting-started.html
[micromamba-ref]: https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html
[reticulate-ref]: https://rstudio.github.io/reticulate/
[basilisk-ref]: https://www.bioconductor.org/packages/release/bioc/html/basilisk.html
