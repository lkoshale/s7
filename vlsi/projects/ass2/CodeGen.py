import os
import sys


interface_mergesort = """ interface MergeSort; 
            method Action take_input(int a,Integer pos);\n 
            method Action set_input_flag();\n 
            method Bit#(1) get_complete(); \n 
            method int get_result(Integer pos);\n \tendinterface"""


interface_oddeven = """ 
interface OddEven;
    method Action take_input_o(int a,Integer pos);
    method Action take_input_e(int a,Integer pos);

    method Action set_input_flag();
    method Bit#(1) get_complete();
    method int get_result(Integer pos);

endinterface
"""

merge_methods_const="""   
    method Action take_input(int a,Integer pos);
        (in_A[pos])<=a;
    endmethod


    method Action set_input_flag();
        flag_in<=1;
    endmethod

    method Bit#(1) get_complete();
        return flag_complete;
    endmethod

"""

oddeven_methods_const="""
    method Action take_input_o(int a,Integer pos);
        (odd[pos])<=a;
    endmethod

    method Action take_input_e(int a,Integer pos);
        (even[pos])<=a;
    endmethod

    method Action set_input_flag();
         flag_in<=1;
    endmethod

    method Bit#(1) get_complete();
        return flag_complete;
    endmethod
        
    method int get_result(Integer pos);
        return readReg(result[pos]);
    endmethod
"""



print(interface_oddeven)

def get_merge(N):
    if(N<1):
        print("Base Case 1 reached not power of 2")
        exit(0)

    str=""
    if(N!=2):
        pass
    else:
        str
    