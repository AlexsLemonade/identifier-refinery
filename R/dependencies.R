# Turn warnings into errors because biocLite throws warnings instead
# of error if it fails to install something.
options(warn=2)

options(repos=structure(c(CRAN="https://cloud.r-project.org")))

# Install dev packages
install.packages("devtools")

# Use devtools::install_version() to install packages in cran.
devtools::install_version('data.table', version='1.11.0')
devtools::install_version('optparse', version='1.4.4')

# Bioconductor packages, installed by devtools::install_url()

# devtools::install_url() requires biocLite.R
source('https://bioconductor.org/biocLite.R')

# Tidyverse and related
install.packages("tidyverse")

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
