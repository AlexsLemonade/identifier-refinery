![](https://i.imgur.com/GphUr2m.png)
# identifier-refinery

Tools and assets for easy and reproducable gene identifier conversion.

## Methods

This repository is used to build matricies which can convert between different gene identifiers.

These conversion matricies are built by:

 * Manually choosing random raw CEL files from NCBI GEO for a given platform accession code (in `/cels`)
 * Reading the CEL header and joining Brainarray (e.g., `hgu133plus2hsensgprobe`) and Bioconductor (e.g., `hgu133plus2.db`) (x, y) coordinates
 * Finding intersecting probe identifiers
 * Extracting supported identifiers and probe IDs from the Bioconductor package
 * Filtering on probe IDs and Ensembl Gene IDs in Brainarray
 * Writing the output to a conversion TSV file

## Repository Contents

### Source Files

The `cels` directory contains raw CEL files taken from GEO. The list of supported platforms is in `supported_microarray_platforms.csv`. Source files can be acquired by running the `acquire_cels.py` script.

### Docker Image

The conversion scripts are run on Docker images. 

Dockerfiles are provided in this repository.

### Conversion Scripts

[ .. ]

## Reproducing

The entire process can be reproduced by running the following command script from a fresh checkout of this repository. It will take some time:

```
$ ./generate_matricies_from_scratch.sh
```

## Identifiers

Released assets in this repository are availble under the DOI, `xyz:1.2.3.4`, which can be seen on Zenodo [here](https://link.todo).

## Related Projects

 * [AlexsLemonade/refinebio](https://github.com/AlexsLemonade/refinebio)

## Copyright

`identifier-refinery` output assets are released under a [CC0 1.0 Universal](https://creativecommons.org/publicdomain/zero/1.0/legalcode) license. All code is released under the BSD 3-clause license. Input assets are property of the original providers to NCBI GEO, but may be [freely downloaded and redistributed](https://www.ncbi.nlm.nih.gov/geo/info/disclaimer.html) unless otherwise noted.
