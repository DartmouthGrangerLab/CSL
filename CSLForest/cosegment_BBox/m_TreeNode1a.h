#ifndef M_TREENODE1A_H
#define M_TREENODE1A_H

#include "m_TreeNode1.h"
#include <vector>
class TreeNode1a:public TreeNode1{
public:
   static int ***integralIms;
   static int *hist_target;
   static double *binWeights;
   static int nHistBin;
   static double C;
   static int K;

   TreeNode1a(WindowPair winPair_):TreeNode1(winPair_){};
   TreeNode1a():TreeNode1(){};   
   void cmpBnds();   
};

//ASHOK
Window findBox1a(int **imAssign, int imH, int imW, 
               int *hist_target, double *weights, 
               int nHistBin, int K, double C, double tolFactor, double knownBest, vector<double> Mu, vector<double> S, bool FlexWin);
Window findBox1a_helper(int ***integralIms, TreeNode1a rootNode, 
                      int *hist_target, double *weights, 
                      int nHistBin, int K, double C, double tolFactor, double knownBest);


#endif
