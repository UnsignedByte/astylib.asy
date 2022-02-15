access contour;

// DEFINE GLOBALS
real astyscale = 1; // Define scale of elements

//UTIL FUNCTIONS

// distance squared
real astyds(pair A, pair B)
{
	return (A.x-B.x)^2+(A.y-B.y)^2;
}

// distance
real astyd(pair A, pair B)
{
	return sqrt(astyds(A, B));
}

//DRAW FUNCTIONS

//mark angle given 3 points.
path[] astymarkangle(pair A, pair B, pair C, real count=1)
{
	real lspacing = 0.2;
	path arcs[];
	pair P;
	pair Q;
	for (int i = 0; i < count; ++i)
	{
		P = (1+lspacing*i)*astyscale*unit(A-B)+B;
		Q = (1+lspacing*i)*astyscale*unit(C-B)+B;
		arcs[i] = arc(B, P, Q);
	}
	return arcs;
}

// right angle mark with 3 points
path[] astymarkrightangle(pair A, pair B, pair C, real count=1)
{
	real lspacing = 0.2;
	path paths[];
	pair P;
	pair Q;
	for (int i = 0; i < count; ++i)
	{
		P = (1+lspacing*i)*astyscale/sqrt(2)*unit(A-B);
		Q = (1+lspacing*i)*astyscale/sqrt(2)*unit(C-B);
		paths[i] = P+B--P+Q+B--Q+B;
	}
	return paths;
}

// draw guide line between two points with spacing between each point and the start of the line
path astyguide(pair A, pair B)
{
	real d, g;
	d = astyd(A, B);
	g = 0.25*astyscale/d; // calculated gap
	return subpath(A--B, g, 1-g);
}

//label x and y components of a line
path[] astycomponents(pair A, pair B)
{
	pair R;
	R = (A.x, B.y);

	path P[];
	P[0] = astyguide(A, R);
	P[1] = astyguide(B, R);
	return P;
}

// Create nonlinear gradient specified by a list of pens and their positions.
pen[] astygradient(int n, pen[] colors, real[] positions = {}) {
	if (positions.length == 0) {
		if (colors.length == 1) {
			positions = new real[] {1};
		} else {
			positions = uniform(0, 1, colors.length-1);
		}
	}

	assert(colors.length == positions.length, "More colors provided than positions.");

	int ri = 1;

	colors.insert(0, colors[0]);
	colors.push(colors[colors.length-1]);
	positions.insert(0, 0);
	positions.push(1);

	pen[] ncolors = new pen[n];

	for (int i = 0; i < n; ++i) {
		if (i > positions[ri] * (n-1)) {
			++ri;
		}

		real dst = (positions[ri]-positions[ri-1]) * (n-1);

		real ratio = 1;

		if (dst != 0) {
			ratio = (i - positions[ri-1] * (n-1)) / dst;
		}

		ncolors[i] = colors[ri-1]*(1-ratio) + colors[ri]*ratio;
	}

	return ncolors;
}

// Draws a contourmap onto a picture.
void astydrawsimplecontour(picture pic = currentpicture, real f(real, real), pair a, pair b, real[] c, real[] important, pen[] grad = {black}) {

	int n = c.length;
	pen[] p = astygradient(n, grad);
	p = sequence(new pen(int i) {
		return p[i] + (c[i] != 0 ? dashed : solid);
	}, n);

	Label[] ll=sequence(new Label(int i) {
  	return Label(c[i] != 0 ? (string) c[i] : "",Relative(unitrand()),(0,0),UnFill(1bp));
	},n);

	contour.draw(pic, ll, contour.contour(f,a,b,c), p);
}