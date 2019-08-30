#include "mex.h"
#include <math.h>
#include "stdlib.h"
#include <string.h>
#include "stdafx.h"
#define SIG  prhs[0]
#define WINSIZE  prhs[1]
#define SHIFT prhs[2]
#define FS  prhs[3]
#define DOPLOT  prhs[4]
#define SPEC  plhs[0]
#define X  plhs[1]
#define Y  plhs[2]
#define PI 3.14159265

const int N = 1024;

inline void swap(double &a, double &b)
{
	double t;
	t = a;
	a = b;
	b = t;
}

void bitrp(double *xreal, double *ximag, int n)
{
	// Bit-reversal Permutation
	int i, j, a, b, p;

	for (i = 1, p = 0; i < n; i *= 2)
	{
		p++;
	}
	for (i = 0; i < n; i++)
	{
		a = i;
		b = 0;
		for (j = 0; j < p; j++)
		{
			b = (b << 1) + (a & 1);    // b = b * 2 + a % 2;
			a >>= 1;        // a = a / 2;
		}
		if (b > i)
		{
			swap(xreal[i], xreal[b]);
			swap(ximag[i], ximag[b]);
		}
	}
}

void FFT(double *xreal, double *ximag, int n)
{
	double wreal[N / 2], wimag[N / 2], treal, timag, ureal, uimag, arg;
	int m, k, j, t, index1, index2;

	bitrp(xreal, ximag, n);

	arg = -2 * PI / n;
	treal = cos(arg);
	timag = sin(arg);
	wreal[0] = 1.0;
	wimag[0] = 0.0;
	for (j = 1; j < n / 2; j++)
	{
		wreal[j] = wreal[j - 1] * treal - wimag[j - 1] * timag;
		wimag[j] = wreal[j - 1] * timag + wimag[j - 1] * treal;
	}

	for (m = 2; m <= n; m *= 2)
	{
		for (k = 0; k < n; k += m)
		{
			for (j = 0; j < m / 2; j++)
			{
				index1 = k + j;
				index2 = index1 + m / 2;
				t = n * j / m;    
				treal = wreal[t] * xreal[index2] - wimag[t] * ximag[index2];
				timag = wreal[t] * ximag[index2] + wimag[t] * xreal[index2];
				ureal = xreal[index1];
				uimag = ximag[index1];
				xreal[index1] = ureal + treal;
				ximag[index1] = uimag + timag;
				xreal[index2] = ureal - treal;
				ximag[index2] = uimag - timag;
			}
		}
	}
}

double *AllocMatrix(int nRow, int nCol)
{
	short i, j;
	double *m;

	m = (double *)malloc((unsigned)(nRow * nCol)
		*sizeof(double));

	for (i = 0; i <= nRow; i++)
		for (j = 0; j <= nCol; j++) 
			m[i+j*nRow] = 0.0;
	return m;
}

void spectra(double *sig, int sigLen, int winsize, int shift, int fs, int doplot, 
            double *spec, double *x, double *y)
{
    int nfre = winsize/2+1;
    int nseg = floor((sigLen - winsize)/shift) + 1;
    double *hann;
    double *xreal, *ximag;
//  y = (double *)malloc(sizeof(double) * (unsigned)(nfre));
//  x = (double *)malloc(sizeof(double) * (unsigned)(nseg));
//	spec = (double *)malloc(sizeof(double) * (unsigned)nfre*nseg);
	hann = (double *)malloc(sizeof(double) * (unsigned)winsize);
	xreal = (double *)malloc(sizeof(double) * (unsigned)winsize);
    ximag = (double *)malloc(sizeof(double) * (unsigned)winsize);
    int i,j;
    
    for (i = 0; i<winsize; i++)
        hann[i] = 0.5*(1-cos((2*PI*i)/winsize));
    for (i = 0; i<nseg; i++)
    {
        for (j=0; j<winsize; j++){
            ximag[j] = 0;
            xreal[j] = sig[j + i*shift] * hann[j];
        }
        FFT(xreal, ximag, winsize);
        for (j=0; j<nfre; j++)
            spec[j+i*nfre] = xreal[j] * xreal[j] + ximag[j] * ximag[j];
       
        for (j=0; j<nfre; j++)
            spec[j+i*nfre] = 10 * log10(spec[j+i*nfre]);
           
    }
    for (i = 0; i < (winsize/2+1); i++)
        y[i] = i * fs / winsize / 1000;
    for (i = 0; i < nseg; i++)
        x[i] = i * shift / fs;
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *sig, *winsize_double, *shift_double, *fs_double, *doplot_double;
	int winsize, shift, fs, doplot;
    double *spec, *x, *y;
    size_t dimN_SIG, dimM_SIG, dimN_WINSIZE, dimM_WINSIZE, dimN_SHIFT;
    size_t dimM_SHIFT, dimN_FS, dimM_FS, dimN_DOPLOT, dimM_DOPLOT;
    size_t dimM_X, dimN_X, dimM_Y, dimN_Y, dimN_SPEC, dimM_SPEC;
    
	if (nrhs != 5)
		mexErrMsgTxt("wrong number of parameters");
    else if (nlhs > 3)
        mexErrMsgTxt("Too many ouotput arguments.");
    
    /* check input data type */
    if (!mxIsDouble(SIG))
        mexErrMsgTxt("The first input must be double");
    if (!mxIsDouble(WINSIZE))
        mexErrMsgTxt("The second input must be double");
    if (!mxIsDouble(SHIFT))
        mexErrMsgTxt("The third input must be double");
    if (!mxIsDouble(FS))
       mexErrMsgTxt("The fourth input must be double");
    if (!mxIsDouble(DOPLOT))
        mexErrMsgTxt("The fifth input must be double");
    
    /* check input dimmension */

    dimN_SIG = mxGetN(SIG);
    dimM_SIG = mxGetM(SIG);
    dimN_WINSIZE = mxGetN(WINSIZE);
    dimM_WINSIZE = mxGetM(WINSIZE);
    dimN_SHIFT = mxGetN(SHIFT);
    dimM_SHIFT = mxGetM(SHIFT);
    dimN_FS = mxGetN(FS);
    dimM_FS = mxGetM(FS);
    dimN_DOPLOT = mxGetN(DOPLOT);
    dimM_DOPLOT = mxGetM(DOPLOT);
     
    if (!(dimN_SIG == 1))
        mexErrMsgTxt("Sig must be a col vector");
    if (!((dimN_WINSIZE==1)&&(dimM_WINSIZE==1)))
        mexErrMsgTxt("Winsize must be a scalar.");
    if (!((dimN_SHIFT==1)&&(dimM_SHIFT==1)))
        mexErrMsgTxt("Shift must be a scalar.");
    if (!((dimN_FS==1)&&(dimM_FS==1)))
        mexErrMsgTxt("FS must be a scalar.");
    if (!((dimN_DOPLOT)&&(dimM_DOPLOT)))
        mexErrMsgTxt("DOPLOT must be a scalar.");
    
    sig = mxGetPr(SIG);
    winsize_double = mxGetPr(WINSIZE);
	winsize = int(winsize_double[0]);
    shift_double = mxGetPr(SHIFT);
	shift = int(shift_double[0]);
    fs_double = mxGetPr(FS);
	fs = int(fs_double[0]);
   
	doplot_double = mxGetPr(DOPLOT);
	doplot = int(doplot_double[0]);

    /* set output parameter dimensions */
    dimM_X = 1;
    dimN_X = floor((dimM_SIG - winsize) / shift) + 1;
    dimM_Y = 1;
    dimN_Y = winsize / 2 + 1;;
    dimM_SPEC = dimN_Y;
    dimN_SPEC = dimN_X;
    
    SPEC = mxCreateDoubleMatrix(mwSize(dimM_SPEC),mwSize(dimN_SPEC),mxREAL);
    X = mxCreateDoubleMatrix(mwSize(dimM_X),mwSize(dimN_X),mxREAL);
    Y = mxCreateDoubleMatrix(mwSize(dimM_Y),mwSize(dimN_Y),mxREAL);
    spec = mxGetPr(SPEC);
    x = mxGetPr(X);
    y = mxGetPr(Y);
    spectra(sig, dimM_SIG, winsize, shift, fs, doplot, spec, x, y);
}