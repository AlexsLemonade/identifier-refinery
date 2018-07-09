# Helper function that installs a list of packages based on input URL
install_with_url <- function(main_url, packages) {
  lapply(packages,
         function(pkg) devtools::install_url(paste0(main_url, pkg)))
}

source("https://bioconductor.org/biocLite.R")
biocLite(paste0(Sys.getenv("DB"), '.db'))
biocLite('pd.ht.hg.u133.plus.pm')
biocLite('pd.ht.mg.430a')
biocLite("htmg430aprobe")

annotation_url <- 'https://bioconductor.org/packages/3.6/data/annotation/src/contrib/'
pd_annotation_pkgs <- c(
	Sys.getenv("PACKAGE")
)
install_with_url(annotation_url, pd_annotation_pkgs)

