#include <math.h>
#include "mex.h"

// void transPosSphTo3D(int rows, int cols, double *phi, double *theta, double *x3d, double *y3d, double *z3d )
// {
//     int i,j;
//     int r = 1;
//     for(i = 0;i++;i<rows){
//         for(j = 0;j++;j<cols){
//             x3d[i+j*rows] = 1;  // r*sin(theta[i+j*rows])*cos(phi[i+j*rows]);
//             y3d[i+j*rows] = 2;  // r*sin(theta[i+j*rows])*sin(phi[i+j*rows]);
//             z3d[i+j*rows] = 3;  // r*cos(theta[i+j*rows]);
//         }            
//     }    
// }

void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{

    int rows, cols;
    double *x3d,*y3d,*z3d;
    double *phi, *theta;
    int i,j;
    int r = 1;



    // // omitting the coefficient check at first ver

    rows = mxGetM(prhs[0]);
    cols = mxGetN(prhs[0]);

    plhs[0] = mxCreateDoubleMatrix(rows,cols, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(rows,cols, mxREAL);
    plhs[2] = mxCreateDoubleMatrix(rows,cols, mxREAL);

    x3d = mxGetPr(plhs[0]);
    y3d = mxGetPr(plhs[1]);
    z3d = mxGetPr(plhs[2]);

    phi = mxGetPr(prhs[0]);
    theta = mxGetPr(prhs[1]);

    for(i = 0;i<rows;i++){
        for(j = 0;j<cols;j++){
            x3d[i+j*rows] = r*sin(theta[i+j*rows])*cos(phi[i+j*rows]);
            y3d[i+j*rows] = r*sin(theta[i+j*rows])*sin(phi[i+j*rows]);
            z3d[i+j*rows] = r*cos(theta[i+j*rows]);
        }            
    }  

}

