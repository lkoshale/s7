
import List :: *;
import Vector :: *;
import ConfigReg::*;

typedef 5 N_t;
typedef 10 N_w;

(* synthesize *)
module mkTb(Empty);
	
	Cla_type#(N_w) c <- add;				//change to N_w

	Wallace_t#(N_t,N_w) m <- mul;

	Integer n = valueOf(N_t);
	
	Reg#(int) iter_c <- mkReg(fromInteger(n));


	Reg#(int) count <- mkReg(0);
	Reg#(Bit#(5)) a_in <- mkReg(5);
	Reg#(Bit#(5)) b_in <- mkReg(3);

	Reg#(Bit#(1)) flag_display <-mkReg(0);

//	Int#(32) size_t = 9;
//	Reg#( Bit#(size_t) ) r1 <-mkReg(0);
	

	rule rl1(count<iter_c);
		Bit#(1) a_bit = a_in[count];
		Bit#(1) b_bit = b_in[count];
		c.put_a(a_bit,count);
		c.put_b(b_bit,count);
		count<=count+1;
	endrule


	rule rl2(count==iter_c);
		c.complete_input();
		count<=count+1;
	endrule


	rule rl3( c.complete_output() == 1);
		flag_display<=1;
	endrule

	rule disp1( flag_display==1);
		$display(" A is %d%d%d%d%d",c.get_a(4),c.get_a(3),c.get_a(2),c.get_a(1),c.get_a(0));
		$display(" B is %d%d%d%d%d",c.get_b(4),c.get_b(3),c.get_b(2),c.get_b(1),c.get_b(0));
		$display(" Carry is %d%d%d%d%d",c.get_carry2(4),c.get_carry2(3),c.get_carry2(2),c.get_carry2(1),c.get_carry2(0));
		$display(" C is %d%d%d%d%d",c.get_c(4),c.get_c(3),c.get_c(2),c.get_c(1),c.get_c(0));
		$display(" idx is %d %d %d %d %d",c.get_idx(4),c.get_idx(3),c.get_idx(2),c.get_idx(1),c.get_idx(0));

		$finish(0);
	endrule


	// for (Integer i = 0; i < n; i = i+1)
	// 	rule disp(flag_display==1);
	// 		$display("bit at pos %d is %d",i,c.get_c(i));
	// 	endrule


endmodule


interface Wallace_t#(numeric type n_t,numeric type n_w);
	method Action put_A(Bit#(1) a,int p);
	method Action put_B(Bit#(1) a,int p);

	method Bit#(1) get_complete();

	method Bit#(1) get_SA( int p);
	method Bit#(1) get_SB( int p);

endinterface



interface Cla_type#(numeric type n_t);
	method Action put_a(Bit#(1) a,int p);
	method Action put_b(Bit#(1) a,int p);

	method Bit#(1) get_c(Integer p);
	method Bit#(1) get_a(Integer p);
	method Bit#(1) get_b(Integer p);
	method Bit#(1) get_carry(Integer p);
	method int get_idx(Integer p);
	
	
	
	method int get_init_count();
	method Bit#(2) get_carry2(Integer p);
	

	method Action complete_input();

	method Bit#(1) complete_output();

endinterface


module add(Cla_type#(n_t));


	Integer n = valueOf (n_t);
	Integer n_max = n+1;

	Reg#(int) value_nmax <- mkReg(fromInteger(n_max));
	//typedef forbidden encode as bits
	//typedef enum { Kill,Prop,Gen } Cstate deriving(Bits, Eq);

	Reg#(Bit#(1)) flag_input <-mkReg(0);

	//sate of carry calculation
	Reg#(Bit#(1)) flag_com_carry <- mkConfigReg(1);
	Reg#(int) carry_init <-mkConfigReg(0);

	Reg#(int) count_comp <-mkConfigReg(0);
	Reg#(Bit#(1)) flag_complete <-mkReg(0);


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
			int n_in = fromInteger(n);
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
						Bit#(2) ival = readReg(carry_st[i]);
						Bit#(2) pval = carryin;
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
						Bit#(2) ival = readReg(carry_st[i]);
						Bit#(2) pval = readReg(carry_st[a] ) ;
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


	for (Integer i = 0; i < n; i = i+1)		
		rule add_final( flag_com_carry==0 && count_comp < value_nmax);
			Integer idx = i-1;
			Bit#(1) out_a = readReg(in1[i]) ^ readReg(in2[i]);
			if(i==0)
				begin
					Bit#(2) c_f = carryin;
					(out[i])<= out_a ^ c_f[0];
					count_comp<=count_comp+1;
				end
			else
				begin
					Bit#(2) c_f = readReg(carry_st[idx]);
					(out[i])<= out_a ^ c_f[0];
					count_comp<=count_comp+1;
				end
						
		endrule
	
	
	rule flag_set_complete( count_comp == value_nmax );
		flag_complete<=1;
	endrule


	method Bit#(1) complete_output();
		return flag_complete;
	endmethod


	method int get_init_count();
		return carry_init;
	endmethod

	method Action put_a(Bit#(1) a,int p);
		(in1[p])<=a;
	endmethod

	method Action put_b(Bit#(1) a,int p);
		(in2[p])<=a;
	endmethod

	method Action complete_input();
		flag_input<=1;
	endmethod


	method Bit#(1) get_c(Integer p);
		return readReg(out[p]);
	endmethod

	method Bit#(1) get_a(Integer p);
		return readReg(in1[p]);
	endmethod
	
	method Bit#(1) get_b(Integer p);
		return readReg(in2[p]);
	endmethod
	
	method Bit#(1) get_carry(Integer p);
		Bit#(2) b = readReg(carry_st[p]);
		return b[0];
	endmethod



	method Bit#(2) get_carry2(Integer p);
		Bit#(2) b = readReg(carry_st[p]);
		return b;
	endmethod

	method int get_idx(Integer p);
		return readReg(carry_st_idx[p] );
	endmethod
	

	
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
	

endmodule


module mul(Wallace_t#(n_t,n_w));

	Integer n = valueOf (n_t);
	Integer nw = valueOf(n_w);
	Integer n_max = nw-1;


	Reg#(int) final_r <- mkReg( fromInteger(n) );
	Reg#(int) count <- mkReg(0);
	Reg#(int) indx <- mkReg(0);
	Reg#( Bit#(1)) swt <- mkConfigReg(0);
	Reg#(int) w_idx <-mkReg(0);

	Reg#(Bit#(1)) flag_pad1 <-mkConfigReg(0);
	Reg#(Bit#(1)) flag_pad2 <-mkConfigReg(0);



	Reg#(Bit#(1)) flag_input <-mkReg(0);
	Reg#(Bit#(2)) flag_pp <- mkConfigReg(1);

	Reg#(Bit#(1)) flag_cry <- mkConfigReg(0);

	Vector #(n_t,Reg#(Bit#(1)) ) in1 <- replicateM( mkReg(0));
	Vector #(n_t,Reg#(Bit#(1)) ) in2 <- replicateM( mkReg(0));


	//vector of length 2*n
	Vector #(n_t, Vector#( n_w,Reg#(Bit#(1))) ) partialp <- replicateM( replicateM(mkConfigReg(0) ) );

	Reg#(Bit#(1)) flag_complete <- mkReg(0);

	for (Integer i = 0; i < n; i = i+1)	
		for (Integer j = i; j < i+n; j = j+1)
			rule gen_pp(flag_input==1  && flag_pp>0);
				Bit#(1) b = in2[j-i];
				Bit#(1) a = in1[j-i];
				if(b==0)
					(partialp[i][j])<=0;
				else
					(partialp[i][j])<=a;
				
				if(i==n && j==2*n-1)
					flag_pp<=flag_pp-1;
					
			endrule

	for (Integer i = 0; i < nw; i = i+1)	
	rule clac_sum_carry( flag_pp==0 && swt ==1 && flag_cry==0);
		Bit#(1) a = 0;
		Bit#(1) b = 0;
		Bit#(1) c = 0;
		int w_i = w_idx;
		int w_i1 = w_i+1;
		if( flag_pad1==0 && flag_pad2==0)
			begin
				int id1 = indx+1;
				int id2 = indx+2;
				a = readReg( partialp[indx][i] );
				b = readReg( partialp[id1][i] );
				c = readReg( partialp[id2][i]);
			end
		else if( flag_pad1==0 && flag_pad2==1)
			begin
				int id1 = indx+1;
				a = readReg( partialp[indx][i] );
				b = readReg( partialp[id1][i] );
			end
		else if( flag_pad1==1 && flag_pad2==1)
			begin
				a = readReg( partialp[indx][i] );
			end

		(partialp[w_i][i])<= a ^ b ^ c;
			
		Bit#(1) ab = a & b;
		Bit#(1) bc = b & c;
		Bit#(1) ca = c & a;
		Bit#(1) crry = ab | bc | ca;

		
		(partialp[w_i1][i])<=crry;
			
		swt<=0;
		flag_cry<=1;
	
	endrule

	//shift
	for (Integer i = nw-1; i > 0; i = i-1)
	rule shiftcry(flag_pp==0 && swt==0 && flag_cry==1);
		int w_i1 = w_idx+1;
		Bit#(1) val = readReg( partialp[w_i1][i-1]);
		(partialp[w_i1][i])<=val;
		flag_cry<=0;
	endrule



	rule map_to_idx( flag_pp==0 && final_r > fromInteger(2) && swt==0 && flag_cry==0);
		
		int w_i1 = w_idx+1;
		(partialp[w_i1][0])<=0;
		
		int idxa3 = indx;

		if(count > 0 && idxa3<final_r)
			begin
			indx<=indx+3;
			w_idx<=count;
			count<=count+2;
			end
		else if( count > 0)
			begin
				final_r<=count;
				count<=2;
				w_idx<=0;
				indx<=0;
			end
		else
			count<=count+2;		//first
	
		
		int n_i = final_r;
		int id2 = indx+1;
		int id3 = indx+2;
	
		
		if(id2 < n_i && id3 < n_i)
			begin
			flag_pad1<=0;
			flag_pad2<=0;
			end
		else if( id2 < n_i)
			begin
			flag_pad2<=1;
			end
		else
			begin
			flag_pad1<=1;
			flag_pad2<=1;
			end
		
		if(final_r > fromInteger(2))
			swt<=1;
		
		
	endrule


	rule endfn( final_r ==2);
		flag_complete<=1;
	endrule


	method Bit#(1) get_complete();
		return flag_complete;
	endmethod


	method Action put_A(Bit#(1) a,int p);
		(in1[p])<=a;
	endmethod

	method Action put_B(Bit#(1) a,int p);
		(in2[p])<=a;
	endmethod


	method Bit#(1) get_SA( int p);
		Bit#(1) b =  readReg(partialp[0][p]);
		return b;
	endmethod
	
	method Bit#(1) get_SB( int p);
		Bit#(1) b =  readReg(partialp[1][p]);
		return b;
	endmethod

endmodule

