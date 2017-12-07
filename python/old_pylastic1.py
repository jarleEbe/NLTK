#!/usr/bin/python

# if we want to give our script parameters, we need a special library
import sys, os, re, regex, io, codecs, requests, json

from elasticsearch import Elasticsearch

# FUNCTIONS

def create_index(es, index_name):
   result = es.indices.create(index=index_name)

   return result

def delete_index(es, index_name):
   result = es.indices.delete(index=index_name)

   return result

def create_mapping(es, index_name, document_type, field):
    mapping = {document_type:{"properties":{field:{"type":"string","store":"yes","index": "analyzed", "analyzer":"standard"}}}}

    result = es.indices.put_mapping(index=index_name, doc_type=document_type, body=mapping)

    return result

def segment_text(directory, text):
   local_file = directory + '/' + text

   # open the file for reading
   with codecs.open(local_file, 'r', encoding="utf-8") as infile:
      content = infile.read() 

#   content = content.replace(u'\ufeff', '')
   my_list = list()
   sunit = re.compile("\n");
   lines = re.split(sunit, content)
   for line in lines:
      line = line.strip()
   
   return


#MAIN
res = requests.get('http://localhost:9200')
print(res.content)

es = Elasticsearch([{'host': 'localhost', 'port': 9200}])
#created = create_index(es, "corpora")

#deleted = delete_index(es, "corpora")

mapped = create_mapping(es, "corpora", "cbf", "sunit")

sunitDict = dict()
sunitDict['sunit'] = u'Dette er en testsetning.'
sunitJSON = json.dumps(sunitDict)
print(sunitJSON)

txt_files = re.compile("\.txt", flags=re.IGNORECASE)
segmented = re.compile("segmented", flags=re.IGNORECASE)
#print ("Start...")
#for dirpath, dirs, files in os.walk("."):
#   print (dirpath)
#   print (dirs)
#   for file in files:
#      if re.search(txt_files, file) and re.search(segmented, dirpath):
#         print (file)
#         return_value = segment_text(dirpath, file)
