int main() {
	int a;
	int b;
	int c;
	int d;
	int e;
	int f;
	int g;
	int h;
	int i;
	int j; 
	int o;
	c = -1;
	a = 2999;
	b = 2999 % 6;
	d = 0;
	i = 90;
	j = 85;
	while (b >= 1) {
		c = c + 1;
		b = b - 1;
		d = !d;
		i = i - 1;
		j = j + 1;
	}

	b = c % 2;
	a = c;
	e = b && d;
	f = 21 * a;
	g = 786 - f;
	h = 13 * 51;
	h = h / 3;
	j = h > g;
	if (!b) {
		int k;
		int l;
		l = 11 + 2;
		k = g;
		k = k % l;
		a = k;
		printf("%d\n", a);
	}
	else {
		int m;
		int n;
		m = i;
		n = j;
		b = m == n;
		printf("%d\n", b);
	}

	o = !j;
	
	if (o || (-51)) {
		printf("%d\n", c);
		printf("%d\n", e);
		printf("%d\n", g);
		printf("%d\n", i);
	}
	else {
		printf("%d\n", d);
		printf("%d\n", f);
		printf("%d\n", h);
		printf("%d\n", j);
	}
	
}
