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
#nltk.download('wordnet')

#from nltk import word_tokenize, sent_tokenize
from nltk.corpus import wordnet
from nltk.stem.wordnet import WordNetLemmatizer

def check_utf8(mytext):

    passed = 1
    content = mytext.split(" ")
    for myword in content:
        try:
            myword.decode('utf8')
#            print('Latin2: ', end="")
#            print(myword, end="\n")
        except UnicodeDecodeError:
            print("String not utf-8?: ", end="")
            print(myword, end="\n")
            passed = 0

    return passed


def populate_lemma_dict():
    
    lemmas = dict()
    lemmas['be'] = 'be'
    lemmas['do'] = 'do'
    lemmas['have'] = 'have'
    lemmas['not'] = 'not'
    lemmas["n't"] = "n't"

    return lemmas


def read_map_penn_c5(map_file):
    file = open(map_file, 'r')
    the_file = file.read()

    map_dict = dict()
    content = the_file.split("\n")
    for line in content:
        line = line.strip()
        taggs = line.split("\t")
        penn = taggs[0]
        c5 = taggs[1]
        map_dict[penn] = c5

    return map_dict
        
def get_wordnet_pos(treebank_tag):

    if treebank_tag.startswith('J'):
        return wordnet.ADJ
    elif treebank_tag.startswith('V'):
        return wordnet.VERB
    elif treebank_tag.startswith('N'):
        return wordnet.NOUN
    elif treebank_tag.startswith('R'):
        return wordnet.ADV
    else:
        return ''


reload(sys)
sys.setdefaultencoding("utf-8")

#MAIN
if len(sys.argv) < 3:
    print("Need input and output file", end="\n")
    sys.exit()

wordnet_lemmatizer = WordNetLemmatizer()

#infile = "test.txt"
infile = sys.argv[1]

file = open(infile, 'r')
theText = file.read()

print('Tagging ', end="")
print(infile, end="\n")

theText = str(theText)
theText = re.sub("</s>", "SETNEND", theText)
theText = re.sub("<s>", "SETNSTART", theText)
theText = re.sub("&amp;", "&", theText)
#theText = re.sub("&lt;", "<", theText)
#theText = re.sub("&gt;", ">", theText)

theText = re.sub("ë", "eø", theText)
theText = re.sub("ń", "nø", theText)
theText = re.sub("œ", "æø", theText)
theText = re.sub("û", "uø", theText)

#theText = re.sub("ï", "iæ", theText)
#theText = re.sub("â", "aø", theText)
#theText = re.sub("ê", "eæ", theText)
#theText = re.sub("è", "eå", theText)
theText = re.sub("à", "aå", theText)

theText = re.sub("ā", "aø", theText)
theText = re.sub("ī", "iø", theText)

theText = re.sub("–", "--", theText)
theText = re.sub('–', '--', theText)

checked = check_utf8(theText)
if checked == 0:
    print("Non utf-8 characters in text", end="\n")

tokens = nltk.word_tokenize(theText)
tags = nltk.pos_tag(tokens)

the_mapping = dict()
the_mapping = read_map_penn_c5("map_penn_c5.txt")
lemma_list = dict()
lemma_list = populate_lemma_dict()

#outfile = "test_tagged.txt"
outfile = sys.argv[2]
new_file = open(outfile, 'w')

for tagg in tags:
    word = tagg[0]
    lemma = ''
    LEMMA = ''

    #Special case if word form is BE, DO or HAVE
    LEMMA = word.upper() #BE, DO or HAVE

    #Find word's lemma
    lemma = word.lower()
    if re.search(r'[a-zA-Z]', lemma):
        wc = get_wordnet_pos(tagg[1])
        if wc != '' and lemma != '':
            lemma = wordnet_lemmatizer.lemmatize(lemma, pos=wc)
    if lemma == "":
        lemma = tagg[0]

    #Check if PENN pos tag can be mapped to C5
    penn = tagg[1]
    c5 = penn
    if LEMMA == 'BE' or LEMMA == 'DO' or LEMMA == 'HAVE':
        penn = penn + '#' + LEMMA
    elif lemma in lemma_list: #lemma == 'be' or lemma == 'do' or lemma == 'have' or lemma == 'of' or lemma == 'not' or lemma == "n't" or lemma == 'when' or lemma == 'although':
        penn = penn + '#' + lemma

    if penn in the_mapping:
        c5 = the_mapping[penn]
    else:
        x = 0
    
    checked = check_utf8(word)
    if checked == 0:
        word = '???'
        c5 = 'SYM'
        lemma = '???'

    if (word == '.' and c5 == '.' and lemma == '.'):
        c5 = 'SETN'

    if (word == '--' and c5 == ':' and lemma == '--'):
        word = '&#x2013;'
        c5 = 'SYM'
        lemma = '&#x2013;'

    if (word == '&' and lemma == '&'):
        word = '&amp;'
        lemma = '&amp;'

    if (word == "``" and c5 == "``" and lemma == "``" ):
        word = '"'
        c5 = '"'
        lemma = '"'
    
    wpl = ''
    if (word == 'SETNSTART'):
        wpl = '<s>'
    elif (word == 'SETNEND'):
        wpl = '</s>'
    else:
        wpl = word + "\t" + c5 + "\t" + lemma

#Problematic characters and signs
    wpl = re.sub("eø", "ë", wpl)
    wpl = re.sub("nø", "ń", wpl)
    wpl = re.sub("æø", "œ", wpl)
    wpl = re.sub("uø", "û", wpl)
    wpl = re.sub("aø", "ā", wpl)
    wpl = re.sub("iø", "ī", wpl)
    wpl = re.sub("aå", "à", wpl)
#    wpl = re.sub("&", "&amp;", wpl)
#    wpl = re.sub("<", "&lt;", wpl)
#    wpl = re.sub(">", "&gt;", wpl)
#    wpl = re.sub("–", "--", wpl)

    new_file.write(wpl)
    new_file.write("\n")

new_file.close()

sys.exit()
