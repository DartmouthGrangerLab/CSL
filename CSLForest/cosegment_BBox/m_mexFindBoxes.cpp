#include "mex.h"
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include "m_utils.h"
#include "m_malloc.h"
#include "m_TreeNode2a.h"
//#include "m_TreeNode2b.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]){     
   /* check for the proper no. of input and outputs */
   if (nrhs != 11)
   mexErrMsgTxt("11 input arguments are required");
   if (nlhs>2)
   mexErrMsgTxt("Too many outputs");

   /* Get the height and width of images*/
   //const int *sizeDim1 = mxGetDimensions(prhs[0]);
   //int rows1 = sizeDim1[0];
   //int cols1 = sizeDim1[1];
   int rows1 = (int)mxGetM(prhs[0]);
   int cols1 = (int)mxGetN(prhs[0]);
   
   //const int *sizeDim2 = mxGetDimensions(prhs[1]);
   //int rows2 = sizeDim2[0];
   //int cols2 = sizeDim2[1];
   int rows2 = (int)mxGetM(prhs[1]);
   int cols2 = (int)mxGetN(prhs[1]);

   int Output = 0;

   /* Get the pointers to the input Data */  
   double *ImAssign1Ptr = mxGetPr(prhs[0]);
   double *ImAssign2Ptr = mxGetPr(prhs[1]);    
   double *weightsPtr = mxGetPr(prhs[2]);
   double *CPtr = mxGetPr(prhs[3]);
   double *tolPtr = mxGetPr(prhs[4]);
   double *knownBestPtr = mxGetPr(prhs[5]);
   double *seekSameSzPtr = mxGetPr(prhs[6]);
   double *resPtr = mxGetPr(prhs[7]);
   //ASHOK
   double *MuPtr = mxGetPr(prhs[8]);
   double *SPtr = mxGetPr(prhs[9]);
   double *FlexWinPtr = mxGetPr(prhs[10]);
   

   double C = (double) *CPtr;
   double tolFactor = (double) *tolPtr;
   double knownBest = (double) *knownBestPtr;
   bool seekSameSz = (bool) *seekSameSzPtr;
   int res = (int) (*resPtr);
   
   /* create matrices */
   int **ImAssign1, **ImAssign2;  
 

   ImAssign1 = buildMatrix<int>(rows1, cols1);
   ImAssign2 = buildMatrix<int>(rows2, cols2);

   int histSize = 0; 

   // Assign the data for ImAssign1 and ImAssign2
   for (int j=0; j<cols1; j++){
      for (int i=0; i<rows1; i++){
         ImAssign1[i][j] = ((int) (*ImAssign1Ptr));
         ImAssign1Ptr++;  
         histSize = max(histSize, ImAssign1[i][j]);
      }
   }

   for (int j=0; j<cols2; j++){
      for (int i=0; i<rows2; i++){
         ImAssign2[i][j] = ((int) (*ImAssign2Ptr));
         ImAssign2Ptr++;  
         histSize = max(histSize, ImAssign2[i][j]);
      }
   }

   double *weights = buildVector<double>(histSize);   
   
   for (int k=0; k<histSize; k++){
      weights[k] = (double) (*weightsPtr);
      weightsPtr++;
   }

   Res winRes(res, res);
   
   if (Output){
      printf("rows1: %d, cols1: %d, rows2: %d, cols2: %d, histSize: %d, C: %f \n", 
              rows1, cols1, rows2, cols2, histSize, C);
   }

   WindowPair bestBBoxes;
   if (seekSameSz){
#if 0
	   bestBBoxes = findBoxes2b(ImAssign1, rows1, cols1, 
                               ImAssign2, rows2, cols2, weights, histSize, 
                               C, tolFactor, knownBest, winRes, winRes);
#endif
   } 
   else 
   {
	      //ASHOK
  		  // Gaussian Prior for windows
		  vector<double> Mu;
		  Mu.push_back(*MuPtr); MuPtr++; Mu.push_back(*MuPtr); 
		  vector<double> S;
		  S.push_back(*SPtr); SPtr++; S.push_back(*SPtr); 
          bool FlexWin = bool(*FlexWinPtr);

		  bestBBoxes = findBoxes2a(ImAssign1, rows1, cols1, 
                               ImAssign2, rows2, cols2, weights, histSize, 
                               C, tolFactor, knownBest, Mu, S, FlexWin);
   }


   /* Create the out going Array  */
   plhs[0] = mxCreateNumericMatrix(1, 4, mxDOUBLE_CLASS, mxREAL);   
   double *labelOutPtr = mxGetPr(plhs[0]); 
   
   labelOutPtr[0] = (double) (bestBBoxes.win1.ul_x + 1);
   labelOutPtr[1] = (double) (bestBBoxes.win1.ul_y + 1);
   labelOutPtr[2] = (double) (bestBBoxes.win1.lr_x + 1);
   labelOutPtr[3] = (double) (bestBBoxes.win1.lr_y + 1);

   plhs[1] = mxCreateNumericMatrix(1, 4, mxDOUBLE_CLASS, mxREAL);   
   labelOutPtr = mxGetPr(plhs[1]); 
   
   labelOutPtr[0] = (double) (bestBBoxes.win2.ul_x + 1);
   labelOutPtr[1] = (double) (bestBBoxes.win2.ul_y + 1);
   labelOutPtr[2] = (double) (bestBBoxes.win2.lr_x + 1);
   labelOutPtr[3] = (double) (bestBBoxes.win2.lr_y + 1);

   destroyMatrix<int>(ImAssign1, rows1, cols1);
   destroyMatrix<int>(ImAssign2, rows2, cols2);
   destroyVector<double>(weights, histSize);
} 
  