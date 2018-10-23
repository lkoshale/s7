
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


 interface MergeSort; 
            method Action take_input(int a,Integer pos);

            method Action set_input_flag();
            method Bit#(1) get_complete(); 
            method int get_result(Integer pos);
 	endinterface
 
interface OddEven;
    method Action take_input_o(int a,Integer pos);
    method Action take_input_e(int a,Integer pos);

    method Action set_input_flag();
    method Bit#(1) get_complete();
    method int get_result(Integer pos);

endinterface

module merge16(MergeSort);
 
Reg#(Bit#(1)) flag_complete <- mkReg(0);
              Reg#(Bit#(1)) flag_in <- mkConfigReg(0);
              Reg#(Bit#(1)) flag_send_mer <- mkConfigReg(1);
     	Vector #(16, Reg#(int))in_A <- replicateM(mkReg(0));
 MergeSort mL1 <- merge8;
 MergeSort mR1 <- merge8;
OddEven  oe1 <- oE8;

for(Integer i=0;i<8;i=i+1)
rule divide1( flag_in==1);
        mL1.take_input(readReg(in_A[i]),i);
         if(i==7)
	 mL1.set_input_flag();

 	 endrule
for(Integer i=8;i<16;i=i+1)
rule divide2( flag_in==1);
mR1.take_input(readReg(in_A[i]),i-8);
 if(i==15)
	 begin
            mR1.set_input_flag();
            flag_in<=0;            
            end
         endrule
 
        
for(Integer i=0;i<8;i=i+1)
rule eMegre( mL1.get_complete()==1 && mR1.get_complete()==1 && flag_send_mer==1);

        oe1.take_input_o(mL1.get_result(i),i);
        oe1.take_input_e(mR1.get_result(i),i);

        if(i==7)
 begin
            oe1.set_input_flag();
            flag_send_mer<=0;
            $display("In call merge %d %d",mL1.get_result(i),mR1.get_result(i));
            end
        endrule
        
  rule completed( oe1.get_complete==1);
        flag_complete<=1;
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
        return oe1.get_result(pos);
        endmethod
        

        endmodule
        

 module oE8(OddEven);
Vector#(8,Reg#(int))odd <- replicateM(mkReg(0));
Vector#(8,Reg#(int))even <- replicateM(mkReg(0));
 Vector#(16,Reg#(int))result <- replicateM(mkReg(0));
    Reg#(Bit#(1)) flag_complete <- mkReg(0);
            Reg#(Bit#(1)) flag_in <- mkConfigReg(0);
        OddEven oe10 <- oE4;
OddEven oe11 <- oE4;


 for(Integer i=0;i<8;i=i+2)

 rule dive( flag_in==1 );
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
         if(i==6)
begin
            oe10.set_input_flag();
            flag_in<=0;
            end

        endrule
        
for(Integer i=1;i<8;i=i+2)
rule divo( flag_in==1 );
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

         if(i==7)
	 
        begin
            oe11.set_input_flag();
            flag_in<=0;
            end
        endrule
        
  for(Integer i=0;i<8;i=i+1)

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
        
        else if(i!=7)
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
         //   $display("%d %d ",readReg(result[0]),readReg(result[1]));
        end
        
        endrule 
        
        
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

 endmodule 

module merge8(MergeSort);
 
Reg#(Bit#(1)) flag_complete <- mkReg(0);
              Reg#(Bit#(1)) flag_in <- mkConfigReg(0);
              Reg#(Bit#(1)) flag_send_mer <- mkConfigReg(1);
     	Vector #(8, Reg#(int))in_A <- replicateM(mkReg(0));
 MergeSort mL1 <- merge4;
 MergeSort mR1 <- merge4;
OddEven  oe1 <- oE4;

for(Integer i=0;i<4;i=i+1)
rule divide1( flag_in==1);
        mL1.take_input(readReg(in_A[i]),i);
         if(i==3)
	 mL1.set_input_flag();

 	 endrule
for(Integer i=4;i<8;i=i+1)
rule divide2( flag_in==1);
mR1.take_input(readReg(in_A[i]),i-4);
 if(i==7)
	 begin
            mR1.set_input_flag();
            flag_in<=0;            
            end
         endrule
 
        
for(Integer i=0;i<4;i=i+1)
rule eMegre( mL1.get_complete()==1 && mR1.get_complete()==1 && flag_send_mer==1);

        oe1.take_input_o(mL1.get_result(i),i);
        oe1.take_input_e(mR1.get_result(i),i);

        if(i==3)
 begin
            oe1.set_input_flag();
            flag_send_mer<=0;
            $display("In call merge %d %d",mL1.get_result(i),mR1.get_result(i));
            end
        endrule
        
  rule completed( oe1.get_complete==1);
        flag_complete<=1;
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
        return oe1.get_result(pos);
        endmethod
        

        endmodule
        

 module oE4(OddEven);
Vector#(4,Reg#(int))odd <- replicateM(mkReg(0));
Vector#(4,Reg#(int))even <- replicateM(mkReg(0));
 Vector#(8,Reg#(int))result <- replicateM(mkReg(0));
    Reg#(Bit#(1)) flag_complete <- mkReg(0);
            Reg#(Bit#(1)) flag_in <- mkConfigReg(0);
        OddEven oe10 <- oE2;
OddEven oe11 <- oE2;


 for(Integer i=0;i<4;i=i+2)

 rule dive( flag_in==1 );
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
         if(i==2)
begin
            oe10.set_input_flag();
            flag_in<=0;
            end

        endrule
        
for(Integer i=1;i<4;i=i+2)
rule divo( flag_in==1 );
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

         if(i==3)
	 
        begin
            oe11.set_input_flag();
            flag_in<=0;
            end
        endrule
        
  for(Integer i=0;i<4;i=i+1)

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
         //   $display("%d %d ",readReg(result[0]),readReg(result[1]));
        end
        
        endrule 
        
        
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

 endmodule 

module merge4(MergeSort);
 
Reg#(Bit#(1)) flag_complete <- mkReg(0);
              Reg#(Bit#(1)) flag_in <- mkConfigReg(0);
              Reg#(Bit#(1)) flag_send_mer <- mkConfigReg(1);
     	Vector #(4, Reg#(int))in_A <- replicateM(mkReg(0));
 MergeSort mL1 <- merge2;
 MergeSort mR1 <- merge2;
OddEven  oe1 <- oE2;

for(Integer i=0;i<2;i=i+1)
rule divide1( flag_in==1);
        mL1.take_input(readReg(in_A[i]),i);
         if(i==1)
	 mL1.set_input_flag();

 	 endrule
for(Integer i=2;i<4;i=i+1)
rule divide2( flag_in==1);
mR1.take_input(readReg(in_A[i]),i-2);
 if(i==3)
	 begin
            mR1.set_input_flag();
            flag_in<=0;            
            end
         endrule
 
        
for(Integer i=0;i<2;i=i+1)
rule eMegre( mL1.get_complete()==1 && mR1.get_complete()==1 && flag_send_mer==1);

        oe1.take_input_o(mL1.get_result(i),i);
        oe1.take_input_e(mR1.get_result(i),i);

        if(i==1)
 begin
            oe1.set_input_flag();
            flag_send_mer<=0;
            $display("In call merge %d %d",mL1.get_result(i),mR1.get_result(i));
            end
        endrule
        
  rule completed( oe1.get_complete==1);
        flag_complete<=1;
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
        return oe1.get_result(pos);
        endmethod
        

        endmodule
        

 module oE2(OddEven);
Vector#(2,Reg#(int))odd <- replicateM(mkReg(0));
Vector#(2,Reg#(int))even <- replicateM(mkReg(0));
 Vector#(4,Reg#(int))result <- replicateM(mkReg(0));
    Reg#(Bit#(1)) flag_complete <- mkReg(0);
            Reg#(Bit#(1)) flag_in <- mkConfigReg(0);
        OddEven oe10 <- oE1;
OddEven oe11 <- oE1;


 for(Integer i=0;i<2;i=i+2)

 rule dive( flag_in==1 );
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
         if(i==0)
begin
            oe10.set_input_flag();
            flag_in<=0;
            end

        endrule
        
for(Integer i=1;i<2;i=i+2)
rule divo( flag_in==1 );
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

         if(i==1)
	 
        begin
            oe11.set_input_flag();
            flag_in<=0;
            end
        endrule
        
  for(Integer i=0;i<2;i=i+1)

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
        
        else if(i!=1)
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
         //   $display("%d %d ",readReg(result[0]),readReg(result[1]));
        end
        
        endrule 
        
        
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

 endmodule 


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

