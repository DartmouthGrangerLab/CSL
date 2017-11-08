#include "mex.h"
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include "m_utils.h"
#include "m_malloc.h"
#include "m_TreeNode1a.h"
#include <vector>

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){   
	mexPrintf("a");
   /* check for the proper no. of input and outputs */
   if (nrhs != 11)
   mexErrMsgTxt("11 input arguments are required");
   if (nlhs>1)
   mexErrMsgTxt("Too many outputs");

   /* Get the no. of dimentsions and size of each dimension in the input array */
   //const int *sizeDimUnary = mxGetDimensions(prhs[0]);
   /* Get the dimensions of the input image */
   //int rows = sizeDimUnary[0]; 
   //int cols = sizeDimUnary[1]; 
   int rows = (int)mxGetM(prhs[0]);
   int cols = (int)mxGetN(prhs[0]);


   int Output = 0;

   /* Get the pointers to the input Data */  
   double *ImAssignPtr = mxGetPr(prhs[0]);
   double *targetHistPtr = mxGetPr(prhs[1]);    
   double *weightsPtr = mxGetPr(prhs[2]);

   // ASHOK
   int CellCnt = GetPyrCellCount();
   int histSize = (int)mxGetScalar(prhs[3]);
   int K = (int)mxGetScalar(prhs[4]);

   double *CPtr = mxGetPr(prhs[5]);
   double *tolFactorPtr = mxGetPr(prhs[6]);
   double *knownBestPtr = mxGetPr(prhs[7]);
   //ASHOK
   double *MuPtr = mxGetPr(prhs[8]);
   double *SPtr = mxGetPr(prhs[9]);
   double *FlexWinPtr = mxGetPr(prhs[10]);
   
   double C = (double) *CPtr;
   double tolFactor = (double) *tolFactorPtr;
   double knownBest = (double) *knownBestPtr;
   
   //ASHOK
	// Gaussian Prior for windows
   vector<double> Mu;
   Mu.push_back(*MuPtr); MuPtr++; Mu.push_back(*MuPtr); 
   vector<double> S;
   S.push_back(*SPtr); SPtr++; S.push_back(*SPtr);  
   bool FlexWin = bool(*FlexWinPtr);
   
   /* create matrices */
   int **ImAssign, *targetHist;  
   double *weights;

   // ASHOK
   targetHist = buildVector<int>(CellCnt*histSize*K);
   weights = buildVector<double>(CellCnt*histSize*K);
   ImAssign = buildMatrix<int>(rows, cols);

   // Assign the data targetHist
   for (int k=0; k<CellCnt*histSize*K; k++){
      targetHist[k] = (int) (*targetHistPtr);
      targetHistPtr++;
      weights[k] = (double) (*weightsPtr);
      weightsPtr++;
   }

   // Assign the data for: Im1Assign Im1Init Label1
   for (int j=0; j<cols; j++){
      for (int i=0; i<rows; i++){
         ImAssign[i][j] = ((int) (*ImAssignPtr));
         ImAssignPtr++;  
      }
   }

   if (Output){
      printf("rows: %d, cols: %d, histSize: %d, C: %g \n", rows, cols, histSize, C);
   }

   Window bestBB = findBox1a(ImAssign, rows, cols, targetHist, weights, histSize, K, 
      C, tolFactor, knownBest, Mu, S, FlexWin);


   /* Create the outGoing Array  */
   plhs[0] = mxCreateNumericMatrix(1, 4, mxDOUBLE_CLASS, mxREAL);   
   double *labelOutPtr = mxGetPr(plhs[0]); 
   
   labelOutPtr[0] = (double) (bestBB.ul_x + 1);
   labelOutPtr[1] = (double) (bestBB.ul_y + 1);
   labelOutPtr[2] = (double) (bestBB.lr_x + 1);
   labelOutPtr[3] = (double) (bestBB.lr_y + 1);
   destroyMatrix<int>(ImAssign, rows, cols);

   destroyVector<int>(targetHist, histSize*K);   
   destroyVector<double>(weights, histSize*K);
   mexPrintf("/");
} 
  