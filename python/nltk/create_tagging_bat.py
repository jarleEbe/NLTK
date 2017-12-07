#!C:/Python34/python
import os, re

rootdir = '.'

filestotag = re.compile('filestotag', flags=re.IGNORECASE)
tagged = re.compile('tagged', flags=re.IGNORECASE)
horizontal = re.compile('horizontal', flags=re.IGNORECASE)
for subdir, dirs, files in os.walk(rootdir):
    if re.search(filestotag, subdir) and not re.search(tagged, subdir) and not re.search(horizontal, subdir):
        for file in files:
            if re.search('\.txt', file):
                name = file
                name = re.sub("\.txt", "", name)
                name += "_tagged.txt"
                print('python nltkTagg.py ', end="")
                print(os.path.join(subdir, file), end=" ")
                print(subdir, end="")
                print('/tagged/', end="")
                print(name, end="\n")
