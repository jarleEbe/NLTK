#!C:/Python34/python
#encoding: utf-8

import sys, os, re, nltk, nltk.tag, nltk.stem, nltk.corpus

#nltk.download('punkt')

from nltk import word_tokenize, sent_tokenize
#from nltk.tag import brill
#from nltk.tag.hunpos import HunposTagger
        
from nltk.corpus import wordnet
from nltk.stem.wordnet import WordNetLemmatizer

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
#        print(penn)
#        print(c5)
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

## MAIN

if len(sys.argv) < 3:
    print("Need input and output file", end="\n")
    sys.exit()
    
wordnet_lemmatizer = WordNetLemmatizer()
#verb = wordnet_lemmatizer.lemmatize('was', wordnet.VERB)
#print (verb)

#infile = 'taggtest_clean.txt'
infile = sys.argv[1]
file = open(infile, 'r', encoding='utf8')

print("Tagging ", end="")
print(infile, end="")
print("...", end="\n")

the_file = file.read()
#Applies to non-clan files
#the_file = re.sub('&mdash;', ' -- ', the_file, flags=re.MULTILINE)
#the_file = re.sub('&dash;', ' -- ', the_file, flags=re.MULTILINE)
#the_file = re.sub('--', ' -- ', the_file, flags=re.MULTILINE)
#the_file = re.sub('_', ' ', the_file, flags=re.MULTILINE)

the_file = re.sub('<s>', 'SETNSTART ', the_file, flags=re.MULTILINE|re.IGNORECASE)
the_file = re.sub('</s>', ' SETNEND', the_file, flags=re.MULTILINE|re.IGNORECASE)
the_file = re.sub('<p>', '', the_file, flags=re.MULTILINE|re.IGNORECASE)
the_file = re.sub('</p>', '', the_file, flags=re.MULTILINE|re.IGNORECASE)

#s_units = nltk.sent_tokenize(the_file)
tokens = nltk.word_tokenize(the_file)
tags = nltk.pos_tag(tokens)

#ht = HunposTagger('d:/hunpos/en_wsj.model/english.model', 'd:/hunpos/hunpos-1.0-win/hunpos-tag.exe')
#hun_pos = ht.tag(tokens)
#print(hun_pos)

#print (tags)
outfile = sys.argv[2]
new_file = open(outfile, 'w', encoding='utf-8')
#new_file.write(str(tags))
#new_file.close()

the_mapping = dict()
the_mapping = read_map_penn_c5("map_penn_c5.txt")
lemma_list = dict()
lemma_list = populate_lemma_dict()

for tagg in tags:
    #Print word
#    new_file.write(tagg[0])
#    new_file.write("\t")
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

    atrib_pos = 'pos="' + c5 + '"'
    if lemma[-1] == '.':
        lemma = lemma[:-1]
    atrib_lem = 'l="' + lemma + '"'
    word_element = '<w ' + atrib_lem + ' ' + atrib_pos + '>' + word + '</w>'
    new_file.write(word_element)
    new_file.write("\n")

new_file.close()
sys.exit()
