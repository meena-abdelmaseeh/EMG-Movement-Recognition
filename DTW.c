#include <math.h>
#include <stdio.h>
#include <stdlib.h>

#define VERY_BIG  (1e30)
#include "mex.h"

//The DTW implementation is based on Andrew Slater and John Coleman's DTW code written in C, and available here: 
// http://www.phon.ox.ac.uk/files/slp/Extras/dtw.html
void dtw(double ** x, double ** y, int xsize,int ysize, int params, double* RetDist, double* RetK)
{
double **globdist;
double **Dist;
double top, mid, bot, cheapest, total;
int **move;
int **warp;
int **temp;
unsigned int I, X, Y, n, i, j, k;
Dist = malloc(xsize * sizeof(double *));
for (i=0; i < xsize; i++)
Dist[i] = malloc(ysize * sizeof(double));
globdist = malloc(xsize * sizeof(double *));
for (i=0; i < xsize; i++)
{
globdist[i] = malloc(ysize * sizeof(double));
}
move = malloc(xsize * sizeof(int *));
for (i=0; i < xsize; i++)
move[i] = malloc(ysize * sizeof(int));
temp = malloc((xsize+ysize) * 2 * sizeof(int *));
for (i=0; i < (xsize+ysize)*2; i++)
	temp[i] = malloc(2 * sizeof(int));
 warp = malloc((xsize+ysize) * 2 * sizeof(int *));
for (i=0; i < (xsize+ysize)*2; i++)
warp[i] = malloc(2 * sizeof(int));
/*Compute distance matrix*/

for(i=0;i<xsize;i++) 
{
  for(j=0;j<ysize;j++) 
  {
    total = 0;
    for (k=0;k<params;k++) 
	{
      total = total + ((x[i][k] - y[j][k]) * (x[i][k] - y[j][k]));
    }
    Dist[i][j] = total;
  }
}
/*% for first frame, only possible match is at (0,0)*/

globdist[0][0] = Dist[0][0];
for(i=1;i<ysize;i++)
{
	globdist[0][i] = globdist[0][i-1] + Dist[0][i];
	move[0][i] = 3;
}
for(i=1;i<xsize;i++)
{
	globdist[i][0] = globdist[i-1][0] + Dist[i][0];
	move[i][0] = 1;
}
for (i = 1; i<xsize;i++)
{
	for(j = 1; j<ysize;j++)
	{
		top = globdist[i-1][j] + Dist[i][j];//Vert
		mid = globdist[i-1][j-1] + Dist[i][j];//diag
		bot = globdist[i][j-1] +Dist[i][j];//Horiz
		if( (top < mid) && (top < bot))
		{
			cheapest = top;
			I = 1;
		}
		else if (mid < bot)
		{
			cheapest = mid;
			I = 2;
		}
		else 
		{
			cheapest = bot;
			I = 3;
		}
		if( ( top == mid) && (mid == bot))
			 I = 2;
		globdist[i][j] = cheapest;
		move[i][j] = I;
	}
}
Y = ysize-1; X = xsize-1; n=0;
while (X != 0 || Y != 0) 
{
	n=n+1;
	if (move[X] [Y] == 1 )
	{
		X= X-1; 
		Y= Y;
	}
	else if (move[X] [Y] == 2)
	{
		X=X-1; Y = Y-1;
	}
	else if (move[X] [Y] == 3 )
	{
		X=X;
		Y= Y-1;
	}
}
*RetK = n; 
*RetDist = globdist[xsize-1][ysize-1];
for (i=0; i < xsize; i++)
free(Dist[i]);
free(Dist);
for (i=0; i < xsize; i++)
free(globdist[i]);
free(globdist);
for (i=0; i < xsize; i++)
free(move[i]);
free(move); 
for (i=0; i < (xsize+ysize)*2; i++)
free(temp[i]);
free(temp);
for (i=0; i < (xsize+ysize)*2; i++)
free(warp[i]);
free(warp);
}
/* The gateway function */
void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
    size_t ncols_A, ncols_B, nrows_A, nrows_B;
	int i, j, r;	
	double *outDTWDistance;
	double *outWarpLength;	
	/* input; channel in rows */
	double* A;
	double* B;
	double** x;
	double** y;
	double best_so_far;
	/* output */
	double dtwDistance;
	double warpLength;
	/* create a pointer to the real data in the input matrix  */
	A = mxGetPr(prhs[0]);
	B = mxGetPr(prhs[1]);
    ncols_A = mxGetN(prhs[0]);
	ncols_B = mxGetN(prhs[1]);
	nrows_A = mxGetM(prhs[0]);
	nrows_B = mxGetM(prhs[1]);
	plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
	plhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
	outDTWDistance = mxGetPr(plhs[0]);
	outWarpLength = mxGetPr(plhs[1]);
	x = malloc(nrows_A * sizeof(double*));
	for (i = 0; i < nrows_A; i++)
		{
			x[i] = malloc(ncols_A * sizeof(double));
			for (j = 0; j < ncols_A; j++)
			{
				x[i][j] = A[(i) + (j*nrows_A)];
			}
		}
		y = malloc(nrows_B * sizeof(double*));
		for (i = 0; i < nrows_B; i++)
		{
			y[i] = malloc(ncols_B * sizeof(double));
			for (j = 0; j < ncols_B; j++)
			{
				y[i][j] = B[(i) + (j*nrows_B)];
			}
		}
		dtw( x,  y,  nrows_A, nrows_B,  ncols_A, &dtwDistance,&warpLength);
		for (i = 0; i < nrows_A; i++)
		{
			free(x[i]);
		}
		free(x);
		for (i = 0; i < nrows_B; i++)
		{
			free(y[i]);
		}
		free(y);
		*outDTWDistance = dtwDistance;
		*outWarpLength = warpLength;
}