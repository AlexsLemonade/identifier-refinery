# Pin devtools to version 1.13.6 & install its dependencies
# devtools is the package we use to install specific versions of other packages
# see also: https://github.com/AlexsLemonade/refinebio/pull/752

# From https://github.com/AlexsLemonade/refinebio/blob/d55616dff8270aa46179a26c8e86318c8535df32/common/install_devtools.R

# Treat warnings as errors, set CRAN mirror, and set parallelization:
options(warn=2)
options(repos=structure(c(CRAN="http://lib.stat.cmu.edu/R/CRAN/")))

install_package_version <- function(package_name, version) {
  # This function install a specific version of a package.

  # However, because the most current version of a package lives in a
  # different location than the older versions, we have to check where
  # it can be found.
  package_tarball <- paste0(package_name, "_", version, ".tar.gz")
  package_url <- paste0("http://lib.stat.cmu.edu/R/CRAN/src/contrib/", package_tarball)

  # Give CRAN a full minute to timeout since it's not always the most reliable.
  curl_result <- system(paste0("curl --head --connect-timeout 60 ", package_url), intern=TRUE)
  if (grepl("404", curl_result[1])) {
    package_url <- paste0("http://lib.stat.cmu.edu/R/CRAN/src/contrib/Archive/", package_name, "/", package_tarball)

    # Make sure the package actually exists in the archive!
    curl_result <- system(paste0("curl --head --connect-timeout 120 ", package_url), intern=TRUE)
    if (grepl("404", curl_result[1])) {
      stop(paste("Package", package_name, "version", version, "does not exist!"))
    }
  }

  install.packages(package_url)
}

install_package_version("jsonlite", "1.5")
install_package_version("mime", "0.6")
install_package_version("curl", "3.2")
install_package_version("openssl", "1.0.2")
install_package_version("R6", "2.3.0")
install_package_version("httr", "1.3.1")
install_package_version("digest", "0.6.18")
install_package_version("memoise", "1.1.0")
install_package_version("whisker", "0.3-2")
install_package_version("rstudioapi", "0.8")
install_package_version("git2r", "0.23.0")
install_package_version("withr", "2.1.2")
install_package_version("devtools", "1.13.6")

# Use devtools::install_version() to install packages in cran.
devtools::install_version('data.table', version='1.11.0')
devtools::install_version('optparse', version='1.4.4')
devtools::install_version('rlang', version='0.2.2')
devtools::install_version('dplyr', version='0.7.4')
devtools::install_version('readr', version='1.1.1')
devtools::install_version('tidyr', version='0.8.2')

# BiocInstaller, required by devtools::install_url()
install.packages('https://bioconductor.org/packages/3.6/bioc/src/contrib/BiocInstaller_1.28.0.tar.gz')

# Helper function that installs a list of packages based on input URL
install_with_url <- function(main_url, packages) {
  lapply(packages,
         function(pkg) devtools::install_url(paste0(main_url, pkg)))
}

bioc_url <- 'https://bioconductor.org/packages/3.6/bioc/src/contrib/'
bioc_pkgs <- c(
  'oligo_1.42.0.tar.gz',
  'Biobase_2.38.0.tar.gz',
  'affy_1.56.0.tar.gz',
  'affyio_1.48.0.tar.gz',
  'AnnotationDbi_1.40.0.tar.gz'
)
install_with_url(bioc_url, bioc_pkgs)

annotation_url <- 'https://bioconductor.org/packages/3.6/data/annotation/src/contrib/'
annotation_pkgs <- c(
  'org.Hs.eg.db_3.5.0.tar.gz',
  'org.Mm.eg.db_3.5.0.tar.gz',
  'org.Dm.eg.db_3.5.0.tar.gz',
  'org.Ce.eg.db_3.5.0.tar.gz',
  'org.Bt.eg.db_3.5.0.tar.gz',
  'org.Cf.eg.db_3.5.0.tar.gz',
  'org.Gg.eg.db_3.5.0.tar.gz',
  'org.Rn.eg.db_3.5.0.tar.gz',
  'org.Ss.eg.db_3.5.0.tar.gz',
  'org.Dr.eg.db_3.5.0.tar.gz'
)
install_with_url(annotation_url, annotation_pkgs)

# Invoke another R script to install BrainArray ensg packages
source("install_ensg_pkgs.R")

# Install Bioconductor platform design (pd) packages
experiment_url <- 'https://bioconductor.org/packages/release/data/experiment/src/contrib/'
pd_experiment_pkgs <- c(
  'pd.atdschip.tiling_0.16.0.tar.gz'
)
install_with_url(experiment_url, pd_experiment_pkgs)
