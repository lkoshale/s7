void check_odd_even(){
	int x;
	scanf("%d", &x);
	printf("%s\n%s", "Enter 0 to end program.", "Enter a number: ?");
	while(x) {	// Throws error
		if(x % 2 == 0) {
			printf("%d is Even.\n", x);
		} else {
			printf("%d is Odd.\n", x);
		}
		printf("%s\n%s", "Enter 0 to end program.", "Enter a number: ?");
		scanf("%d", &x);
	}
}

int main()
{
	check_odd_even();
	return 0;
}