#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

int check_var(char* var){
	int i=0;
	for(i=0;i<strlen(var);i++){
		if(i==0){
			if(isalpha(var[i]) || var[i]=='_')
				continue;
			else
				return 0;
		}
		else{
			if(isalnum(var[i]) || var[i]=='_')
				continue;
			else
				return 0;
		}
	}

	return 1;
}

int check_type(char* type){
	if(strcmp(type,"int")==0 || strcmp(type,"double")==0 || strcmp(type,"char")==0 )
		return 1;
	return 0;
}

int check_end(char* str){
	return 0;
}

int main(int argc, char* argv[]){
	char input[100];
	fgets(input,100,stdin);
	char cpyinput[100];
	strcpy(cpyinput,input);
	const char delim[5]=" ,\n";
	char* token;
	token = strtok(input,delim );

	// printf("%s\n",token);

	// if(!check_type(token))
	// 	printf("inavlid\n");
	int i=0;
	int flag_var=0;
	while(token!=NULL){
		if(strcmp(token,"\n")==0 )
			break;

		printf("%s\n",token);
		if(i==0){
			if(check_type(token)==0){
				printf(" Invalid\n");
				return 0;
			}
		}
		else{

			if(strcmp(token,";")==0 ){
				if(flag_var==0){
					printf("Invalid\n");
					return 0;
				}

				break;
			}



			char* dm;
			dm=strstr(token,";");
			if(dm==NULL){
				if(check_var(token)==0){
					printf("Invalid\n");
					return 0;
				}
			}
			else{
				// char cpy[100];
				// strncpy(cpy,token,strlen(token)-1);
				*dm='\0';
				if(check_var(token)==0){
					printf("Invalid\n");
					return 0;
				}
			}

			flag_var=1;
		}
		token = strtok(NULL,delim);
		i++;
	}
	char* dm;
	dm=strstr(cpyinput,";");
	if(dm==NULL)
		printf("Invalid-i\n");

	// printf("%d\n",i );
	printf("Valid\n");
	return 0;
}