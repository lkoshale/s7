import os
import sys


interface_mergesort = """ interface MergeSort; 
            method Action take_input(int a,Integer pos);

            method Action set_input_flag();
            method Bit#(1) get_complete(); 
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

merge2="""
module merge2(MergeSort);

    Reg#(Bit#(1)) flag_complete <- mkReg(0);
    Vector #(2, Reg#(int))in_A <- replicateM(mkReg(0));
    Reg#(Bit#(1)) flag_in <- mkConfigReg(0);

    rule csw(flag_in==1);
        int a = readReg(in_A[0]);
        int b = readReg(in_A[1]);
        if(a<b)
            begin
                (in_A[0])<=a;
                (in_A[1])<=b;
            end
        else
            begin
                (in_A[0])<=b;
                (in_A[1])<=a;
            end
        
        flag_complete<=1;
        flag_in<=0;

        $display("merge2 %d %d",a,b);

    endrule

    method Action take_input(int a,Integer pos);
        (in_A[pos])<=a;
    endmethod


    method Action set_input_flag();
        flag_in<=1;
    endmethod

    method Bit#(1) get_complete();
        return flag_complete;
    endmethod


    method int get_result(Integer pos);
        return readReg(in_A[pos]);
    endmethod

endmodule
"""

oddeven00="""
module oE1(OddEven);

    Reg#(int) o <- mkReg(0);
    Reg#(int) e <- mkReg(0);

    Reg#(Bit#(1)) flag_complete <- mkReg(0);
    Reg#(Bit#(1)) flag_in <- mkConfigReg(0);

    Vector#(2,Reg#(int))result <- replicateM(mkReg(0));
    
    rule cmsp(flag_in==1);
        if(o<e)
            begin
                (result[0])<=o;
                (result[1])<=e;
            end
        else    
            begin
                (result[0])<=e;
                (result[1])<=o;
            end

        flag_in<=0;
        flag_complete<=1;
    //    $display("oE00 %d %d",o,e);

    endrule

    method Action take_input_o(int a,Integer pos);
        o<=a;
    endmethod

    method Action take_input_e(int a,Integer pos);
        e<=a;
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


endmodule
"""


def gen_merge_start(N):
    str="module merge{}(MergeSort);\n".format(N)
    str+=""" \nReg#(Bit#(1)) flag_complete <- mkReg(0);
              Reg#(Bit#(1)) flag_in <- mkConfigReg(0);
              Reg#(Bit#(1)) flag_send_mer <- mkConfigReg(1);
    """

    str+=" \tVector #({}, Reg#(int))in_A <- replicateM(mkReg(0));\n".format(N)

    str+=" MergeSort mL1 <- merge{};\n MergeSort mR1 <- merge{};\n".format(N//2,N//2)

    str+="OddEven  oe1 <- oE{};\n".format(N//2)

    return str


def gen_merge_divides(N):
    str="for(Integer i=0;i<{};i=i+1)\n".format(N//2)
    str+="""rule divide1( flag_in==1);
        mL1.take_input(readReg(in_A[i]),i);
        """
    str+=" if(i=={})\n\t mL1.set_input_flag();\n".format( (N//2)-1)
    str+="\n \t endrule\n"

    str+="for(Integer i={};i<{};i=i+1)\n".format(N//2,N)
    
    str+="rule divide2( flag_in==1);\n"
    str+="mR1.take_input(readReg(in_A[i]),i-{});\n".format(N//2)
    str+=" if(i=={})\n".format(N-1)
    str+="""\t begin
            mR1.set_input_flag();
            flag_in<=0;            
            end
         endrule\n 
        """
    return str


def gen_merge_end(N):
    str="for(Integer i=0;i<{};i=i+1)\n".format(N//2)
    str+="""rule eMegre( mL1.get_complete()==1 && mR1.get_complete()==1 && flag_send_mer==1);

        oe1.take_input_o(mL1.get_result(i),i);
        oe1.take_input_e(mR1.get_result(i),i);

        """
    str+="if(i=={})".format((N//2)-1)
    str+="""\n begin
            oe1.set_input_flag();
            flag_send_mer<=0;
            $display("In call merge %d %d",mL1.get_result(i),mR1.get_result(i));
            end
        endrule
        """

    str+="""\n  rule completed( oe1.get_complete==1);
        flag_complete<=1;
        endrule
        """
    str+=merge_methods_const
    str+="""\n method int get_result(Integer pos);
        return oe1.get_result(pos);
        endmethod
        \n
        endmodule
        """
    return str



def odd_even_start(N):
    str="\n module oE{}(OddEven);\n".format(N)
    str+="Vector#({},Reg#(int))odd <- replicateM(mkReg(0));\n".format(N)
    str+="Vector#({},Reg#(int))even <- replicateM(mkReg(0));\n".format(N)
    str+=" Vector#({},Reg#(int))result <- replicateM(mkReg(0));\n".format(N*2)
    
    str+="""    Reg#(Bit#(1)) flag_complete <- mkReg(0);
            Reg#(Bit#(1)) flag_in <- mkConfigReg(0);
        """

    str+="OddEven oe10 <- oE{};\n".format(N//2)
    str+="OddEven oe11 <- oE{};\n".format(N//2)

    return str


def odd_even_body(N):
    str="\n for(Integer i=0;i<{};i=i+2)\n".format(N)
    str+="""\n rule dive( flag_in==1 );
        if(i>0)
            begin
                Integer k = div(i,2);
                oe10.take_input_o(readReg(odd[i]),k);
                oe10.take_input_e(readReg(even[i]),k); 
            end
        else
            begin
                oe10.take_input_o(readReg(odd[i]),0);
                oe10.take_input_e(readReg(even[i]),0);
            end
        """
    
    str+=" if(i=={})\n".format(N-2)
    str+="""begin
            oe10.set_input_flag();
            flag_in<=0;
            end

        endrule
        """

    str+="\nfor(Integer i=1;i<{};i=i+2)\n".format(N)
    str+="""rule divo( flag_in==1 );
        if(i>1)
            begin
                Integer k = div((i-1),2);
                oe11.take_input_o(readReg(odd[i]),k);
                oe11.take_input_e(readReg(even[i]),k); 
            end
        else
            begin
               oe11.take_input_o(readReg(odd[i]),0);
               oe11.take_input_e(readReg(even[i]),0);   
            end

        """
    str+=" if(i=={})\n".format(N-1)
    str+= """\t 
        begin
            oe11.set_input_flag();
            flag_in<=0;
            end
        endrule
        """

    str+="\n  for(Integer i=0;i<{};i=i+1)\n".format(N)
    str+="""
        rule meg( oe10.get_complete()==1 && oe11.get_complete()==1 );
        if(i==0)
            begin
            (result[0])<=oe10.get_result(0);
            int o = oe10.get_result(1);
            int e = oe11.get_result(0);
            if(o<e)
                begin
                (result[1])<=o;
                (result[2])<=e;
                end
            else
                begin
                (result[1])<=e;
                (result[2])<=o;
                 end
            end
        
        """
    str+="else if(i!={})\n".format(N-1)
    str+=""" begin
                int o = oe10.get_result(i+1);
                int e = oe11.get_result(i);
                Integer l = 2*i+1;
                Integer r = 2*i+2;
                if(o<e)
                    begin
                    (result[l])<=o;
                    (result[r])<=e;
                    end
                else
                    begin
                    (result[l])<=e;
                    (result[r])<=o;
                    end

            end

        """

    str+="""
        else
            begin
            Integer l = 2*i+1;
            (result[l])<=oe11.get_result(i);
            flag_complete<=1;           //completed
         //   $display("%d %d ",readReg(result[0]),readReg(result[1]));
        end
        
        endrule 
        
        """

    str+=oddeven_methods_const
    str+="\n endmodule \n"

    return str


def gen_merge(N):
    str=gen_merge_start(N)
    str+="\n"+gen_merge_divides(N)
    str+="\n"+gen_merge_end(N)
    return str

def gen_oddeven(N):
    str=odd_even_start(N)
    str+="\n"+odd_even_body(N)
    return str


testbench="""
import Vector::*;
import ConfigReg::*;


//for 4

(* synthesize *)
module mkTb(Empty);

    Vector#(3,Integer)vec = genVector();
    let m_vec = cons(4, vec);

    MergeSort m2 <- merge4;
    Reg#(Bit#(1))flag_in <-mkConfigReg(1); 

    for(Integer i=0;i<4;i=i+1)
    rule rl1(flag_in==1);
        int a = fromInteger(m_vec[i]);
        m2.take_input(a,i);

        if(i==3)
            begin
                flag_in<=0;
                m2.set_input_flag();
            end
    endrule

    rule r2(m2.get_complete()==1);
        $display("Vec %d %d  %d %d to  %d %d %d %d",m_vec[0],m_vec[1],m_vec[2],m_vec[3],m2.get_result(0),m2.get_result(1),m2.get_result(2),m2.get_result(3));
        $finish(0);
    endrule


endmodule

"""



def print_help(N):
    print(testbench)
    print(interface_mergesort)
    print(interface_oddeven)
    
    if N>2:
        x=N
        while x>2:
            print(gen_merge(x))
            print(gen_oddeven(x//2))
            x=x//2
    
    print(merge2)
    print(oddeven00)

print_help(16)

