#!/usr/bin/python
# -*- coding: utf-8 -*- 
from __future__ import print_function

# if we want to give our script parameters, we need a special library
#from xml.etree import ElementTree as ET
import sys
import os
import re
import nltk
import nltk.stem
import nltk.corpus
import nltk.tag

#nltk.download('punkt')
#nltk.download('averaged_perceptron_tagger')

from nltk import word_tokenize, sent_tokenize
from nltk.corpus import wordnet
from nltk.stem.wordnet import WordNetLemmatizer

reload(sys)
sys.setdefaultencoding("utf-8")

#MAIN
wordnet_lemmatizer = WordNetLemmatizer()

infile = "test.txt"
file = open(infile, 'r')
theText = file.read()
tokens = nltk.word_tokenize(theText)
tags = nltk.pos_tag(tokens)

outfile = "test_tagged.txt"
newFile = open(outfile, 'w')
for tag in tags:
      newFile.write(tag[0])
      newFile.write("\t")
      newFile.write(tag[1])
      newFile.write("\n")

newFile.close()

sys.exit()

#if len(sys.argv) < 1:
#    print("Need input directory")
#    sys.exit()

#mystartdir = sys.argv[1]

#xml_files = re.compile("\.xml$", flags=re.IGNORECASE)
#segmented = re.compile("segmented", flags=re.IGNORECASE)

#print ("Start segmenting ...")
#for dirpath, dirs, files in os.walk(mystartdir):
#   print (dirpath)
#   print (dirs)
#   for file in files:
#      if re.search(xml_files, file): # and re.search(clean_files, file) and not re.search(segmented, dirpath) and not re.search(header, dirpath):
#         print (file)
#         print (dirpath)
#         return_value = segment_text(dirpath, file)
print ("End.")
