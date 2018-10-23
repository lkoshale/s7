

import Vector::*;


//for 8

(* synthesize *)
module mkTb(Empty);

    rule rl1;
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


module sort(MergeSort);

    Reg#(int) count_in <-mkReg(0);
    Reg#(Bit#(1)) flag_complete <- mkReg(0);
    Vector #(8, Reg#(int))in_A <- replicateM(mkReg(0));
    Reg#(Bit#(1)) flag_in <- mkReg(0);


    MergeSort mL1 <- mergeL1;
    MergeSort mR1 <- mergeR1;
    OddEven  odev1 <- oE1;

    for(Integer i=0;i<4;i=i+1);
    rule divide1(count_in>2 && flag_in==1);
        mergeL1.take_input(readReg(in_A[i]),i);
        if(i==3)
            mergeL1.set_input_flag();
    endrule

    for(Integer i=4;i<8;i=i+1)
    rule divide2(count_in>2 && flag_in==1);
        mergeR1.take_input(readReg(in_A[i],i-3);
        if(i==7)
            mergeR1.set_input_flag();
    endrule

    for(Integer i=0;i<8;i=i+2)
    rule eMegre( mergeL1.get_complete()==1 && mergeR1.get_complete()==1);
        if(i>0)
            begin
                Integer k = div(i,2);
                oE1.take_input_o(readReg(in_A[i],k); 
            end
        else
            oE1.take_input_o(readReg(in_A[i]),0);
        
    endrule

    for(Integer i=1;i<8;i=i+2)
    rule oMerge( mergeL1.get_complete()==1 && mergeR1.get_complete()==1);
        if(i>1)
            begin
                Integer k = div((i-1),2);
                oE1.take_input_e(readReg(in_A[i],k); 
            end
        else
            oE1.take_input_e(readReg(in_A[i]),0);    

        if(i==7)
            oE1.set_input_flag();

    endrule



    method Action take_input(int a,int pos);
            (in_A[pos])<=a;
            count_in<=count_in+1;
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

module mergeL1(MergeSort);

    Reg#(int) count_in <-mkReg(0);
    Reg#(Bit#(1)) flag_complete <- mkReg(0);
    Vector #(4, Reg#(int))in_A <- replicateM(mkReg(0));
    Reg#(Bit#(1)) flag_in <- mkReg(0);





    method Action take_input(int a,int pos);
            (in_A[pos])<=a;
            count_in<=count_in+1;
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


module mergeL1(MergeSort);
    Reg#(int) count_in <-mkReg(0);
    Reg#(Bit#(1)) flag_complete <- mkReg(0);
    Vector #(4, Reg#(int))in_A <- replicateM(mkReg(0));
    Reg#(Bit#(1)) flag_in <- mkReg(0);





    method Action take_input(int a,int pos);
            (in_A[pos])<=a;
            count_in<=count_in+1;
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

module oE1(OddEven);

    Vector#(4,Reg#(int))odd <- replicateM(mkReg(0));
    Vector#(4,Reg#(int))even <- replicateM(mkReg(0));

    Vector#(8,Reg#(int))result <- replicateM(mkReg(0));
    Reg#(Bit#(1)) flag_complete <- mkReg(0);
    Reg#(Bit#(1)) flag_in <- mkReg(0);

    OddEven oe10 <- oE10;
    OddEven oe11 <- oE11;


    //all even value
    for(Integer i=0;i<4;i=i+2)
    rule dive( flag_in==1 );
        if(i>0)
            begin
                Integer k = div(i,2);
                oe10.take_input_o(readReg(odd[i]),k);
                oe10.take_input_e(readReg(even[i],k); 
            end
        else
            begin
                oe10.take_input_o(readReg(odd[i]),0);
                oe10.take_input_e(readReg(even[i],0);
            end
        
        if(i==2)
            oe10.set_input_flag();
        
    endrule

    for(Integer i=1;i<4;i=i+2)
    rule divo( flag_in==1 );
        if(i>1)
            begin
                Integer k = div((i-1),2);
                oe11.take_input_o(readReg(odd[i]),k);
                oe11.take_input_e(readReg(even[i],k); 
            end
        else
            begin
               oe11.take_input_o(readReg(odd[i]),0);
               oe11.take_input_e(readReg(even[i]),0);   
            end

        if(i==3)
            oe11.set_input_flag();

    endrule

    for(Integer i=0;i<4;i=i+1);
    rule meg( oe10.get_complete()==1 && oe11.get_complete()==1);
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
        else if(i!=3)
            begin
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
        else
            begin
            Integer l = 2*i+1;
            (result[l])<=oe11.get_result(i);
            flag_complete<=1;           //completed
            end
    endrule 

    method Action take_input_o(int a,int pos);
        (odd[pos])<=a;
    endmethod

    method Action take_input_e(int a,int pos);
        (even[pos])<=a;
    endmethod

    method Action set_input_flag();
        return flag_in;
    endmethod

    method Bit#(1) get_complete();
        return flag_complete;
    endmethod
        
    method int get_result(int pos);
        return readReg(result[pos]);
    endmethod

endmodule