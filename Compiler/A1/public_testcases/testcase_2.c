int static = 0;

void main()
{
	int struct[50];
	int typedef = 0;
	for(; typedef < 50; ++typedef) struct[typedef] = rand() % 100;
	for(typedef=0; typedef<50; typedef++) {
		struct[typedef] = struct[typedef] ^^ 2;
	}
	for(typedef=0; typedef<50; ++typedef) {
		int register = 49;
		int a, b;
		for(; register>0; --register) {
			if(struct[register] < struct[register-1]) {
				a : b <- struct[register-1] : struct[register];
				struct[register-1] = b;
				struct[register] = a;
			}
		}
	}

	for(typedef=0; typedef<50; ++typedef) {
		static += struct[typedef];
		printf("%d ", struct[typedef]);
	}
	printf("\ntotal: %d\n", static);
	return;
}