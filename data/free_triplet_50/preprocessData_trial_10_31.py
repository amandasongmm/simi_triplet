# -*- coding: utf-8 -*-
"""
Created on Sat Oct 31 16:59:29 2015

@author: amand_000
"""

import csv
from scipy.io import savemat
from numpy import array


with open('triplet.csv','rb') as f:
    reader = csv.reader(f)
    for row in reader:
        pass  
        #print row
    
######
data = []
with open('triplet.csv', 'r') as f:
    for line in f:
        line = line.strip().split(',')
        if line[10].startswith('http'):
            line[10] = line[11]
            line[11] = line[12]
            line[12] = line[13]
            line[13] = line[14]
            line[14] = line[15]
            line = line[:-1]
        data.append(line)
raw_results = [
    [entry[8][10:],
     entry[9][10:],
     entry[12][10:],
     entry[13][10:],
     entry[14][10:]] for entry in data
]

results = []
for entry in raw_results:
    ij_items = entry[:2]
    ijk_items = entry[2:]
    k_item = None
    for item in ijk_items:
        if item not in ij_items:
            k_item = item
            break
    if not k_item:
        print ij_items, ijk_items
        continue
    two_result = [
        [ij_items[0], ij_items[1], k_item],
        [ij_items[1], ij_items[0], k_item]
    ]
    results.extend(two_result)


with open('faceTriplet.csv', 'w') as f:
    for result in results:
        f.write(','.join(result) + '\n')

#savemat('testSave',result)