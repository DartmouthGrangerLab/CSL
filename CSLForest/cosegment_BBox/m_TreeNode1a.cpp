#include <cmath>
#include <queue>

#include "m_malloc.h"
#include "m_utils.h"
#include "m_BranchBound.cpp"
#include "m_TreeNode1a.h"
#include "mex.h"

 vector<double> FG_Prior_Mu;
 vector<double> FG_Prior_S;
 double ImgDimX = 0;
 double ImgDimY = 0;
 bool isWinFlexible = false;

void TreeNode1a::cmpBnds(){
	//mexPrintf("d");
	//mexPrintf("1");
   Window smallestWin = winPair.getSmallestWin();
   //mexPrintf("2");
   int *hist1_min = smallestWin.getPyrHist(integralIms, nHistBin, K);
  // mexPrintf("3");
   Window largestWin = winPair.getLargestWin();
   //mexPrintf("4");
   int *hist1_max = largestWin.getPyrHist(integralIms, nHistBin, K);
   //mexPrintf("5");
   lb = getLowerBnd1(hist1_min, hist1_max, hist_target, binWeights, nHistBin, K, C);
   //mexPrintf("6");
   vector<double> bestwin = GetBestWin( smallestWin, largestWin, FG_Prior_Mu, FG_Prior_S, ImgDimX, ImgDimY, isWinFlexible);
   double pr1 = CalcLogGauss(bestwin , FG_Prior_Mu,  FG_Prior_S, isWinFlexible);

   lb = lb - pr1;
   //mexPrintf("7");
   ub = cmpEnergy(hist1_max, hist_target, binWeights, nHistBin, K, C);

   vector<double>x;
   x.push_back(((double)(largestWin.lr_x - largestWin.ul_x))/ImgDimX);
   x.push_back(((double)(largestWin.lr_y - largestWin.ul_y))/ImgDimY);
   double pr2 = CalcLogGauss( x,  FG_Prior_Mu,  FG_Prior_S, isWinFlexible);
   ub = ub - pr2;

   //mexPrintf("processing cmpBnds [%d,%d,%d,%d], [%d,%d,%d,%d], %.2f, %.2f, %.2f, %.2f\n",winPair.win1.ul_x+1,winPair.win1.ul_y+1,winPair.win1.lr_x+1,winPair.win1.lr_y+1,winPair.win2.ul_x+1,winPair.win2.ul_y+1,winPair.win2.lr_x+1,winPair.win2.lr_y+1, lb, ub, lb + pr1, ub + pr2);

   destroyVector<int>(hist1_min, nHistBin*K);
   destroyVector<int>(hist1_max, nHistBin*K);
   //mexPrintf("/");
};


int ***TreeNode1a::integralIms = NULL;
int *TreeNode1a::hist_target = NULL;
double *TreeNode1a::binWeights = NULL;
int TreeNode1a::nHistBin = 0;
double TreeNode1a::C = 0;
int TreeNode1a::K = 0;


/**
 * Find the best box in an image matching the given target histogram
 *    by minimzing the objective:
 *    sum_i {weights(i)*[|hist(i) - hist_target(i)| - C*(hist(i) + hist_target(i)]}
 * Inputs:
 *    imAssign: a 2 dim array for histogram bin assignments, entries should be
 *       positive integers.
 *    imH, imW: heigh and width of the image
 *    hist_target: a 1-dim array for target histogram
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
 *    A best (within tolerence) rectangle that minimizes the desired energy
 */

Window findBox1a(int **imAssign, int imH, int imW, int *hist_target, double *weights,
                 int nHistBin, int K, double C, double tolFactor, double knownBest, vector<double> Mu, vector<double> S, bool FlexWin){
   mexPrintf("b");
	int ***integralIms = cmpIntegralIms(imAssign, imH, imW, nHistBin);
   Window biggestWin(0,0, imW-1, imH-1);
   TreeNode1a rootNode(WindowPair(biggestWin, biggestWin));

	FG_Prior_Mu = Mu;
	FG_Prior_S = S;
    ImgDimX = imW;
    ImgDimY = imH;
    isWinFlexible = FlexWin;


   Window bestBB = findBox1a_helper(integralIms, rootNode, hist_target, weights, nHistBin, K,
      C, tolFactor, knownBest);
   destroyArrayThree<int>(integralIms, imH, imW, nHistBin);
   mexPrintf("/");
   return bestBB;
}

Window findBox1a_helper(int ***integralIms, TreeNode1a rootNode,
                      int *hist_target, double *weights, int nHistBin, int K,
                      double C, double tolFactor, double knownBest){
	mexPrintf("c");
   TreeNode1a::integralIms = integralIms;
   TreeNode1a::hist_target = hist_target;
   TreeNode1a::binWeights = weights;
   TreeNode1a::nHistBin = nHistBin;
   TreeNode1a::C = C;
   TreeNode1a::K = K;

   TreeNode1a bestNode = m_branch_bound<TreeNode1a>(rootNode, tolFactor);
   //mexPrintf("-->\n");
   mexPrintf("/");
   return bestNode.winPair.getLargestWin();
   //Window asdf= bestNode.winPair.getLargestWin();
   //mexPrintf("<--\n");
   //return asdf;
}
