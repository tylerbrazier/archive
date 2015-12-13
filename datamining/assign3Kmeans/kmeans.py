#!/usr/bin/python2

# Not very optimized

import sys
import math
import random
import matplotlib.pyplot as plot
import numpy


def dist(pointA, pointB):
    "pointA and pointB should be lists"
    total = 0
    for i in range(0, len(pointA)):
        total += (pointA[i] - pointB[i])**2
    return math.sqrt(total)


def findClosest(point, meanPoints):
    '''
    returns the index of the mean point in meanPoints that the 
    point argument is closest to.
    '''
    index = 0
    shortestDist = dist(point, meanPoints[0])
    for i in range(1, len(meanPoints)):
        currentDist = dist(point, meanPoints[i]) 
        if currentDist < shortestDist:
            shortestDist = currentDist
            index = i
    return index
 

def findCentroid(points):
    "argument is a list of lists; returns a list (point)"
    totals = [0 for attr in points[0]] # holds total for each point attribute
    for point in points:
        for i in range(0, len(point)):
            totals[i] += point[i]

    centroid = []
    for i in range(0, len(totals)):
        centroid.append(totals[i] / len(points))
    return centroid
    ''' old implementation
    totalX = 0
    totalY = 0
    for point in points:
        totalX += point.x
        totalY += point.y
    return Point( (totalX / len(points)), (totalY / len(points)) )
    '''


filename = sys.argv[1]
k = int(sys.argv[2])
data = numpy.loadtxt(filename)
meanPoints = []


# find initial random means
maxAttrs = [0 for i in data[1]]
for point in data:
    for i in range(0, len(point)):
        if point[i] > maxAttrs[i]:
            maxAttrs[i] = point[i]
for i in range(0, k):
    randPoint = []
    for maxAttr in maxAttrs:
        randPoint.append(random.random() * maxAttr)
    meanPoints.append(randPoint)



maxIterations = 20
epsilonThreshold = 0.00001
delta = 1
iterations = 0

while iterations < maxIterations and delta > epsilonThreshold:
    delta = 0

    # assign points to means
    memberships = [ [] for i in range(0, k) ] # [ [], [] ] when k = 2
    membersToPrint = [] # for the report of which points belong where
    for point in data:
        memberships[findClosest(point, meanPoints)].append(point)
        membersToPrint.append(findClosest(point, meanPoints))
        

    # update mean points
    previousMeanPoints = meanPoints
    meanPoints = []
    for group in memberships:
        if len(group) != 0:
            meanPoints.append(findCentroid(group))
    # calculate delta
    for i in range(0, len(meanPoints)):
        delta += dist(meanPoints[i], previousMeanPoints[i])

    iterations += 1


# report
print "mean points :", meanPoints
for i in range(0, len(memberships)):
    print "number of points in cluster", i, ":", len(memberships[i])
print "number of iterations :", iterations
print "delta :", delta
print "membership :", membersToPrint


# plot 2d data
if data.shape[1] == 2:
    xs = []
    ys = []
    for point in data:
        xs.append(point[0])
        ys.append(point[1])
    meanXs = []
    meanYs = []
    for point in meanPoints:
        meanXs.append(point[0])
        meanYs.append(point[1])
    plot.plot(xs, ys, 'ro', meanXs, meanYs, 'bs')
    plot.axis([0, round(max(xs)) + 1, 0, round(max(ys)) + 1])
    plot.show()
