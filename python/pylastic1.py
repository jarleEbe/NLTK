#!/usr/bin/python

# if we want to give our script parameters, we need a special library
import sys, os, re, regex, io, codecs, requests, json

from elasticsearch import Elasticsearch

# FUNCTIONS

def add_data_to_index(es, index_name, document_type, data):

    result = es.index(index=index_name, doc_type=document_type, body=data)

    return result

def segment_and_index_text(directory, text):
   local_file = directory + '/' + text

   # open the file for reading
   with codecs.open(local_file, 'r', encoding="utf-8") as infile:
      content = infile.read() 

#   content = content.replace(u'\ufeff', '')
   my_list = list()
   sunitDict = dict()
   sunit = re.compile("\n");
   lines = re.split(sunit, content)
   for line in lines:
      line = line.strip()
#      print(line)
      sunitDict['sunit'] = line
      sunitJSON = json.dumps(sunitDict)
      indexed = add_data_to_index(es, "corpora", "cbf", sunitJSON)

   return

#MAIN
res = requests.get('http://localhost:9200')
#print(res.content)

es = Elasticsearch([{'host': 'localhost', 'port': 9200}])

#sunitDict['sunit'] = u'Test av innlegging.'
#sunitJSON = json.dumps(sunitDic)
#indexed = add_data_to_index(es, "corpora", "cbf", sunitJSON)

txt_files = re.compile("\.txt", flags=re.IGNORECASE)
segmented = re.compile("segmented", flags=re.IGNORECASE)
cbf = re.compile("cbf", flags=re.IGNORECASE)
print ("Start...")
for dirpath, dirs, files in os.walk("."):
#   print (dirpath)
#   print (dirs)
   for file in files:
      if re.search(txt_files, file) and re.search(segmented, dirpath) and re.search(cbf, dirpath):
         print(file)
         return_value = segment_and_index_text(dirpath, file)
