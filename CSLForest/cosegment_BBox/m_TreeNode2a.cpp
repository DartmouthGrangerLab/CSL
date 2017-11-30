
#include <iostream>
#include <fstream>
#include <cmath>
#include <queue>
#include <string>
#include <sstream>
#include "m_malloc.h"
#include "m_utils.h"
#include "time.h"
#include "m_TreeNode2a.h"
#include "m_TreeNode1a.h"
#include "m_BranchBound.cpp"

int ***TreeNode2a::integralIms1 = NULL;
int ***TreeNode2a::integralIms2 = NULL;
int TreeNode2a::nHistBin = 0;
double *TreeNode2a::weights = NULL;
double TreeNode2a::C = 0;

 vector<double> FG_Prior_Mu;
 vector<double> FG_Prior_S;
 double Img1DimX = 0;
 double Img1DimY = 0;
 double Img2DimX = 0;
 double Img2DimY = 0;
 bool isWinFlexible = false;
 
void TreeNode2a::cmpBnds(){
   double pr1, pr2;
   vector<double>x; 
   
   Window smallestWin1 = winPair1.getSmallestWin();
   int *hist1_min = smallestWin1.getPyrHist(integralIms1, nHistBin, 1);
   Window largestWin1 = winPair1.getLargestWin();
   int *hist1_max = largestWin1.getPyrHist(integralIms1, nHistBin, 1); // K = 1

   Window smallestWin2 = winPair2.getSmallestWin();
   int *hist2_min = smallestWin2.getPyrHist(integralIms2, nHistBin, 1);
   Window largestWin2 = winPair2.getLargestWin();
   int *hist2_max = largestWin2.getPyrHist(integralIms2, nHistBin, 1);

   lb = getLowerBnd2(hist1_min, hist1_max, hist2_min, hist2_max, weights, nHistBin, C);
   
   vector<double> bestwin = GetBestWin( smallestWin1, largestWin1, FG_Prior_Mu, FG_Prior_S, Img1DimX, Img1DimY, isWinFlexible);
   pr1 = CalcLogGauss( bestwin,  FG_Prior_Mu,  FG_Prior_S, isWinFlexible);
   bestwin = GetBestWin( smallestWin2, largestWin2, FG_Prior_Mu, FG_Prior_S, Img2DimX, Img2DimY, isWinFlexible);
   pr2 = CalcLogGauss( bestwin,  FG_Prior_Mu,  FG_Prior_S, isWinFlexible);
   //lb -= SCAL_CONST*(exp(pr1)+exp(pr2));
   lb -= (pr1+pr2);
   
   double ub1, ub2, ub3, ub4; // four candidates
   ub1 = cmpEnergy(hist1_min, hist2_min, weights, nHistBin, 1, C);
   
   x.push_back(((double)(smallestWin1.lr_x - smallestWin1.ul_x))/Img1DimX);
   x.push_back(((double)(smallestWin1.lr_y - smallestWin1.ul_y))/Img1DimY);
   pr1 = CalcLogGauss( x,  FG_Prior_Mu,  FG_Prior_S, isWinFlexible);
   x.clear();
   x.push_back(((double)(smallestWin2.lr_x - smallestWin2.ul_x))/Img2DimX);
   x.push_back(((double)(smallestWin2.lr_y - smallestWin2.ul_y))/Img2DimY);
   pr2 = CalcLogGauss( x,  FG_Prior_Mu,  FG_Prior_S, isWinFlexible);

   //ub1 -= SCAL_CONST*(exp(pr1)+exp(pr2));
   ub1 -= ((pr1)+(pr2));
   ub = ub1;

   bestBBoxes = WindowPair(smallestWin1, smallestWin2);

   ub2 = cmpEnergy(hist1_min, hist2_max, weights, nHistBin, 1, C);
   
   x.push_back(((double)(smallestWin1.lr_x - smallestWin1.ul_x))/Img1DimX);
   x.push_back(((double)(smallestWin1.lr_y - smallestWin1.ul_y))/Img1DimY);
   pr1 = CalcLogGauss( x,  FG_Prior_Mu,  FG_Prior_S, isWinFlexible);
   x.clear();
   x.push_back(((double)(largestWin2.lr_x - largestWin2.ul_x))/Img2DimX);
   x.push_back(((double)(largestWin2.lr_y - largestWin2.ul_y))/Img2DimY);
   pr2 = CalcLogGauss( x,  FG_Prior_Mu,  FG_Prior_S, isWinFlexible);
   //ub2 -= SCAL_CONST*(exp(pr1)+exp(pr2));
   ub2 -= ((pr1)+(pr2));
   
   if (ub > ub2){
      ub = ub2;
      bestBBoxes = WindowPair(smallestWin1, largestWin2);
   }

   ub3 = cmpEnergy(hist1_max, hist2_min, weights, nHistBin, 1, C);
   
   x.push_back(((double)(largestWin1.lr_x - largestWin1.ul_x))/Img1DimX);
   x.push_back(((double)(largestWin1.lr_y - largestWin1.ul_y))/Img1DimY);
   pr1 = CalcLogGauss( x,  FG_Prior_Mu,  FG_Prior_S, isWinFlexible);
   x.clear();
   x.push_back(((double)(smallestWin2.lr_x - smallestWin2.ul_x))/Img2DimX);
   x.push_back(((double)(smallestWin2.lr_y - smallestWin2.ul_y))/Img2DimY);
   pr2 = CalcLogGauss( x,  FG_Prior_Mu,  FG_Prior_S, isWinFlexible);
   
   //ub3 -= SCAL_CONST*(exp(pr1)+exp(pr2));
   ub3 -= ((pr1)+(pr2));
   
   if (ub > ub3){
      ub = ub3;
      bestBBoxes = WindowPair(largestWin1, smallestWin2);
   }

   ub4 = cmpEnergy(hist1_max, hist2_max, weights, nHistBin, 1, C);
   x.push_back(((double)(largestWin1.lr_x - largestWin1.ul_x))/Img1DimX);
   x.push_back(((double)(largestWin1.lr_y - largestWin1.ul_y))/Img1DimY);
   pr1 = CalcLogGauss( x,  FG_Prior_Mu,  FG_Prior_S, isWinFlexible);
   x.clear();
   x.push_back(((double)(largestWin2.lr_x - largestWin2.ul_x))/Img2DimX);
   x.push_back(((double)(largestWin2.lr_y - largestWin2.ul_y))/Img2DimY);
   pr2 = CalcLogGauss( x,  FG_Prior_Mu,  FG_Prior_S, isWinFlexible);

   //ub4 -= SCAL_CONST*(exp(pr1)+exp(pr2));
   ub4 -= ((pr1)+(pr2));
   
   if (ub > ub4){
      ub = ub4;
      bestBBoxes = WindowPair(largestWin1, largestWin2);
   }

   destroyVector<int>(hist1_min, nHistBin);
   destroyVector<int>(hist1_max, nHistBin);
   destroyVector<int>(hist2_min, nHistBin);
   destroyVector<int>(hist2_max, nHistBin);

//   cmpUb1();
};
#if 0
void
TreeNode2a::cmpUb1(){
   Window randWin2 = winPair2.getRandomWin();
   Window randWin1 = winPair1.getRandomWin();
   int *hist2_rand = randWin2.getPyrHist(integralIms2, nHistBin, 1);
   int *hist1_rand = randWin1.getPyrHist(integralIms1, nHistBin, 1);

   double newUb = cmpEnergy(hist1_rand, hist2_rand, weights, nHistBin, 1, C);
   if (ub > newUb){
      ub = newUb;
      bestBBoxes = WindowPair(randWin1, randWin2);
   }
   
   destroyVector<int>(hist1_rand, nHistBin);
   destroyVector<int>(hist2_rand, nHistBin);   
}

void
TreeNode2a::cmpUb2(double knownBest){
   Window smallestWin2 = winPair2.getSmallestWin();
   int *hist2_min = smallestWin2.getPyrHist(integralIms2, nHistBin, 1);
   Window largestWin2 = winPair2.getLargestWin();
   int *hist2_max = largestWin2.getPyrHist(integralIms2, nHistBin, 1);

   Window bestWin1a = findBox1a_helper(integralIms1, TreeNode1a(winPair1), 
      hist2_min, weights, nHistBin, 1, C, 0, knownBest); //K = 1
   Window bestWin1b = findBox1a_helper(integralIms1, TreeNode1a(winPair1), 
      hist2_max, weights, nHistBin, 1, C, 0, knownBest); //K = 1

   int *bestWin1a_hist = bestWin1a.getPyrHist(integralIms1, nHistBin, 1);
   int *bestWin1b_hist = bestWin1b.getPyrHist(integralIms1, nHistBin, 1);

   double ub5 = cmpEnergy(bestWin1a_hist, hist2_min, weights, nHistBin, 1, C);
   double ub6 = cmpEnergy(bestWin1b_hist, hist2_max, weights, nHistBin, 1, C);
   ub = min(ub, min(ub5, ub6));

   destroyVector<int>(bestWin1a_hist, nHistBin);
   destroyVector<int>(bestWin1b_hist, nHistBin);
   destroyVector<int>(hist2_min, nHistBin);
   destroyVector<int>(hist2_max, nHistBin);
}


void
TreeNode2a::cmpUb3(double knownBest){
   Window randWin2 = winPair2.getRandomWin();
   int *hist2_rand = randWin2.getPyrHist(integralIms2, nHistBin, 1);
   
   Window bestWin1 = findBox1a_helper(integralIms1, TreeNode1a(winPair1), 
      hist2_rand, weights, nHistBin, 1, C, 0, knownBest); //K = 1
   
   int *bestWin1_hist = bestWin1.getPyrHist(integralIms1, nHistBin, 1);  

   double ub5 = cmpEnergy(bestWin1_hist, hist2_rand, weights, nHistBin, 1, C);
   if (ub > ub5){
      ub = ub5;
      bestBBoxes = WindowPair(bestWin1, randWin2);
   }
   
   destroyVector<int>(bestWin1_hist, nHistBin);
   destroyVector<int>(hist2_rand, nHistBin);   
}

#endif


TreeNode2a::TreeNode2a(WindowPair winPair1_, WindowPair winPair2_){
   winPair1 = winPair1_;
   winPair2 = winPair2_;
}



void
TreeNode2a::split(TreeNode2a *left, TreeNode2a *right){
   if (winPair1.getMaxDim() > winPair2.getMaxDim()){ // split the first win pair
      left->winPair2 = winPair2;
      right->winPair2 = winPair2;
      winPair1.split(&(left->winPair1), &(right->winPair1));
   } else {
      left->winPair1 = winPair1;
      right->winPair1 = winPair1;
      winPair2.split(&(left->winPair2), &(right->winPair2));
   }
}


typedef priority_queue < TreeNode2a, vector<TreeNode2a>, TreeNodeCompare<TreeNode2a> > TreeNode2Queue;

TreeNode2Queue pruneQueue(TreeNode2Queue myQ, double pruneVal){
   vector<TreeNode2a> remainElems;
   int queueSz = myQ.size();
   for (int i = 0; i < queueSz; i++){
      TreeNode2a topNode = myQ.top();
      myQ.pop();
      if (topNode.lb <= pruneVal){
         remainElems.push_back(topNode);
      }
   }
   TreeNode2Queue prunedQueue(remainElems.begin(), remainElems.end());
   return prunedQueue;  

}

/**
 * Simultaneously find similar rectangles in two images
 *    by minimzing the objective:
 *    sum_i {weights(i)*[|hist1(i) - hist2(i)| - C*(hist1(i) + hist2(i)]}
 * Inputs:
 *    imAssign1, imAssign2: a 2 dim array for histogram bin assignments, entries should be
 *       positive integers.
 *    imH1, imW1, imH2, imW2: heigh and width of the images
 *    weights: a 1-dim array for weights for histogram bins
 *    nHistBin: # of histogram bins
 *    C: tradeoff b/t having good match to the target histogram and the size of the box
 *    tolFactor: tolerence factor for stopping criteria of branch and bound
 *       if tolFactor = 0, run BB until global optimality is known.
 *       the bigger tolFactor, the earlier BB terminates.
 *    knownBest: the solution is known to be better than this value.
 *       branches with the lower bound less than this value is not explored.
 *       if no leaf node has energy smaller than this value, the method
 *       return an arbitrary solution.
 * Output:
 *    Best (within tolerence) rectangles that minimizes the desired energy
 */
WindowPair findBoxes2a(int **imAssign1, int imH1, int imW1, 
                       int **imAssign2, int imH2, int imW2, 
                       double *weights, int nHistBin, 
                       double C, double tolFactor, double knownBest, vector<double> Mu, vector<double> S, bool FlexWin){

   int ***integralIms1 = cmpIntegralIms(imAssign1, imH1, imW1, nHistBin);
   int ***integralIms2 = cmpIntegralIms(imAssign2, imH2, imW2, nHistBin);
   
   TreeNode2a::integralIms1 = integralIms1;
   TreeNode2a::integralIms2 = integralIms2;
   TreeNode2a::nHistBin = nHistBin;
   TreeNode2a::weights = weights;
   TreeNode2a::C = C;

	FG_Prior_Mu = Mu;
	FG_Prior_S = S;
    Img1DimX = imW1;
    Img1DimY = imH1;
	Img2DimX = imW2;
    Img2DimY = imH2;
    isWinFlexible = FlexWin;
    

   Window biggestWin1(0,0, imW1-1, imH1-1);
   Window biggestWin2(0,0, imW2-1, imH2-1);

   TreeNode2a rootNode(WindowPair(biggestWin1, biggestWin1), 
                      WindowPair(biggestWin2, biggestWin2));

   TreeNode2a bestNode = m_branch_bound<TreeNode2a>(rootNode, tolFactor);

   destroyArrayThree<int>(integralIms1, imH1, imW1, nHistBin);
   destroyArrayThree<int>(integralIms2, imH2, imW2, nHistBin);   
   return bestNode.bestBBoxes; 
}

