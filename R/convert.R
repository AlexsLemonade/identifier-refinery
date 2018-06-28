# J. Taroni 2018

# magrittr pipe
`%>%` <- dplyr::`%>%`

option_list = list(
  optparse::make_option(c("-p", "--platform"),
                        type = "character",
                        default = "hgu133plus2",
                        help = "Platform",
                        metavar ="character"),
  optparse::make_option(c("-d", "--db"),
                        type = "character",
                        default = "hgu133plus2",
                        help = "Platform",
                        metavar ="character"),
  optparse::make_option(c("-s", "--species"),
                        type = "character",
                        default = "hs",
                        help = "Species",
                        metavar ="character"),
  optparse::make_option(c("-i", "--inputFile"),
                        type = "character",
                        default = "",
                        help = "inputFile",
                        metavar = "character"),
  optparse::make_option(c("-g", "--gid"),
                        type = "character",
                        default = "",
                        help = "outputFile",
                        metavar = "character"),
  optparse::make_option(c("-o", "--outputFile"),
                        type = "character",
                        default = "",
                        help = "outputFile",
                        metavar = "character")
)

opt_parser <- optparse::OptionParser(option_list=option_list)
opt <- optparse::parse_args(opt_parser)

platform <- opt$platform
db <- opt$db
org_code <- opt$species
cel_path <- opt$inputFile
gid <- opt$gid
out_file_path <- opt$outputFile

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

# load bioconductor .db package
db_package_name <- paste0(db, ".db")
library(db_package_name, character.only = TRUE)

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

# what identifiers will we support conversion from? we'll supply these to the
# .db package
supported_identifiers <- c("SYMBOL", "ENTREZID", "UNIGENE", "ENSEMBL",
                           "REFSEQ")
# only those that are actually supported by the package
message("Interesectiong..")
supported_identifiers <- base::intersect(supported_identifiers, 
                                         keytypes(get(db_package_name)))

# extract the supported identifiers and probe IDs from .db package
message("Selecting..")
db_map_df <- select(get(db_package_name), 
                    keys = keys(get(db_package_name)),
                    columns = supported_identifiers)

# filtering join on probe IDs and Ensembl gene IDs in brainarray
message("Filtering..")
master_map_df <- dplyr::left_join(x = ba_probe_ensg_df,
                                  y = db_map_df,
                                  by = c("PROBEID", "ENSEMBL"))

# output file, using the path supplied as an argument
output_file <- file.path(out_file_path, 
                         paste0(platform, "_", gid, "_master_conversion.tsv.gz"))
# write compressed file
message("Writing outfile..")
readr::write_tsv(master_map_df, 
                 path = output_file)
