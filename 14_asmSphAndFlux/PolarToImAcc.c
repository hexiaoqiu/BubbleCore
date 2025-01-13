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

double interpolate(double* imP, double theta, double t, int M, int N, double delR, double delT)
{   
    // M is the total number of lines
    int rf,rc,tf,tc;
    double ri,ti;
    double A[4][4];
    double z[4];
    double a[4];
    double w[4];
    double v;

    ri = 1 + (theta - PI/(4*M))/delR;
    ti = 1 + t/delT;
    rf = floor(ri);
    rc = ceil(ri);
    tf = floor(ti);
    tc = ceil(ti);
    
    if(tc > N)
    {
        tc = tf;
    } 
    if( (rf==rc)&&(tc==tf) )
    {
        v = imP[rc + (tc-1)*M -1];
    } 
    else if( rf == rc)
    {
        v = imP[rf+ (tf-1)*M -1] + (ti - tf)*(imP[rf + (tc-1)*M -1] - imP[rf+ (tf-1)*M -1]);
    }
    else if( tf == tc)
    {
        v = imP[rf + (tf-1)*M -1] + (ri - rf)*(imP[rc+(tf-1)*M-1] - imP[rf+(tf-1)*M-1] );
    }
    else
    {
        A[0][0] = rf;
        A[0][1] = tf;
        A[0][2] = rf*tf;
        A[0][3] = 1;
        A[1][0] = rf;
        A[1][1] = tc;
        A[1][2] = rf*tc;
        A[1][3] = 1;
        A[2][0] = rc;
        A[2][1] = tf;
        A[2][2] = rc*tf;
        A[2][3] = 1;
        A[3][0] = rc;
        A[3][1] = tc;
        A[3][2] = rc*tc;
        A[3][3] = 1;

        z[0] = imP[rf+ (tf-1)*M -1];
        z[1] = imP[rf+ (tc-1)*M -1];
        z[2] = imP[rc+ (tf-1)*M -1];
        z[3] = imP[rc+ (tc-1)*M -1];

        // a = A\r_2;
        Gausse(A,z,a);
        w[0] = ri;
        w[1] = ti;
        w[2] = ri*ti;
        w[3] = 1;
        v = (w[0]*a[0] + w[1]*a[1] + w[2]*a[2] + w[3]*a[3]);
    }
    return v;
}

void mexFunction(int nlhs,mxArray *plhs[],int nrhs, const mxArray *prhs[])
{
    int M,N;
    double rMin, rMax;
    double* imR;
    double Om, On;
    // double element;

    int Mr,Nr;

    double sx,sy,delR,delT;
    double theta,r,x,y,t;
    int xi, yi;

    double* imP;

    // int test = 0;
    
    // accept the input data
    imP = mxGetPr(prhs[0]);
    rMin = mxGetScalar(prhs[1]);
    rMax = mxGetScalar(prhs[2]);
    Mr = (int)mxGetScalar(prhs[3]);
    Nr = (int)mxGetScalar(prhs[4]);

    // generate the output data
    plhs[0]=mxCreateDoubleMatrix(Mr,Nr,mxREAL);
    imR = mxGetPr(plhs[0]);
    
    Om = ((double)Mr+1)/2; 
    On = ((double)Nr+1)/2;

    sx = ( (double)Mr-1)/2;
    sy = ( (double)Nr-1)/2;

    M = mxGetM(prhs[0]);
    N = mxGetN(prhs[0]);

    delR = PI/(2*(double)M);
    delT = 2*PI/((double)N);

    // mexPrintf("sx is %f \n", sx);
    // mexPrintf("sy is %f \n", sy);
    // mexPrintf("delR is %f \n", delR);
    // mexPrintf("delT is %f \n", delT);


    for(xi = 1; xi <= Mr; xi++)
    {
        for(yi = 1; yi <= Nr; yi++)
        {
            x = (xi - Om)/sx;
            y = (yi - On)/sy;
            r = sqrt(x*x + y*y);
            theta = acos( (rMax*rMax - r*r)/(rMax*rMax + r*r) );

            if ( ( theta>=0 )&&( theta<=(PI/2-delR/2) ) )
            {
                t = atan2(y,x);
                if(t<0)
                {
                    t = t + 2*PI;
                }
                imR[ xi + (yi-1)*Mr -1 ] = interpolate(imP, theta, t, M, N, delR, delT);
            }
            else
            {
                imR[ xi + (yi-1)*Mr -1 ] = 0;
            }
            
            // imP[ ri + (ti-1)*M -1 ] = test++;
        }
    }

    // mexPrintf("M is %d \n", M);
    // element = getElement(imR, 2,2, Mr);
    // mexPrintf("element is %f \n", element);


}