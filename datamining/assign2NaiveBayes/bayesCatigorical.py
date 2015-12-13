import sys
import numpy
import math
from scipy.stats import norm

# run with python 2 
# Call this script with first argument as training file and second as 
# the testing file.


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
    trainingFile = open(trainingFileName)
    classLines = []
    for line in trainingFile:
        line = line.split()
        if line[-1] == classNum:
            line.pop() # remove the last element (the class number)
            classLines.append(line)
    # at this point, classLines is a 2D array
    classCounts = []
    for i in range(0,len(testingFileLine)-1):
        classCounts.append(0)
        for attrs in classLines:
            if testingFileLine[i] in attrs:
                classCounts[i] += 1
        classCounts[i] = float(classCounts[i]) / float(len(classLines))
    classTotal = 1
    for val in classCounts:
        classTotal *= val
    return classTotal
# end of getLikelihood 


def getPosteriori(trainingFileName, testingLine, classNum):
    return getLikelihood(
    trainingFileName, 
    testingLine, 
    classNum) * getPrior(trainingFileName, classNum)


# main part of the script

tpos = 0
tneg = 0
fpos = 0
fneg = 0
trainingFileName = sys.argv[1]
testingFileName = sys.argv[2]
for line in open(testingFileName): 
    classOne = getPosteriori(trainingFileName, line, "1")
    classNeg = getPosteriori(trainingFileName, line, "-1")
    if classOne > classNeg:
        winner = "1"
    elif classNeg > classOne:
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
