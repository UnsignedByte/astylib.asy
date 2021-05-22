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
path[] astyangle(pair A, pair B, pair C, real count=1)
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

//draw guide line between two points with spacing

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