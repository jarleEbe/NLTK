#!/usr/bin/python

# if we want to give our script parameters, we need a special library
import sys, os, re, regex, io, codecs, requests, json

from elasticsearch import Elasticsearch

# FUNCTIONS


def simple_search(es, index_name, document_type, q):

   print(q)
   mylist = list()
   if re.search(" ", q):
      mylist = q.split(" ")

#   no_of_words = len(mylist)
#   print(q)
#   print(no_of_words)
#   print(mylist[0])
#   print(mylist[1])

   size = 20
   data = json.dumps({})
#   data = {"size": size, "query": {"match_phrase": {"sunit": q}}}

#   data = {"size": size, "query": {"simple_query_string": {"query": q, "fields": ["sunit"], "default_operator": "and"}}}


#   data = {"from": 0, "size": size, "query": {"term": {"sunit": q}}}
#   data = {"from": 0, "size": size, "query": {"wildcard": {"sunit": q}}}
#   if (no_of_words == 0):
#      data = {"from": 0, "size": size, "query": {"bool": {"must": [ {"match": {"sunit": q}} ] }}}
#   elif (no_of_words == 1):
#      data = {"from": 0, "size": size, "query": {"bool": {"must": [ {"match": {"sunit": mylist[0]}}, {"match": {"sunit": mylist[1]}} ] }}}

   data = {"from" : 0, "size": size, "query":{ "span_near" : { "clauses" : [ { "span_term" : { "sunit": "it" }}, { "span_term" : { "sunit": "was" }}, { "span_multi" : { "match" : { "regexp": {"sunit": ".*"}}}}, { "span_term" : { "sunit": "that" }} ], "slop" : 0, "in_order" : "true" }}, "highlight": {"pre_tags": ["<em>"], "post_tags": ["</em>"], "fields": {"sunit": {}}}}

#   data = {"from": 0, "size": size, "query": {"regexp": {"sunit": q}}}

   result = es.search(index=index_name, doc_type=document_type, body=data)

   return result


#MAIN

input = sys.argv[1]
#print(input)
res = requests.get('http://localhost:9200')
#print(res.content)

es = Elasticsearch([{'host': 'localhost', 'port': 9200}])

#looking_for = simple_query_string(es, "corpora", "cbf", query)

query = input
result = simple_search(es, "corpora", "cbf", query)

#print(result)
#print("\n")

parsed_data = json.dumps(result)

#print(parsed_data)
#print("\n")

sunit = json.loads(parsed_data)

#print(json.dumps(sunit, indent=4))
#print("\n")

print(sunit['hits']['total'])

#print(sunit['hits']['hits'][0]['_source']['sunit'])
#print("\n")

sentence = list()
for row in sunit["hits"]["hits"]:
#    print row["_source"]["sunit"]
    sentence = row["highlight"]["sunit"]
    for word in sentence:
       word = str(word)
       word = word.replace("<em>", "<hi>", 1)
#       word = word.replace("</em>", "</hi>", 4)
       word = word[::-1]
       word = word.replace(">me/<", ">ih/<", 1)
       word = word[::-1]
       word = word.replace("<em>", "")
       word = word.replace("</em>", "")
       print(word)
