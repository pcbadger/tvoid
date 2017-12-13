import markovify
from random import *
import random
from flask import Flask
import os

prefixFile="OUTPUT/title_prefix.txt"
suffixFile="OUTPUT/title_suffix.txt"

def getTitlePart(afile):
    lines = open(afile).read().splitlines()
    myline =random.choice(lines)
    return myline

def getContent(synopsCountMax):
# Get raw text as string.
    synops=""
    short=""

    with open("OUTPUT/synopsis.txt") as f:
        text = f.read()

    text_model = markovify.Text(text, state_size=3)

    while not synops:
        synops=(text_model.make_sentence())
        print "produced synops"
    synopsCount=synops.count("")

    print synops

    remaining=eval("synopsCountMax - synopsCount")

    while eval("synopsCount > synopsCountMax"):
    	print "too long, shortening"
        synops=(text_model.make_sentence())
        synopsCount=synops.count("")

    remaining=eval("synopsCountMax - synopsCount")

    while eval("synopsCount < synopsCountMax"):
        short=""
        print "making short"
        while not short:
            short=(text_model.make_short_sentence(remaining))
        print short
        shortCount=short.count("")
        if short:
            synops+=str(" " + short)
            synopsCount=synops.count("")
            remaining=eval("synopsCountMax - synopsCount")
            if synopsCount > 180:
                synopsCount=eval("synopsCountMax + 1")
        else:
            synopsCount=eval("synopsCountMax + 1")

    print "--------------"
    return synops



def getTitle():
    prefix=""
    suffix=""
    suffix=getTitlePart(suffixFile).lower()
    prefix=getTitlePart(prefixFile).lower()
    title=(prefix + " " + suffix)
    title = (title.replace("the of ", "the "))
    title = (title.replace("the a ", "the "))
    title = (title.replace("the the ", "the "))
    title = (title.replace("the the ", "the "))
    title = (title.replace("  ", " ")).title()
    title = (title.replace("  ", " "))
    title = (title.replace("\'S", "\'s"))
    title = (title.replace("\'T", "\'t"))
    title = (title.replace("\'Ll", "\'ll"))
    title = (title.replace("\'M", "\'m"))
    title = (title.replace("\'N", "\'n"))
    return title

def getWhoTitle():
    prefix=""
    suffix=""
    while prefix.count("") < 2:
        rando=randint(1,4)
        if rando > 2:
            prefix=getTitlePart(suffixFile).lower()
        else:
            prefix=getTitlePart(prefixFile).lower()
    while suffix.count("") < 2:
        rando=randint(1,10)
        if rando > 8:
            suffix=getTitlePart(prefixFile).lower()
        else:
            suffix=getTitlePart(suffixFile).lower()
    prefix = (prefix.replace("!", ""))
    print prefix
    print suffix

    rando2=randint(1,5)
    if rando2 > 2:
        ofThe=" of the "
    elif rando2 > 5:
        ofThe=" of "
    else:
        ofThe=""

    if suffix.startswith("of ") or  suffix.startswith("in ") or  suffix.startswith("a ") or  suffix.startswith("to ") or  suffix.startswith("on ") or  suffix.startswith("for ") or  suffix.startswith("and ") or  suffix.startswith("at "):
        ofThe=""
    if suffix.startswith("the "):
        ofThe="of "

    if prefix.startswith("of ") or  prefix.startswith("with ") or  prefix.startswith("from ") or  prefix.startswith("and ") or  prefix.startswith("in ")  or  prefix.startswith("a ") :
        print "TRIM PREFIX"
        prefix.partition(' ')[2]

    title=("the " + prefix + " " + ofThe + " " + suffix)#.title()
    title = (title.replace("the of ", "the "))
    title = (title.replace("the a ", "the "))
    title = (title.replace("the the ", "the "))
    title = (title.replace("the the ", "the "))
    title = (title.replace("  ", " ")).title()
    title = (title.replace("  ", " "))
    title = (title.replace("\'S", "\'s"))
    return title


def doAllTheThings():
    storyTitle=getTitle().title()
    titleCount=storyTitle.count("")
    synopsCountMax=eval("277 - titleCount")
    storyContent=getContent(synopsCountMax)
    return storyTitle
    return storyContent

app_finl = Flask(__name__)

@app_finl.route('/')
def doAllTheThings():
    fullStory=""
    storyContent=""
    storyTitle=getTitle()
    titleCount=storyTitle.count("")
    synopsCountMax=eval("277 - titleCount")
    storyContent=getContent(synopsCountMax)

    fullStory+=str(storyTitle + ": " + storyContent)
    fullStoryCount=fullStory.count("")

    while fullStoryCount > 279:
        fullStory=""
        storyContent=getContent(synopsCountMax)
        fullStory+=str(storyTitle + ": " + storyContent)
        fullStoryCount=fullStory.count("")
    return fullStory

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app_finl.run(host='0.0.0.0', port=port)
    #app_finl.run(debug=False, host='0.0.0.0')