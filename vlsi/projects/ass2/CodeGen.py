import os
import sys


interface_mergesort = "interface MergeSort; method Action take_input(int a,Integer pos);\n method Action set_input_flag();\n method Bit\#(1) get_complete(); \n method int get_result(Integer pos);\n endinterface"





def get_merge(N):
    if(N<1):
        print("Base Case 1 reached not power of 2")
        exit(0)

    str=""
    if(N!=2):
        pass
    else:
        str
    