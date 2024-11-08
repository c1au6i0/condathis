
<!-- README.md is generated from README.Rmd. Please edit that file -->

# condathis

<!-- badges: start -->

[![R-CMD-check](https://github.com/luciorq/condathis/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/luciorq/condathis/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Run system command line inteface (CLI) tools in a **reproducible** and
**isolated** environment **within R**.

## Get started

Install package from
[R-Universe](https://luciorq.r-universe.dev/condathis):

``` r
install.packages("condathis", repos = c("https://luciorq.r-universe.dev", getOption("repos")))
```

### Installing the development version

``` r
remotes::install_github("luciorq/condathis")
```

## Motivation

One of the main disadvantages of calling CLI tools within R is that they
are system-specific. This affects the replicability of your code, making
it dependent on the system it’s run on. Additionally, using multiple CLI
tools increases the likelihood of encountering version conflicts, where
different tools require different versions of the same library.
Therefore, relying on system-specific tools within R is generally not
recommended.

The package **`{condathis}`lets you call CLI tools within R while
keeping things reproducible and isolated.**

This means you can use R alongside other tools without the draw back of
of having system specific code. It opens up the possibility of creating
code and pipelines in R integrating multiple CLI tools. This is
especially useful for bioinformatics and all other fields that relies on
many software tools for conducting complex analysis.

## Reproducibility: An Example

### The issue with `system`

Suppose you’re writing a pipeline or just a script for some analysis,
and you want to use
[`fastqc`](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) —
a program to check the quality of FASTQ files. You’ve installed fastqc
and use system2 to run it.

The `fastqc` command synopsis is
`fastqc <path-to-fastq-file> -o <output-dir>`. The output directory is
where fastqc saves its quality control reports.

``` r
fastq_file <- system.file("extdata", "sample1_L001_R1_001.fastq.gz", package = "condathis")

temp_out_dir <- tempdir()
system2(command = "fastqc", args = c(fastq_file,  "-o", temp_out_dir))
```

The `fastqc` program generates several output files, including a zip
file that is 424KB in size.

To get information about one of the output file, we can use:

``` r
library(fs)
library(dplyr)

file_info(fs::dir_ls(temp_out_dir, glob = "*zip")) |> 
  mutate(file_name = path_file(path) ) |> 
  select(file_name, size)
```

Now, let’s consider the scenario where you share your code with someone
else or revisit it yourself after a year. There’s no guarantee the code
will run because it relies on a specific CLI tool installed on the
system. In the worst case, it might run without throwing any errors but
produce different results, so you might not even realize that.

The exact same code run on the same system but with an updated version
of `fastqc` (0.12.1 instead of 0.11.2) generates a different file, and
its size is different as well.

    #> # A tibble: 1 × 2
    #>   file_name                             size
    #>   <chr>                          <fs::bytes>
    #> 1 sample1_L001_R1_001_fastqc.zip        424K

    #> # A tibble: 1 × 2
    #>   file_name                             size
    #>   <chr>                          <fs::bytes>
    #> 1 sample1_L001_R1_001_fastqc.zip        446K

This discrepancy limits the workflow, pipeline, and scripts to using
only R packages!

What can we do about it? We can use `{condathis)`!

The package **`{condathis}`** ensures that the code you share and the
results from running `fastqc` will be **consistent across different
systems and over time**!

### The solution with `{condathis}`

We would first create an isolated environment containig a specific
version of package `fastqc` (0.12.0). The command automatically manages
all the library dependencies of `fastqc`, making sure that they are
compatible with the specific operating system.

``` r
condathis::create_env(packages = "fastqc==0.12.1", env_name = "fastqc_env")
```

Then we run the command inside the enviroment just create with that
specific version of fastqc

The `out` object contains info regarding the exit status, standard
error, standard output and timeout if any

``` r
out
#> $status
#> [1] 0
#> 
#> $stdout
#> [1] "application/gzip\nAnalysis complete for sample1_L001_R1_001.fastq.gz\n"
#> 
#> $stderr
#> [1] "Started analysis of sample1_L001_R1_001.fastq.gz\nApprox 90% complete for sample1_L001_R1_001.fastq.gz\n"
#> 
#> $timeout
#> [1] FALSE
```

In the our temp dir, `fastqc`generated the output files as expected.

``` r
fs::dir_ls(temp_out_dir_2)
#> /var/folders/bp/fpwcfq1563l21rz5gdcsfcsw0000gn/T/RtmpSxHysq/libloc_220_e600d766ecff9728.rds
#> /var/folders/bp/fpwcfq1563l21rz5gdcsfcsw0000gn/T/RtmpSxHysq/libloc_253_f6724fe3a7174438.rds
#> /var/folders/bp/fpwcfq1563l21rz5gdcsfcsw0000gn/T/RtmpSxHysq/libloc_263_425eb536d80dd010.rds
#> /var/folders/bp/fpwcfq1563l21rz5gdcsfcsw0000gn/T/RtmpSxHysq/sample1_L001_R1_001_fastqc.html
#> /var/folders/bp/fpwcfq1563l21rz5gdcsfcsw0000gn/T/RtmpSxHysq/sample1_L001_R1_001_fastqc.zip
```

The code that we created with `{condathis}` **use a system CLI tool but
is reproducible**.

## Isolation: an example

Another key feature of `{condathis}` is the ability to run CLI tools in
**independent, isolated environments**. This allows you to run packages
within R that would have conflicting dependencies. This makes it
possible for `{condathis}` to run two versions of the same CLI tool
simultaneously!

For example, the system’s `curl` is of a specific version:

``` r
libcurlVersion()
#> [1] "8.4.0"
#> attr(,"ssl_version")
#> [1] "SecureTransport (LibreSSL/3.3.6)"
#> attr(,"libssh_version")
#> [1] ""
#> attr(,"protocols")
#>  [1] "dict"    "file"    "ftp"     "ftps"    "gopher"  "gophers" "http"   
#>  [8] "https"   "imap"    "imaps"   "ldap"    "ldaps"   "mqtt"    "pop3"   
#> [15] "pop3s"   "rtsp"    "smb"     "smbs"    "smtp"    "smtps"   "telnet" 
#> [22] "tftp"
```

However, we can choose to use a different version of `curl` run in a
different environment. Here, for example, we are installing a different
version of curl in a separate environment, and checking the version of
the newly installed `curl`.

``` r
condathis::create_env(packages = "curl==8.10.1", env_name = "curl_env")

out <- condathis::run("curl", "--version", 
               env_name = "curl_env" # environment
               )

cat(out$stdout)
#> curl 8.10.1 (x86_64-apple-darwin13.4.0) libcurl/8.10.1 OpenSSL/3.3.2 (SecureTransport) zlib/1.3.1 zstd/1.5.6 libssh2/1.11.0 nghttp2/1.64.0
#> Release-Date: 2024-09-18
#> Protocols: dict file ftp ftps gopher gophers http https imap imaps ipfs ipns mqtt pop3 pop3s rtsp scp sftp smb smbs smtp smtps telnet tftp ws wss
#> Features: alt-svc AsynchDNS GSS-API HSTS HTTP2 HTTPS-proxy IPv6 Kerberos Largefile libz MultiSSL NTLM SPNEGO SSL threadsafe TLS-SRP UnixSockets zstd
```

This isolation feature of {condathis} allows not only running different
versions of the same CLI tools but also different tools that have
**incompatible dependencies**. One common example is CLI tools that rely
on different versions of Python.

## Details

The package `{condathis}` relies on
[**`micromamba`**](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html)
to bring **reproducibility and isolation**. Micromamba is a lightweight,
fast, and efficient package manager that “does not need a base
environment and does not come with a default version of Python”.

The integration of `micromamba` into `R`is handled using the `processx`
and `withr` packages. The package `processx` runs external processes and
manages their input and output, ensuring that commands to `micromamba`
are executed correctly from within R. The package `withr` temporarily
modifies environment variables and settings, allowing Micromamba to run
smoothly without permanently altering your R environment.
