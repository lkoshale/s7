
import List :: *;
import Vector :: *;
import ConfigReg::*;

typedef 20 N_t;

(* synthesize *)
module mkTb(Empty);
	
	Cla_type#(N_t) c <- add;
	
	Reg#(int) count <- mkReg(0);

//	Int#(32) size_t = 9;
//	Reg#( Bit#(size_t) ) r1 <-mkReg(0);
	
	rule rl1(count<5);
		c.put_a(1,0);
		count<=count+1;
	endrule

	rule rl2(count==5);
		$display(" A at pos 0 is : %d",c.get_a(0));
		$finish(0);
	endrule


endmodule

interface Cla_type#(numeric type n_t);
	method Action put_a(Bit#(1) a,Integer p);
	method Action put_b(Bit#(1) a,Integer p);

	method Bit#(1) get_a(Integer p);

	method Action complete_input();

	// method Action put_b(Bit#(1) b);
//	method Action input_value( Bit#(size_t) a,Bit#(size_t) b);

endinterface


module add(Cla_type#(n_t));

	Integer n = valueOf (n_t);
	Integer n_max = n+1;
	//typedef forbidden encode as bits
//	typedef enum { Kill,Prop,Gen } Cstate deriving(Bits, Eq);

	Reg#(Bit#(1)) flag_input <-mkReg(0);
	Reg#(Bit#(1)) flag_carry <-mkReg(0);

	//sate of carry calculation
	Reg#(Bit#(1)) flag_com_carry <- mkConfigReg(1);
	Reg#(int) carry_init <-mkConfigReg(0);


	Vector #(n_t,Reg#(Bit#(1)) ) in1 <- replicateM( mkReg(0));
	Vector #(n_t,Reg#(Bit#(1)) ) in2 <- replicateM( mkReg(0));

	Vector #(n_t,Reg#(Bit#(1)) ) carry <- replicateM( mkReg(0));
	Vector #(n_t,Reg#(Bit#(1)) ) out <- replicateM( mkReg(0));

	// 1->gen 0->kill, 2->prop
	Reg#(Bit#(2)) carryin <- mkReg(0);
	Vector #(n_t,Reg#(Bit#(2))) carry_st <- replicateM( mkConfigReg(0) );

	///index reg for of next
	Vector #(n_t,Reg#(int)) carry_st_idx <- replicateM(mkConfigReg(0));

	
	//compute the kill prop and gen in one time
	for (Integer i = 0; i < n; i = i+1)
		rule compute_carry_st(flag_input==1 && flag_com_carry==1);
			
			Integer c = n -1;
			int n_in = fromInteger(n_max);
			if(carry_init < n_in)
				begin
					Bit#(1) i1 = readReg(in1[i]);
					Bit#(1) i2 = readReg(in2[i]);
					Integer i_less=i-1;
					if( i1==1 && i2==1)
						(carry_st[i])<=1;
					else if( i1==1 && i2==0)
						(carry_st[i])<=2;
					else if( i1==0 && i2==1)
						(carry_st[i])<=2;
					else
						(carry_st[i])<=0;
					
					if(i==0)
						(carry_st_idx[i])<=fromInteger(n_max);
					else
						(carry_st_idx[i])<=fromInteger(i_less);

					carry_init<= carry_init+1;
				end
			else
				begin
				int a = readReg(carry_st_idx[i]);
				int b = fromInteger(n_max);
				if( a==b )
					begin					
						Bit#(2) ival = carryin;
						Bit#(2) pval = readReg(carry_st[i]);
						if(ival==0 && pval==0)
							(carry_st[i])<=0;
						else if(ival==2 && pval==0)
							(carry_st[i])<= 0;
						else if( ival==1 && pval==0)
							(carry_st[i])<= 1;
						else if( ival==2 && pval==1)
							(carry_st[i])<= 1;
						else if( ival==0 && pval==1)
							(carry_st[i])<= 0;
						else if( ival==1 && pval == 1)
							(carry_st[i])<= 1;
						else if( ival==0 && pval==2)
							(carry_st[i])<= 0;
						else if( ival==1 && pval==2)
							(carry_st[i])<= 1;
						else 
							(carry_st[i])<= 2;
					end
					   
				else 
					begin
						Bit#(2) ival = readReg(carry_st[a] ) ;
						Bit#(2) pval = readReg(carry_st[i]);
						if(ival==0 && pval==0)
							(carry_st[i])<=0;
						else if(ival==2 && pval==0)
							(carry_st[i])<= 0;
						else if( ival==1 && pval==0)
							(carry_st[i])<= 1;
						else if( ival==2 && pval==1)
							(carry_st[i])<= 1;
						else if( ival==0 && pval==1)
							(carry_st[i])<= 0;
						else if( ival==1 && pval == 1)
							(carry_st[i])<= 1;
						else if( ival==0 && pval==2)
							(carry_st[i])<= 0;
						else if( ival==1 && pval==2)
							(carry_st[i])<= 1;
						else 
							(carry_st[i])<= 2;
		
						(carry_st_idx[i])<= readReg( carry_st_idx[a]);
					end
					int lastr = readReg(carry_st_idx[i]);
					if(i==c && lastr == b)
						flag_com_carry<=0;
				
				end

		endrule
	
		/*
	rule check_recursive(flag_com_carry2==1);
		Integer idx = n -1;
		int pt = readReg(carry_st_idx[idx]);
		int b = fromInteger(n_max);
		if(pt ==b)
			flag_com_carry2<=0;
		
	endrule


	for (Integer i = 0; i < n; i = i+1)
		rule recursive_double(flag_com_carry2==1);
			int a = readReg(carry_st_idx[i]);
			int b = fromInteger(n_max);
			Integer c = n -1;
			if( a==b )
				begin					
					Bit#(2) ival = carryin;
					Bit#(2) pval = readReg(carry_st[i]);
					if(ival==0 && pval==0)
						(carry_st[i])<=0;
					else if(ival==2 && pval==0)
						(carry_st[i])<= 0;
					else if( ival==1 && pval==0)
						(carry_st[i])<= 1;
					else if( ival==2 && pval==1)
						(carry_st[i])<= 1;
					else if( ival==0 && pval==1)
						(carry_st[i])<= 0;
					else if( ival==1 && pval == 1)
						(carry_st[i])<= 1;
					else if( ival==0 && pval==2)
						(carry_st[i])<= 0;
					else if( ival==1 && pval==2)
						(carry_st[i])<= 1;
					else 
						(carry_st[i])<= 2;
				end
			       
			else 
				begin
					Bit#(2) ival = readReg(carry_st[a] ) ;
					Bit#(2) pval = readReg(carry_st[i]);
					if(ival==0 && pval==0)
						(carry_st[i])<=0;
					else if(ival==2 && pval==0)
						(carry_st[i])<= 0;
					else if( ival==1 && pval==0)
						(carry_st[i])<= 1;
					else if( ival==2 && pval==1)
						(carry_st[i])<= 1;
					else if( ival==0 && pval==1)
						(carry_st[i])<= 0;
					else if( ival==1 && pval == 1)
						(carry_st[i])<= 1;
					else if( ival==0 && pval==2)
						(carry_st[i])<= 0;
					else if( ival==1 && pval==2)
						(carry_st[i])<= 1;
					else 
						(carry_st[i])<= 2;
	
					(carry_st_idx[i])<= readReg( carry_st_idx[a]);
				end
		endrule
		*/

	// rule add_a_b(flag_carry==1);

	// endrule

	//ival = i+1 , pval = i //point , curval
	
	method Action put_a(Bit#(1) a,Integer p);
		(in1[p])<=a;
	endmethod

	method Action put_b(Bit#(1) a,Integer p);
		(in2[p])<=a;
	endmethod

	method Action complete_input();
		flag_input<=1;
	endmethod


	method Bit#(1) get_a(Integer p);
		return readReg(in1[p]);
	endmethod
	

endmodule