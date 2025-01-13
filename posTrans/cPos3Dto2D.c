#include <math.h>
#include "mex.h"

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{

    int rows, cols;
    double *x3d,*y3d,*z3d;
    double *x2d, *y2d;
    int i,j;

    // // omitting the coefficient check at first ver

    rows = mxGetM(prhs[0]);
    cols = mxGetN(prhs[0]);

    plhs[0] = mxCreateDoubleMatrix(rows,cols, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(rows,cols, mxREAL);

    x3d = mxGetPr(prhs[0]);
    y3d = mxGetPr(prhs[1]);
    z3d = mxGetPr(prhs[2]);

    x2d = mxGetPr(plhs[0]);
    y2d = mxGetPr(plhs[1]);

    for(i = 0;i<rows;i++){
        for(j = 0;j<cols;j++){
            x2d[i+j*rows] = x3d[i+j*rows]/(1 + z3d[i+j*rows]);
            y2d[i+j*rows] = y3d[i+j*rows]/(1 + z3d[i+j*rows]);
        }            
    }  

}

