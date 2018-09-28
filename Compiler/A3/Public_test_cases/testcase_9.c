int foo (int q) {
	q = q + 6;
	return q;
}


int main() {
	int a;
	int b;
	a = 13;
	b = foo(a);
	printf("%d\n", b);
	return 0;
}
