#!/usr/bin/python

import matplotlib as mpl
mpl.use('SVG')
import matplotlib.pyplot as plt
import csv

data = []
column_names = [
    'newline',
    'word',
    'character',
    'byte',
    'maximum line length',
    'chapter'
]

with open('stats/data.csv') as f:
    reader = csv.DictReader(f,  fieldnames=column_names)
    for row in reader:
        data.append(row)


for col in column_names[:-1]:
    fig = plt.figure()
    ax = fig.add_subplot(111)
    hist_data = [int(x[col]) for x in data]
    ax.hist(hist_data, bins='auto')
    plt.title(col)
    fig.savefig('stats/' + col + '.svg')
