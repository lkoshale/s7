
import Vector::*;
import ConfigReg::*;


//for 2

(* synthesize *)
module mkTb(Empty);

    Vector#(1,Integer)vec = genVector();
    let m_vec = cons(4, vec);

    MergeSort m2 <- merge2;
    Reg#(Bit#(1))flag_in <-mkConfigReg(1); 

    for(Integer i=0;i<2;i=i+1)
    rule rl1(flag_in==1);
        int a = fromInteger(m_vec[i]);
        m2.take_input(a,fromInteger(i));

        if(i==1)
            begin
                flag_in<=0;
                m2.set_input_flag();
            end
    endrule

    rule r2(m2.get_complete()==1);
        $display("Vec %d %d to  %d %d",m_vec[0],m_vec[1],m2.get_result(0),m2.get_result(1));
        $finish(0);
    endrule


endmodule


interface MergeSort;
    method Action take_input(int a,int pos);   //array to sort

    method Action set_input_flag();
    method Bit#(1) get_complete();
    method int get_result(int pos);

endinterface

interface OddEven;
    method Action take_input_o(int a,int pos);
    method Action take_input_e(int a,int pos);

    method Action set_input_flag();
    method Bit#(1) get_complete();
    method int get_result(int pos);

endinterface

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
    endrule

    method Action take_input(int a,int pos);
        (in_A[pos])<=a;
    endmethod


    method Action set_input_flag();
        flag_in<=1;
    endmethod

    method Bit#(1) get_complete();
        return flag_complete;
    endmethod


    method int get_result(int pos);
        return readReg(in_A[pos]);
    endmethod

endmodule