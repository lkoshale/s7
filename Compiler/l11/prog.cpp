
#include <iostream>
#include <stdio.h>
#include <vector>
#include <cstdlib>
#include <map>
#include <utility> 
#include <set>

using namespace std;

map<int, set<char> >Live;

class Node{
public:
	char val;
	vector< pair<int,int> > ranges;

	Node(char ch){
		val=ch;
	}

	void addRange(int start,int end){
		pair<int,int> p;
		p.first = start;
		p.second = end;

		ranges.push_back(p);
	}


};



void makeLive(map<char,Node*>graph){
	map<char,Node*>:: iterator itr;

	for( itr=graph.begin();itr!=graph.end();itr++)
	{	
		Node* n1 = (*itr).second;
		for(int i=0;i<n1->ranges.size();i++){
			
			pair<int,int>p1 = n1->ranges[i];
			map<char,Node*>:: iterator it2;
			for( it2=graph.begin();it2!=graph.end();it2++){
				
				Node* n2 = (*it2).second;
				if(n1->val==n2->val)
					continue;

				for(int j=0;j<n2->ranges.size();j++){
					pair<int,int>p2 = n2->ranges[j];
					if(p1.first <= p2.first){
						
						if(p2.first <= p1.second  ){
							map<int,set<char>>::iterator sitr;
		
							sitr=Live.find(p2.first);
							if(sitr!=Live.end()){
								(*sitr).second.insert(n1->val);
							}
							else{
								set<char>temp;
								temp.insert(n1->val);
								Live.insert(pair<int,set<char>>(p2.first,temp));
							}
						}
						
						if( p2.second <= p1.second){
							map<int,set<char>>::iterator sitr;
							sitr=Live.find(p2.second);
							if(sitr!=Live.end()){
								(*sitr).second.insert(n1->val);
							}
							else{
								set<char>temp;
								temp.insert(p2.second);
								Live.insert(pair<int,set<char>>(p2.second,temp));
							}

						}
					}
					
					
				}
			}
		}
	}
}


void printLive(){
	map<int,set<char>>::iterator sitr;
	for(sitr=Live.begin();sitr!=Live.end();sitr++){
		cout<<(*sitr).first<<" ";
		set<char>st = (*sitr).second;
		set<char>::iterator itr;
		
		for(itr=st.begin();itr!=st.end();itr++){
			cout<<*itr<<" ";
		}

		cout<<"\n";
	}
}

pair<char,int> checkSpill(map<char,int>regs,set<char>lvar){
	map<char,int>::iterator mr;

	char ch='0';
	int regval=-1;
	//for all var in alloc
	for(mr=regs.begin();mr!=regs.end();mr++){
		//check if its live
		set<char>::iterator sitr;
		sitr=lvar.find( mr->first);

		//if not live
		if(sitr==lvar.end()){
			//lowest number reg
			if(regval>0 && mr->second < regval ){
				regval=mr->second;
				ch = mr->first;
			}
			else if(regval<0){
				regval=mr->second;
				ch = mr->first;
			}
			//else dont update

		}

	}

	pair<char,int> p1 ;
	p1.first=ch;
	p1.second=regval;

	return p1;
}


int main(){

	map<char,Node*>Graph;

	char ch;
	int maxreg=0;

	while( scanf("%c",&ch)!=EOF){
		int st,end;
		scanf("%d %d\n",&st,&end);

		map<char,Node*>::iterator it;
		it= Graph.find(ch);

		if(it==Graph.end()){	
			Node* n = new Node(ch);
			n->addRange(st,end);
			Graph.insert(pair<char,Node*>(ch,n));
		}
		else{
			Node* n = it->second;
			n->addRange(st,end);
		}

		//second algo
		map<int,set<char>>::iterator sitr;
		
		sitr=Live.find(st);
		if(sitr!=Live.end()){
			(*sitr).second.insert(ch);
		}
		else{
			set<char>temp;
			temp.insert(ch);
			Live.insert(pair<int,set<char>>(st,temp));
		}

		sitr=Live.find(end);
		if(sitr!=Live.end()){
			(*sitr).second.insert(ch);
		}
		else{
			set<char>temp;
			temp.insert(ch);
			Live.insert(pair<int,set<char>>(end,temp));
		}

		// cout<<ch<<" "<<st<<" "<<end<<"\n";
	}

	// makeEdges(Graph);
	// printG(Graph);

	map<int,set<char>>::iterator sitr;
	for(sitr=Live.begin();sitr!=Live.end();sitr++){
		int s = (*sitr).second.size();
		if( s > maxreg)
			maxreg=s;
	}

	makeLive(Graph);
	//printLive();


	int regCount = 0;
	int spillCount = 0;

	//if free then 0
	bool freeReg = true;
	
	map<char,int>cRegAlloc;


	for(sitr=Live.begin();sitr!=Live.end();sitr++){

		set<char>st = (*sitr).second;
		set<char>::iterator itr;
		
		for(itr=st.begin();itr!=st.end();itr++){
			
			//check if allocated
			map<char,int>::iterator mitr;
			mitr=cRegAlloc.find(*itr);
			
			if(mitr==cRegAlloc.end()){
				//not allocated

				//if reg free
				if(freeReg){
					regCount++;
					if(regCount>=maxreg)
						freeReg=false;

					cRegAlloc.insert(pair<char,int>(*itr,regCount));

				}
				else {
					//check if spill possible
					pair<char,int> pr = checkSpill(cRegAlloc,st);
					if(pr.second ==-1){
						regCount++;
						
						if(regCount>=maxreg)
							freeReg=false;

						cRegAlloc.insert(pair<char,int>(*itr,regCount));
					}
					else{
						map<char,int>::iterator mfr;
						mfr = cRegAlloc.find(pr.first);
						
						//remove the val from alloc
						if(mfr!=cRegAlloc.end())
							cRegAlloc.erase(mfr);

						spillCount++;
						//add new map
						cRegAlloc.insert(pair<char,int>(*itr,pr.second));
						//cout<<"spill "<<pr.first<<" "<<pr.second<<" for "<<*itr<<"\n";
					}
				}

			}

		}

	}

	cout<<regCount<<" "<<spillCount<<"\n";


	return 0;
}