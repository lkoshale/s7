import sys
import random
import time
from random import shuffle


random.seed(int(time.time()))


inList = input().strip().split(" ")
inList = [ int(x) for x in inList]
per = float(input())


Size = 1
for x in inList[1:]:
    Size*=x

for x in inList:
    print("{} ".format(x),end=" ")

extent = list(range(0,inList[0]))
shuffle(extent)

for x in extent:
    print("{} ".format(x),end=" ")

print()

random.seed(0)

for i in range(0,Size):
    r = random.randint(0,100)
    if r <= per:
        print("0 ",end=" ")
    else:
        y = random.randint(1,1000000)
        print("{} ".format(y),end=" ")


print()


