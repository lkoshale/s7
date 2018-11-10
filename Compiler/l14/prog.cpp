#include <iostream>
#include <cstdlib>
#include <vector>
#include <stdio.h>
#include <utility>

#define BEST   100
#define WORST  200
#define FIRST  300


using namespace std;

vector<Pair> FreeMemory;
vector<string> allocP;

vector<string> fPointers;


string free_mem(string name){

	int index = -1;
	for(int i=0;i<allocP.size();i++){
		if(name==allocP[i]){
			index = i;
			break;
		}
	}

	if(index==-1){
		for(int i=0;i<fPointers.size();i++){
			if(fPointers[i]==name){
				return "double-free error";
			}
		}

		return "invalid-pointer error";
	}
	else{
		
	}

}


void insert_name(string name){
	for(int i=0;i<allocP.size();i++){
		if(name==allocP[i]){
			allocP[i] = "invalid";
		}
	}

	allocP.push_back(name);
}

bool Allocate(string name,int size,int ST){
	
	boOL ANS = false;

	if(ST==BEST){

	}
	else if(ST==WORST){

	}
	else if(ST==FIRST){
		for(int i=0;i<FreeMemory.size();i++){
			Pair p= FreeMemory[i];
			if( (p.second-p.first)+1 <= size ){
				
				if( (p.second-p.first)+1 == size){
					FreeMemory.erase(FreeMemory.begin()+i);
				}
				else{
					FreeMemory[i].first = p.first+ (size - p.first);
				}

				insert_name(name);

				break;
			}
		}
	}
	return ans;
}



int main(){

	int N;
	int Strat;
	string type;
	cin>>N>>type;

	Pair p;
	p.first = 0;
	p.second = N-1;

	FreeMemory.push_back(p);

	if(type=="best-fit")
		Strat=BEST;
	else if(type=="worst-fit")
		Strat=WORST;
	else if(type=="first-fit")
		Strat=FIRST;

	char buffer[100];

	while(scanf("%s")!=EOF){

		if(strcmp(buffer,"free")==0){
			char name[100];
			int size;
			scanf("%s %d\n",name,&size);
			string t(name);
			bool v = Allocate(t,size,Strat);
		}
		else if(strcmp(buffer,"malloc")==0) {
			char name[100];
			scanf("%s\n",name);
		}
		else{

		}


	}



	return 0;
}