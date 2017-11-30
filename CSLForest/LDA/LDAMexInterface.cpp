#include "mex.h"
#include <vector>
#include "GibbsSamplerLDA.cpp"
using namespace std;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs,
                 const mxArray *prhs[])
{
    double ALPHA,BETA;
    int KK,NN, MM, SEED;
    double *DblPtr, *OutDP, *OutWP;
    int *dp, *wp;
    
    /* Check for proper number of arguments. */
    if (nrhs != 5) {
        mexErrMsgTxt("5 input arguments required");
    } else if (nlhs < 2) {
        mexErrMsgTxt("2 output arguments required");
    }


    /* process the input arguments */
    if (mxIsDouble( prhs[ 0 ] ) != 1) mexErrMsgTxt("DMap input vector must be a double precision matrix");

    // pointer to word indices
    DblPtr = mxGetPr( prhs[ 0 ] );
    NN = mxGetM( prhs[ 0 ] );
    MM =  mxGetN( prhs[ 0 ] );
    vector <vector <double> > DMap(NN, vector<double>(MM,0));
    for (int i = 0; i <NN; i++)
        for (int j = 0; j < MM; j++)
            DMap[i][j] = DblPtr[j*NN+i];

    KK    = (int) mxGetScalar(prhs[1]);
    if (KK<=0) mexErrMsgTxt("Number of topics must be greater than zero");

    ALPHA = (double) mxGetScalar(prhs[2]);
    if (ALPHA<=0) mexErrMsgTxt("ALPHA must be greater than zero");

    BETA = (double) mxGetScalar(prhs[3]);
    if (BETA<=0) mexErrMsgTxt("BETA must be greater than zero");

    SEED = (int) mxGetScalar(prhs[4]);

    dp  = new int [ NN*KK ];
    wp  = new int [ MM*KK ];

    Run_LDA(DMap, KK, dp, wp, ALPHA, BETA, SEED);  
    plhs[0] = mxCreateDoubleMatrix(NN, KK, mxREAL);
    plhs[1] = mxCreateDoubleMatrix(MM, KK, mxREAL);
    DblPtr = mxGetPr(plhs[0]);
    for (int i = 0 ; i < NN; i++)
        for (int k = 0 ; k < KK ; k++)
            DblPtr[k*NN+i] = dp[i*KK+k];

    DblPtr = mxGetPr(plhs[1]);
    for (int j = 0 ; j < MM; j++)
        for (int k = 0 ; k < KK ; k++)
            DblPtr[k*MM+j] = wp[j*KK+k];

    delete [] dp;
    delete [] wp;
    
}
