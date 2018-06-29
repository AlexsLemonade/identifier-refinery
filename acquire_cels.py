import csv
import GEOparse
import os
import random
import sys
import urllib

try:
  from pathlib import Path
except ImportError:
  from pathlib2 import Path  # python 2 backport

try:
    target = sys.argv[1]
except IndexError:
    target = None

brainset = []
with open('supported_microarray_platforms.csv', 'r') as csv_in:
    csv_in = csv.reader(csv_in)
    for ccount, row in enumerate(csv_in):
        if ccount is 0:
            continue

        # This _is_ a supported platform.
        if row[2] == "y":
            if target:
                if target == row[0]:
                    brainset.append((row[0], row[1]))
                else:
                    continue
            else:
                brainset.append((row[0], row[1]))

# Ensure uniqueness
brainset = list(set(brainset))

for pair in brainset:
    brainarray_package = pair[0] # ex, `bovgene10st`
    accession = pair[1] # ex, `GPL16500`

    # This is a GEO GPL, not an Array Express accession.
    if '-' not in accession:

        # Skip platforms we have already platform.
        path = 'cels/' + brainarray_package + '/'
        if os.path.exists(path):
            print("Skipping existing platform " + brainarray_package)
            continue

        # This is an empty platform.
        if accession == 'GPL13158':
            continue

        # Fetch the GPL info from NCBI GEO
        gpl = GEOparse.get_GEO(accession, how='brief', destdir='/tmp')

        # Randomize our choice of cells.
        keys = gpl.metadata.get('sample_id', [])
        random.shuffle(keys)
        random.shuffle(keys)
        random.shuffle(keys)
        random.shuffle(keys)
        random.shuffle(keys)

        # Get five samples per platform.
        for i in range(0,5):
            try:
                gid = keys[i]
                gse = GEOparse.get_GEO(gid, how='brief', destdir='/tmp')
                for ffile in gse.metadata['supplementary_file']:
                    # We only care about CEL files, not metadata files.
                    if '.CEL' in ffile:
                        Path(path).mkdir(exist_ok=True)
                        urllib.urlretrieve(ffile, path + gid + "_" + ffile.split('/')[-1])
                        break
            except Exception as e:
                print(e)
        break
