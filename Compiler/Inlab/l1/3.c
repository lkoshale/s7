#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int main(int argc, char* argv[]){
	if(argc<2)
		exit(0);

	char* infile = argv[1];

	int fno = argv[1][0]-'0';

	printf("%d\n",fno);

	char outfile[10] ;
	sprintf(outfile,"%d.c",++fno);
	

	FILE* fptr = fopen(outfile,"w");
	FILE* old = fopen(argv[1],"r");
	char buffer[100];
	while(fgets(buffer,100,old)!=NULL){
		fprintf(fptr, "%s",buffer);
	}
	fclose(old);
	fclose(fptr);
	return 0;
}