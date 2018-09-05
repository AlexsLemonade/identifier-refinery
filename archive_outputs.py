import os
import shutil
import time

out_dir = os.getcwd() + '/cels/out/'
archive_dir = os.getcwd() + '/archives/'

for dirName, subdirList, fileList in os.walk(out_dir):
    for subDir in subdirList:
    	platform_dir = os.path.join(out_dir, subDir)
        for file in os.listdir(platform_dir):
        	shutil.copyfile(os.path.join(platform_dir, file), (archive_dir + file.split('_')[0]) + '.tsv.gz')

shutil.make_archive("all_" + str(int(time.time())), 'zip', archive_dir)
