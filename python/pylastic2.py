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


#MAIN
res = requests.get('http://localhost:9200')
print(res.content)

es = Elasticsearch([{'host': 'localhost', 'port': 9200}])

created = create_index(es, "corpora")

mapped = create_mapping(es, "corpora", "cbf", "sunit")
mapped = create_mapping(es, "corpora", "cbf", "textId")

#deleted = delete_index(es, "corpora")
