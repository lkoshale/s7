int main() {
	int a[10];
	int b;
	int c;
	b = 0;
	c = 11;
	while (b < 10) {
		a[b] = c + b;
		b = b + 1;
	}
	b = b - 1;
	while (b >= 0) {
		int e;
		e = a[b];
		printf("%d\n", e);
		b = b - 1;
	}
	return 0;
}
