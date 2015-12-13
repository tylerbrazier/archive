#!/usr/bin/python3

# Used for my final project in data mining. This produces datasets in .arff 
# format to be used by weka. 

import sys
import random as rand

# tolerance is the max difference between values of the same attribute that
# all the instances of a cluster can have. so for example, if tolerance is 5
# and class 1 and class 2 are in a cluster, then for each attribute, class 1's
# value of that attribute can be no more than 5 away from class 2's value for
# that attribute
tolerance = 5  
numDimensions = 3
clusterSizes = [ 4, 7, 4, 2, 5, 6, 9 ]
maxDimValue = 100


class Object:
    def __init__(self):
        self.attrs = []

class Cluster:
    def __init__(self, objects):
        "objects arg should be a list of Objects"
        self.objects = objects


# build clusters
clusters = []
for i in range(0, len(clusterSizes)):
    clusters.append(Cluster( [Object() for j in range(0, clusterSizes[i])] ))
for clust in clusters:
    for attr in range(0, numDimensions):
        baseNum = rand.randrange(0, maxDimValue)
        for obj in clust.objects:
            posNeg = rand.choice([1,-1])
            obj.attrs.append(baseNum + (tolerance*rand.random())*posNeg)
            

# write to file
filename = "/home/tyler/Desktop/custom.arff"
f = open(filename, "w")
f.write("@relation custom\n")
for i in range(0, numDimensions):
    f.write("@attribute dim" + str(i) + " real\n")
f.write("@attribute class {0")
for i in range(1, len(clusterSizes)):
    f.write(","+str(i))
f.write("}\n")
f.write("@data\n")
for i in range(0, len(clusters)):
    for obj in clusters[i].objects:
        for attr in obj.attrs:
            f.write(str(attr) + ",")
        f.write(str(i) + "\n")
f.close()
