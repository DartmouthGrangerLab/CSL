#include <iostream>
#include <fstream>
#include <cmath>
#include <queue>
#include <string>
#include <sstream>
#include "m_malloc.h"
#include "m_utils.h"
#include "time.h"
#include "m_TreeNode2b.h"
#include "m_BranchBound.cpp"

using namespace std;



string 
TreeNode2b::str(){
   ostringstream rslt;
   rslt << win1.str() << ", " << win2.str() << ", " << szRange.str();
   return rslt.str();
};

void
TreeNode2b::refine(){
   //Check if this is space is empty
   if ((win1.ul_x + szRange.wmin > imW1) ||
       (win1.ul_y + szRange.hmin > imH1) ||
       (win2.ul_x + szRange.wmin > imW2) ||
       (win2.ul_y + szRange.hmin > imH2)){
      isEmpty = true;
   } else {
      isEmpty = false;
   }

   //croping the rectangles for upper left corners if it can
   if (win1.lr_x + szRange.wmin > imW1){
      win1.lr_x = imW1 - szRange.wmin;
   }
   if (win2.lr_x + szRange.wmin > imW2){
      win2.lr_x = imW2 - szRange.wmin;
   }
   if (win1.lr_y + szRange.hmin > imH1){
      win1.lr_y = imH1 - szRange.hmin;
   }
   if (win2.lr_y + szRange.hmin > imH2){
      win2.lr_y = imH2 - szRange.hmin;
   }
   //reducing the wmax if there is redundancy
   if (win1.ul_x + szRange.wmax > imW1){
      szRange.wmax = imW1 - win1.ul_x;
   }
   if (win2.ul_x + szRange.wmax > imW2){
      szRange.wmax = imW2 - win2.ul_x;
   }
   //reducing hmax if it can
   if (win1.ul_y + szRange.hmax > imH1){
      szRange.hmax = imH1 - win1.ul_y;
   }
   if (win2.ul_y + szRange.hmax > imH2){
      szRange.hmax = imH2 - win2.ul_y;
   }
}


Window 
TreeNode2b::getIntersection(Window win, SizeRange szRange){
   if ((win.lr_x - win.ul_x >= szRange.wmin) || 
      (win.lr_y - win.ul_y >= szRange.hmin)){
       return Window();
   } else {
      return Window(win.lr_x, win.lr_y, 
         win.ul_x + szRange.wmin-1, win.ul_y + szRange.hmin - 1);
   }
}

Window 
TreeNode2b::getUnion(Window win, SizeRange szRange, int imH, int imW){
   return Window(win.ul_x, win.ul_y, 
      min(imW-1, win.lr_x + szRange.wmax - 1), min(imH-1,win.lr_y + szRange.hmax - 1));
}

int*
TreeNode2b::getMinHist(int ***integralIm, int nHistBin, Window win, Res winRes){
   Window minWin = getIntersection(win, szRange);
   return minWin.getHist(integralIm, nHistBin, 1, winRes); 
}

int*
TreeNode2b::getMaxHist(int ***integralIm, int nHistBin, Window win, int imH, int imW, Res winRes){
   Window maxWin = getUnion(win, szRange, imH, imW);
   return maxWin.getHist(integralIm, nHistBin, 1, winRes); 
}

void
TreeNode2b::cmpBnds(){   
   int *hist1_min = getMinHist(integralIms1, nHistBin, win1, winRes1);
   int *hist1_max = getMaxHist(integralIms1, nHistBin, win1, imH1, imW1, winRes1);

   int *hist2_min = getMinHist(integralIms2, nHistBin, win2, winRes2);
   int *hist2_max = getMaxHist(integralIms2, nHistBin, win2, imH2, imW2, winRes2);

   lb = getLowerBnd2(hist1_min, hist1_max, hist2_min, hist2_max, weights,
                     nHistBin, C);

   // Randomly pick the two rectangels of the same size in two images
   srand((unsigned int)time(0));
   double alpha = ((double)(rand() % 1000))/1000;
   double beta  = ((double)(rand() % 1000))/1000;
   int w = (int)ceil(szRange.wmax + alpha*(szRange.wmin - szRange.wmax));
   int h = (int)ceil(szRange.hmax + beta*(szRange.hmin  - szRange.hmax));

   Window box1, box2;
   box1.ul_x = (int)floor(win1.ul_x + alpha*(win1.lr_x - win1.ul_x));
   box1.ul_y = (int)floor(win1.ul_y +  beta*(win1.lr_y - win1.ul_y));   
   box1.lr_x = box1.ul_x + w -1;
   box1.lr_y = box1.ul_y + h - 1;

   box2.ul_x = (int)floor(win2.ul_x + alpha*(win2.lr_x - win2.ul_x));
   box2.ul_y = (int)floor(win2.ul_y +  beta*(win2.lr_y - win2.ul_y));   
   box2.lr_x = box2.ul_x + w -1;
   box2.lr_y = box2.ul_y + h - 1;

   bestBoxes = WindowPair(box1, box2);

   int *hist1 = box1.getHist(integralIms1, nHistBin, 1, winRes1);
   int *hist2 = box2.getHist(integralIms2, nHistBin, 1, winRes2);
   ub = cmpEnergy(hist1, hist2, weights, nHistBin, 1, C);

   destroyVector<int>(hist1_min, nHistBin);
   destroyVector<int>(hist1_max, nHistBin);
   destroyVector<int>(hist2_min, nHistBin);
   destroyVector<int>(hist2_max, nHistBin);
   destroyVector<int>(hist1, nHistBin);
   destroyVector<int>(hist2, nHistBin);
}


void
TreeNode2b::split(TreeNode2b *left, TreeNode2b *right){
   int s1 = win1.getMaxDim();
   int s2 = win2.getMaxDim();
   int s3 = szRange.hmax - szRange.hmin;
   int s4 = szRange.wmax - szRange.wmin;

   if (max(s3, s4) > max(s1, s2)){
      left->win1 = win1;
      left->win2 = win2;
      right->win1 = win1;
      right->win2 = win2;

      Window win3(szRange.wmin, szRange.hmin, szRange.wmax, szRange.hmax);
      Window win3a, win3b;
      win3.split(&win3a, &win3b); 
      left->szRange  = SizeRange(win3a.ul_y, win3a.lr_y, win3a.ul_x, win3a.lr_x);
      right->szRange = SizeRange(win3b.ul_y, win3b.lr_y, win3b.ul_x, win3b.lr_x);
   } else {
      left->szRange = szRange;
      right->szRange = szRange;
      if (s1 >= s2){
         win1.split(&(left->win1), &(right->win1));
         left->win2  = win2;
         right->win2 = win2;         
      } else {
         win2.split(&(left->win2), &(right->win2));
         left->win1  = win1;
         right->win1 = win1;         
      }
   }
   left->refine();
   right->refine();
}

int ***TreeNode2b::integralIms1 = NULL;
int TreeNode2b::imH1 = 0;
int TreeNode2b::imW1 = 0;
int ***TreeNode2b::integralIms2 = NULL;
int TreeNode2b::imH2 = 0;
int TreeNode2b::imW2 = 0;
int TreeNode2b::nHistBin = 0;
double *TreeNode2b::weights = NULL;
double TreeNode2b::C = 0;
Res TreeNode2b::winRes1 = Res();
Res TreeNode2b::winRes2 = Res();

/**
 * Simultaneously find same-sized rectangles in two images that have similar 
 *    histograms.    
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
 *    winRes1, winRes2: resolutions of grid search in image 1 and 2
 * Output:
 *    Best (within tolerence) same-sized rectangles that minimizes the desired energy
 */
WindowPair findBoxes2b(int **imAssign1, int imH1, int imW1, 
                       int **imAssign2, int imH2, int imW2, 
                       double *weights, int nHistBin, 
                       double C, double tolFactor, double knownBest,
                       Res winRes1, Res winRes2){

   int ***integralIms1 = cmpIntegralIms(imAssign1, imH1, imW1, nHistBin);
   int ***integralIms2 = cmpIntegralIms(imAssign2, imH2, imW2, nHistBin);
   int oldImH1, oldImW1, oldImH2, oldImW2;
   oldImH1 = imH1; oldImW1 = imW1;
   oldImH2 = imH2; oldImW2 = imW2;
   imH1 = (int) floor(((double)imH1)/winRes1.y);
   imW1 = (int) floor(((double)imW1)/winRes1.x);
   imH2 = (int) floor(((double)imH2)/winRes2.y);
   imW2 = (int) floor(((double)imW2)/winRes2.x);
   TreeNode2b::integralIms1 = integralIms1;
   TreeNode2b::imH1 = imH1;
   TreeNode2b::imW1 = imW1;
   TreeNode2b::integralIms2 = integralIms2;
   TreeNode2b::imH2 = imH2;
   TreeNode2b::imW2 = imW2;
   TreeNode2b::nHistBin = nHistBin;
   TreeNode2b::weights = weights;
   TreeNode2b::C = C;
   TreeNode2b::winRes1 = winRes1;
   TreeNode2b::winRes2 = winRes2;
   
   Window biggestWin1(0,0, imW1-1, imH1-1);
   Window biggestWin2(0,0, imW2-1, imH2-1);
   SizeRange biggestSzRange(1, min(imH1, imH2), 1, min(imW1, imW2));
   TreeNode2b rootNode(biggestWin1, biggestWin2, biggestSzRange);
   TreeNode2b bestNode = m_branch_bound<TreeNode2b>(rootNode, tolFactor);

   destroyArrayThree<int>(integralIms1, oldImH1, oldImW1, nHistBin);
   destroyArrayThree<int>(integralIms2, oldImH2, oldImW2, nHistBin);   
   return WindowPair(Window(bestNode.bestBoxes.win1, winRes1), 
                     Window(bestNode.bestBoxes.win2, winRes2));  
}
