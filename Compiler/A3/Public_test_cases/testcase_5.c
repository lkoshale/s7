int main() {
	int a;
	int b;
	int c;
	a = 42;
	b = 51;
	c = -99;
	if (a <= b) {
		printf("%d\n", a);
		c = 1;
	}
	else {
		printf("%d\n", b);
	}

	if (c) 
		printf("%d\n", b);
	return 0;
}
