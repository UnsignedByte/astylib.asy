access contour;

// DEFINE GLOBALS
pen shortdashed = linetype(new real[] {4, 4});

//UTIL FUNCTIONS

// distance
real astyd(pair A, pair B)
{
	return sqrt(abs(A-B));
}

//DRAW FUNCTIONS
// labels a point
void astylabel(picture pic = currentpicture, string name, pair A, real s = 1, pair d = (0, 0), filltype filltype=NoFill) {
	label(pic, scale(s)*Label(name, A, d), filltype);
}

// labels a path
void astylabel(picture pic = currentpicture, string name, path p, real s = 1, pair d = (0, 0), filltype filltype=NoFill) {
	astylabel(pic, name, relpoint(p, 0.5), s, d, filltype);
}

// labels a line
void astylabel(picture pic = currentpicture, string name, pair A, pair B, real s = 1, pair d = (0, 0), filltype filltype=NoFill) {
	astylabel(pic, name, (A+B)/2, s, d, filltype);
}

// draw guide line between two points with spacing between each point and the start of the line
path astyguide(pair A, pair B, real spacing = 0.25)
{
	real d, g;
	d = astyd(A, B);
	g = spacing/d; // calculated gap
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

// Creates a perpendicular to a line at a certain time t (from 0 to 1) at a distance dist
pair astyperp(path p, real t, real dist=1, bool clockwise=CW) {
	real time = reltime(p, t);
	pair src = point(p, time);
	pair tangent = dir(p, time);

	real angle = degrees(tangent) + (clockwise==CCW ? 90 : -90);

	return dist*dir(angle)+src;
}

// returns a perpendicular point on line A--B at point B.
pair astyperp(pair A, pair B, real dist=1, bool clockwise=CW) {
	return astyperp(A--B, 1, dist, clockwise);
}

// draw a perpendicular line through a point B on A--B
path astyperpline(pair A, pair B, real dist=1) {
	return astyperp(A, B, dist, CW)--astyperp(A, B, dist, CCW);
}

// Mark a path with congruence lines
path[] astymarkpath(path p, int count=1, real len = 0.1, real spacing=0.05, real center=0.5)
{
	real tspacing = spacing/arclength(p);

	path marks[];

	real start = center - tspacing*(count-1)/2;

	real pos;
	pair A;
	pair B;

	for (int i = 0; i < count; ++i)
	{
		pos = start + tspacing*i;
		A = astyperp(p, pos, len/2, CW);
		B = astyperp(p, pos, len/2, CCW);

		marks.push(A--B);
	}

	return marks;
}

//mark angle given 3 points.
path[] astymarkangle(pair A, pair B, pair C, int count=1, real scale=0.1, real spacing=0.2, bool clockwise=CW, bool tick=false)
{
	if (clockwise == CW) {
		return astymarkangle(C, B, A, count, scale, spacing, CCW, tick);
	}

	if (tick) {
		path p = astymarkangle(A, B, C, 1, scale, spacing, clockwise, tick=false)[0];
		path[] ticks = astymarkpath(p, count, len=scale*0.25, spacing=spacing*0.075, center=0.5);
		path ps[];
		ps.push(p);
		for (int i = 0; i < count; ++i) {
			ps.push(ticks[i]);
		}
		return ps;
	}

	path arcs[];
	pair P;
	pair Q;
	for (int i = 0; i < count; ++i)
	{
		P = (1+spacing*i)*scale*unit(A-B)+B;
		Q = (1+spacing*i)*scale*unit(C-B)+B;
		arcs.push(arc(B, P, Q));
	}
	return arcs;
}

// right angle mark with 3 points
path[] astymarkrightangle(pair A, pair B, pair C, int count=1, real scale=0.1, real spacing=0.2, bool clockwise=CW)
{
	if (clockwise == CW) {
		return astymarkrightangle(C, B, A, count, scale, spacing, CCW);
	}

	path paths[];
	pair P;
	pair Q;
	for (int i = 0; i < count; ++i)
	{
		P = (1+spacing*i)*scale/sqrt(2)*unit(A-B);
		Q = (1+spacing*i)*scale/sqrt(2)*unit(C-B);
		paths.push(P+B--P+Q+B--Q+B);
	}
	return paths;
}

//label x and y components of a line
path[] astylinecomponents(pair A, pair B)
{
	pair R;
	R = (A.x, B.y);

	path P[];
	P.push(astyguide(A, R));
	P.push(astyguide(B, R));
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

		ncolors.push(colors[ri-1]*(1-ratio) + colors[ri]*ratio);
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

pair[] astyconstructsquare(pair A, pair B, bool clockwise = CW) {
	real dist = abs(A-B);

	pair C = astyperp(A--B, 1, dist, clockwise);
	pair D = astyperp(A--B, 0, dist, clockwise);

	pair[] CD = {C, D};

	return CD;
}


/// SHADING FUNCTIONS
void astyfillcheckered(picture pic=currentpicture, path[] p, pen a, pen b, real nx=5, real ny=5, bool stroke=false) {
	real[] acols = colors(rgb(a));
	real[] bcols = colors(rgb(b));

	string shader = 
		"%.4f mul " 
		"floor "
		"exch "
		"%.4f mul " 
		"floor "
		"add "
		"2 mod "
		"1 eq "
		"{ %.4f %.4f %.4f } "
		"{ %.4f %.4f %.4f } "
		"ifelse ";

	shader = format(format(shader, ny), nx); // replace the first two ns
	shader = format(format(format(shader, acols[0]), acols[1]), acols[2]);
	shader = format(format(format(shader, bcols[0]), bcols[1]), bcols[2]);

	layer(pic);
	functionshade(pic, p, stroke, rgb(zerowinding), shader);
	layer(pic);
}