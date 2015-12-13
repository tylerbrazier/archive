import decimal
import sys
import numpy
import math
from scipy.stats import norm

# run with python 2 
# Call this script with first argument as training file and second as 
# the testing file.


# returns a list (one for each attribute) of means for a particular class
# both arguments should be strings
def getMeans(trainingFileName, classNum):
    means = [] # this will be returned
    lines = []
    trainingFile = open(trainingFileName)
    for line in trainingFile:
        lineList = line.split()
        if lineList[-1] == classNum: # look at last element in the list
            lineList.pop() # remove the last element (the class label)
            lines.append(lineList)
    # at this point, "lines" contains all the attributes belonging to the class
    for i in range (0, len(lines[0])):
        attrList = []
        for j in range(0,len(lines)):
            attrList.append(float(lines[j][i]))
        means.append(numpy.mean(attrList))
    return means
# end of getMeans


# returns a list (one for each attribute) of standard deviations for a 
# particular class
# both arguments should be strings
def getStds(trainingFileName, classNum):
    stds = [] # this will be returned
    lines = []
    trainingFile = open(trainingFileName)
    for line in trainingFile:
        lineList = line.split()
        if lineList[-1] == classNum: # look at last element in the list
            lineList.pop() # remove the last element (the class label)
            lines.append(lineList)
    # at this point, "lines" contains all the attributes belonging to the class
    for i in range (0, len(lines[0])):
        attrList = []
        for j in range(0,len(lines)):
            attrList.append(float(lines[j][i]))
        stds.append(numpy.std(attrList))
    return stds
# end of getStds


# returns the prior for a particular class
# both arguments should be strings
def getPrior(trainingFileName, classNum):
    classLines = 0
    totalLines = 0
    trainingFile = open(trainingFileName)
    for line in trainingFile:
        lineList = line.split()
        if lineList[-1] == classNum:
            classLines += 1
        totalLines += 1
    return float(classLines) / float(totalLines)
# end of getPrior


def getLikelihood(trainingFileName, testingFileLine, classNum):
    testingFileLine = testingFileLine.split()
    # convert each element from a string to a number
    for i in range(0, len(testingFileLine)):
        testingFileLine[i] = float(testingFileLine[i])
    # need decimal class for increased precision
    likelihood = decimal.Decimal(norm.pdf(
    testingFileLine[0],
    getMeans(trainingFileName, classNum)[0],
    getStds(trainingFileName, classNum)[0]))
    for i in range (1, len(testingFileLine)-1):
        likelihood *= decimal.Decimal(norm.pdf(
        testingFileLine[i], 
        getMeans(trainingFileName, classNum)[i],
        getStds(trainingFileName, classNum)[i]))
    #return decimal.Decimal(likelihood)
    return likelihood
# end of getLikelihood 


def getPosteriori(trainingFileName, testingLine, classNum):
    return getLikelihood(
    trainingFileName, 
    testingLine, 
    classNum) * decimal.Decimal(getPrior(trainingFileName, classNum))
# end of getPosteriori


# main part of the script

tpos = 0
tneg = 0
fpos = 0
fneg = 0
trainingFileName = sys.argv[1]
testingFileName = sys.argv[2]
for line in open(testingFileName): 
    classOne = getPosteriori(trainingFileName, line, "1")
    classNegOne = getPosteriori(trainingFileName, line, "-1")
    if classOne > classNegOne:
        winner = "1"
    elif classNegOne > classOne:
        winner = "-1"
    else:
        print("Equal probability.")
        continue # don't execute the rest of this loop iteration
    actualClass = line.split()[-1]
    if winner == "1" and actualClass == "1":
        tpos += 1
    elif winner == "1" and actualClass == "-1":
        fpos += 1
    elif winner == "-1" and actualClass == "-1":
        tneg += 1
    elif winner == "-1" and actualClass == "1":
        fneg += 1
print("True positives  =", tpos)
print("True negatives  =", tneg)
print("False positives =", fpos)
print("False negatives =", fneg)

print("Accuracy =", float(tpos + tneg) / float(tpos + tneg + fpos + fneg))
print("Precision =", float(tpos) / float(tpos + fpos))
print("Recall =", float(tpos) / float(tpos + fneg))
# done
