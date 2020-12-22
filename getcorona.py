import requests
from contextlib import closing
import csv
import time as timeobj
import datetime
from matplotlib import pyplot as plt


time = list()
value = list()
url = "https://raw.githubusercontent.com/jgehrcke/covid-19-germany-gae/master/cases-rki-by-state.csv"
with closing(requests.get(url, stream=True)) as r:
    f = (line.decode('utf-8') for line in r.iter_lines())
    reader = csv.reader(f, delimiter=',', quotechar='"')
    first = True
    
    for row in reader:
        if first:
            first = False
            continue
        else:
            if len(row) > 17:
                time.append(row[0])
                value.append(row[3])  

t_sec = list()

with open('eggs.csv', 'w', newline='') as csvfile:
    spamwriter = csv.writer(csvfile, delimiter=' ',
                            quotechar='|', quoting=csv.QUOTE_MINIMAL)
    for i in range(0, len(time)):
        t = timeobj.mktime(datetime.datetime.strptime(time[i], "%Y-%m-%dT%H:%M:%S+0000").timetuple())
        t_sec.append(t)
        spamwriter.writerow([ str(t), str(value[i]) ])

import numpy 
a = numpy.array(t_sec)
b = numpy.array(value)

plt.plot(a, b)
plt.show()