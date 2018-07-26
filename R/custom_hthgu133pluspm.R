# adapted from the brainarray stuff!

`%>%` <- dplyr::`%>%`

cel_path <- "/home/user/data/GSM673476_SJHYPO008_D_HTU133PM.CEL"
platform <- "hthgu133pluspm"
org_code <- "hs"

# Does platform in CEL header match platform passed as an argument?
header_platform <- unlist(affyio::read.celfile.header(cel_path)[1])
header_platform <- tolower(gsub("[[:punct:]]", "", header_platform))
# if not, throw error
if (header_platform != platform) {
  stop("CEL file header does not match platform argument")
}

# load brainarray package
ba_package_name <- paste0(platform, org_code, "ensgprobe")
library(ba_package_name, character.only = TRUE)

# generate a ExpressionFeatureSet from inputFile -- this step will automatically
# install platform design packages from bioconductor if not already installed
# adapted from SCAN.UPC one color
message("Reading..")
affy_feature_set <- oligo::read.celfiles(cel_path)
# this data.frame has the x, y coords and the manufacturer ID
probe_info_df <- oligo::getProbeInfo(affy_feature_set, 
                                     field = c("x", "y"), 
                                     probeType = "pm")

# data.frame contains x, y coord and the gene IDs from brainarray package
message("Mutating..")
brainarray_df <- as.data.frame(get(ba_package_name), stringsAsFactors = FALSE)
# we'll drop the trailing "_at" to get the Ensembl gene IDs
brainarray_df <- brainarray_df %>%
  dplyr::mutate(Probe.Set.Name = sub("_at", "", Probe.Set.Name))

# join brainarray and probe info by x,y coord & clean up a bit
message("Joining..")
ba_probe_ensg_df <- dplyr::inner_join(probe_info_df, brainarray_df,
                                      by = c("x", "y")) %>%
  dplyr::select(c("man_fsetid", "Probe.Set.Name")) %>%
  dplyr::mutate(PROBEID = man_fsetid, ENSEMBL = Probe.Set.Name) %>%
  dplyr::select(PROBEID:ENSEMBL) %>%
  dplyr::mutate(ENSEMBL = as.character(ENSEMBL))

# read in GPL file from geo and wrangle
gpl_df <- readr::read_tsv("/home/user/data/GPL13158-5065.txt", comment = "#") %>%
  dplyr::select(c("ID", "Gene Symbol", "ENTREZ_GENE_ID", "RefSeq Transcript ID")) %>%
  dplyr::mutate(PROBEID = ID, 
                SYMBOL = `Gene Symbol`, 
                ENTREZID = ENTREZ_GENE_ID,
                REFSEQ = `RefSeq Transcript ID`) %>%
  dplyr::select(PROBEID:REFSEQ)

# some of the gene ids are separated by " /// " -- which columns have that?
sep_cols <- names(gpl_df)[apply(gpl_df, 2, function(x) any(grepl(" /// ", x)))]

# for each of the gene ids with multiple mappings, separate
for (col_name in sep_cols) {
  gpl_df <- gpl_df %>%
    tidyr::separate_rows(rlang::UQ(rlang::sym(col_name)), sep = " /// ")
}

# master
master_df <- dplyr::left_join(x = ba_probe_ensg_df, y = gpl_df, by = "PROBEID")

# output file, using the path supplied as an argument
output_file <- file.path("/home/user/data/out", paste0("hthgu133pluspm_master_conversion.tsv.gz"))
# write compressed file
message("Writing outfile..")
readr::write_tsv(master_df, 
                 path = output_file)