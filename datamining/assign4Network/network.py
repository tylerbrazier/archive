#!/usr/bin/python2

import sys
import numpy
import matplotlib.pyplot as plt

filename = sys.argv[1]
data = numpy.loadtxt(filename)

# find the largest nodes to initalize the matrix size
largest = 0
for pair in data:
    if max(pair) > largest:
        largest = max(pair)

# create the matrix
matrix = numpy.zeros([largest, largest])
for pair in data:
    matrix[ pair[0]-1 ][ pair[1]-1 ] = 1
    matrix[ pair[1]-1 ][ pair[0]-1 ] = 1


# plot ( j, k[j] )
xVals = []
yVals = []
totals = []
for i in range(0, len(matrix)):
    totals.append(matrix[i].tolist().count(1))
for i in range(1, max(totals)+1):
    if i != 0:
        xVals.append(i)
        yVals.append(totals.count(i))
for i in range(0, len(xVals)):
    plt.scatter(xVals[i], yVals[i])
plt.xlabel("j")
plt.ylabel("k[j]")
plt.title("Degree Distribution")
plt.show()
plt.clf()


# plot ( j, P(k[j]) )
for i in range(0, len(yVals)):
    yVals[i] = float(float(yVals[i])/len(matrix))
    plt.scatter(xVals[i], yVals[i])
plt.yscale('log', basey=2)
plt.xscale('log', basex=2)
plt.xlabel("j")
plt.ylabel("P( k[j] )")
plt.title("Probability")
plt.show()
plt.clf()


def getClustCoef(node):
    "Node number should start at index 1"
    # calculate connected neighborhood
    neighborhood = [] # will contain nodes connected to arg
    nodes = matrix[node-1].tolist()
    for i in range(0, len(nodes)):
        if nodes[i] == 1:
            neighborhood.append(i + 1)
    if len(neighborhood) < 2:
        return 0
    connectedness = 0
    for i in range(0, len(neighborhood)):
        j = i + 1
        if j >= len(neighborhood): break;
        for k in range(j, len(neighborhood)):
            if matrix[neighborhood[i]-1][neighborhood[k]-1] == 1: 
                connectedness += 1
    return float( float(connectedness) / float(float(len(neighborhood)*float(len(neighborhood)-1)) / 2) )


# plot ( k, C(k) )
yVals = []
for k in xVals:
    clustCoefSum = 0
    for i in range(0, len(totals)):
        if totals[i] == k:
            clustCoefSum += getClustCoef(i+1)
    yVals.append(float(clustCoefSum / totals.count(k) if totals.count(k) > 0 else 0))
for i in range(0, len(xVals)):
    plt.scatter(xVals[i], yVals[i])
plt.yscale('log', basey=2)
plt.xscale('log', basex=2)
plt.xlabel("k")
plt.ylabel("C(k)")
plt.title("Clustering Coefficient")
plt.show()


