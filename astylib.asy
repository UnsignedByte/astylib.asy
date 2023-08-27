access contour;

// DEFINE GLOBALS
real astyscale = 1; // Define scale of elements
pen shortdashed = linetype(new real[] {4, 4});

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
path[] astymarkangle(pair A, pair B, pair C, real count=1, real spacing=0.2, bool clockwise=CW)
{
	if (clockwise == CW) {
		return astymarkangle(C, B, A, count, CCW);
	}

	path arcs[];
	pair P;
	pair Q;
	for (int i = 0; i < count; ++i)
	{
		P = (1+spacing*i)*astyscale*unit(A-B)+B;
		Q = (1+spacing*i)*astyscale*unit(C-B)+B;
		arcs[i] = arc(B, P, Q);
	}
	return arcs;
}

// right angle mark with 3 points
path[] astymarkrightangle(pair A, pair B, pair C, real count=1, real spacing=0.2, bool clockwise=CW)
{
	if (clockwise == CW) {
		return astymarkrightangle(C, B, A, count, CCW);
	}

	path paths[];
	pair P;
	pair Q;
	for (int i = 0; i < count; ++i)
	{
		P = (1+spacing*i)*astyscale/sqrt(2)*unit(A-B);
		Q = (1+spacing*i)*astyscale/sqrt(2)*unit(C-B);
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

// returns a new point $d$ units away from $B$ along line $AB$.
pair astyextend(pair A, pair B, real d) {
	return unit(B-A)*d+B;
}

// returns an arc with center $A$ between angles deg1 and deg2 and a certain radius
path astyarc(pair A, real radius, real deg1, real deg2, real degpad = 10, bool clockwise=CW) {
	if (clockwise == CCW) {
		return astyarc(A, radius, deg2, deg1, degpad, CW);
	}

	return arc(A, radius, deg1+degpad, deg2-degpad, CW);
}

// draws an arc with center $A$ between points $B$ and $C$ extended on both ends
path astyarc(pair A, pair B, pair C, real degpad = 10, bool clockwise=CW) {
	return astyarc(A, abs(B-A), degrees(B-A), degrees(C-A), degpad, clockwise);
}

// draws a line from A to B extended on both ends.
path astyline(pair A, pair B, real pad=1) {
	return astyextend(B, A, pad)--astyextend(A, B, pad);
}

// returns a perpendicular point on line A--B at point B.
pair astyperp(pair A, pair B, real dist=1, bool clockwise=CW) {
	real angle = degrees(B-A) + (clockwise==CW ? 90 : -90);
	return dist*dir(angle)+B;
}

// draw a perpendicular line through a point B on A--B
path astyperpline(pair A, pair B, real dist=1) {
	return astyperp(A, B, dist, CW)--astyperp(A, B, dist, CCW);
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

// Imitates a construction of an angle bisector for angle ABC
// Returns the bisector
pair astyconstructbisector(picture pic = currentpicture, pair A, pair B, pair C, real r, pen p = shortdashed, real degpad = 10, real dotsize = 5, bool clockwise = CW) {
	if (clockwise == CCW) {
		return astyconstructbisector(pic, C, B, A, r, p, degpad, dotsize, CW);
	}

	// initially drawn circle and two intersection points
	path arc1 = astyarc(B, r, degrees(A-B), degrees(C-B), degpad, CW);
	path circ = circle(B, r);
	pair p1 = intersectionpoint(circ, B--A);
	pair p2 = intersectionpoint(circ, B--C);

	draw(pic, arc1, p);
	dot(pic, p1, p+dotsize);
	dot(pic, p2, p+dotsize);

	// two remaining arcs used to find bisect point
	real d = abs(p1-p2);
	real ang1 = degrees(p1-p2);
	real ang2 = degrees(p2-p1);

	// first helper arc
	path _arca = arc(p2, d, ang1, ang1-180, CW);
	// second helper arc
	path _arcb = arc(p1, d, ang2, ang2+180, CCW);

	// gets the bisection point beforehand for artistic purposes
	pair bpoint = intersectionpoint(_arca, _arcb);

	real ang3 = degrees(bpoint-p2);
	real ang4 = degrees(bpoint-p1);

	path arc2 = astyarc(p2, d, ang1, ang3, degpad, CW);
	path arc3 = astyarc(p1, d, ang2, ang4, degpad, CCW);

	dot(pic, bpoint, p+dotsize);

	draw(arc2, p);
	draw(arc3, p);

	return bpoint;
}