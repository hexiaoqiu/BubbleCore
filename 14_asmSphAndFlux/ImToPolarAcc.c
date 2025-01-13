#include "mex.h"
#include <math.h>

#define PI 3.141592653589793

void Gausse(double(* A)[4], double* Y, double* X)
{
    int n = 4;
    int i,j,k;
    int mi;
    double mx,tmp;
    // static double A[4][4],Y[4],X[4];
    

    for(i=0;i<n-1;i++)
    {
        //找主元素 
        for(j=i+1,mi=i,mx=fabs(A[i][i]);j<n;j++)
        {
            if(fabs(A[j][i])>mx)
            {
                mi=j;
                mx=fabs(A[j][i]);
            }
        }

        //交换两行  
        if(i<mi)
        {
            tmp=Y[i];
            Y[i]=Y[mi];
            Y[mi]=tmp;
            for(j=i;j<n;j++)
            {
                tmp=A[i][j];
                A[i][j]=A[mi][j];
                A[mi][j]=tmp;
            }
        } 

        //高斯消元 
        for(j=i+1;j<n;j++)
        {
            tmp=-A[j][i]/A[i][i];
            Y[j]+=Y[i]*tmp;
            for(k=i;k<n;k++)
            {
                A[j][k]+=A[i][k]*tmp;
            }
        }
    }

    //求解方程 
    X[n-1]=Y[n-1]/A[n-1][n-1];
    for(i=n-2;i>=0;i--)
    {
        X[i]=Y[i];
        for(j=i+1;j<n;j++)
        {
            X[i]-=A[i][j]*X[j];
        }
        X[i]/=A[i][i];
    }  
}

// double getElement(double* firstElement, int numLine, int numRow, int numAllLine)
// {   
//     int position;
//     double element;
//     position = ( (numRow-1)*numAllLine + numLine ) - 1;
//     element = firstElement[position];
//     return element;
// }

double interpolate(double* imR_i, double xR_i, double yR_i, int M)
{   
    // M is the total number of lines
    int xf,xc,yf,yc;
    double A[4][4];
    double r_2[4];
    double a[4];
    double w[4];
    double v;

    xf = floor(xR_i);
    xc = ceil(xR_i);
    yf = floor(yR_i);
    yc = ceil(yR_i);
    
    if(xf == xc && yc == yf)
    {
        // v = imR_i(xc, yc);
        v = imR_i[xc + (yc-1)*M -1];
    } 
    else if(xf == xc)
    {
        v = imR_i[xf+ (yf-1)*M -1] + (yR_i - yf)*( imR_i[xf+ (yc-1)*M -1] - imR_i[xf+ (yf-1)*M -1] );
    } 
    else if( yf == yc)
    {
        v = imR_i[xf+ (yf-1)*M -1] + (xR_i - xf)*(imR_i[xc+ (yf-1)*M -1] - imR_i[xf+ (yf-1)*M -1]);
    }
    else
    {
        A[0][0] = xf;
        A[0][1] = yf;
        A[0][2] = xf*yf;
        A[0][3] = 1;
        A[1][0] = xf;
        A[1][1] = yc;
        A[1][2] = xf*yc;
        A[1][3] = 1;
        A[2][0] = xc;
        A[2][1] = yf;
        A[2][2] = xc*yf;
        A[2][3] = 1;
        A[3][0] = xc;
        A[3][1] = yc;
        A[3][2] = xc*yc;
        A[3][3] = 1;

        r_2[0] = imR_i[xf+ (yf-1)*M -1];
        r_2[1] = imR_i[xf+ (yc-1)*M -1];
        r_2[2] = imR_i[xc+ (yf-1)*M -1];
        r_2[3] = imR_i[xc+ (yc-1)*M -1];

        // a = A\r_2;
        Gausse(A,r_2,a);
        w[0] = xR_i;
        w[1] = yR_i;
        w[2] = xR_i*yR_i;
        w[3] = 1;
        v = (w[0]*a[0] + w[1]*a[1] + w[2]*a[2] + w[3]*a[3]);
    }
    return v;
}


// gate function for Matlab
void mexFunction(int nlhs,mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
    int M,N;
    double rMin, rMax;
    double* imR;
    double Om, On;
    // double element;

    int Mr,Nr;

    double sx,sy,delR,delT;
    double theta,r,x,y,t,xR,yR;
    int ri, ti;

    double* imP;

    // int test = 0;
    
    // accept the input data
    imR = mxGetPr(prhs[0]);
    rMin = mxGetScalar(prhs[1]);
    rMax = mxGetScalar(prhs[2]);
    M = (int)mxGetScalar(prhs[3]);
    N = (int)mxGetScalar(prhs[4]);

    
    Mr = mxGetM(prhs[0]);
    Nr = mxGetN(prhs[0]);
    
    // generate the output data
    plhs[0]=mxCreateDoubleMatrix(M,N,mxREAL);
    imP = mxGetPr(plhs[0]);

    Om = ((double)Mr+1)/2; 
    On = ((double)Nr+1)/2;

    sx = ( (double)Mr-1)/2;
    sy = ( (double)Nr-1)/2;
    delR = PI/(2*(double)M);
    delT = 2*PI/((double)N);
    // mexPrintf("sx is %f \n", sx);
    // mexPrintf("sy is %f \n", sy);
    // mexPrintf("delR is %f \n", delR);
    // mexPrintf("delT is %f \n", delT);


    for(ri = 1; ri <= M; ri++)
    {
        theta = PI/(4*M) + (ri - 1)*delR;
        r = rMax*sin(theta)/(1+cos(theta));
        for(ti = 1; ti <= N; ti++)
        {
            t = (ti - 1)*delT;
            x = r*cos(t);
            y = r*sin(t);
            xR = x*sx + Om;  
            yR = y*sy + On;
            imP[ (ti-1)*M + ri-1 ] = interpolate(imR, xR, yR, Mr);
            // imP[ ri + (ti-1)*M -1 ] = test++;
        }
    }

    // mexPrintf("M is %d \n", M);
    // element = getElement(imR, 2,2, Mr);
    // mexPrintf("element is %f \n", element);


}

