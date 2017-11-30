#ifndef M_TREENODE2A_H
#define M_TREENODE2A_H


class TreeNode2a{
public:
   static int ***integralIms1, ***integralIms2, nHistBin;
   static double *weights, C;

   WindowPair winPair1, winPair2, bestBBoxes;
   double lb, ub;
   void cmpBnds();
   
   TreeNode2a(WindowPair winPair1_, WindowPair winPair2_);
   TreeNode2a(){};
   void split(TreeNode2a *left, TreeNode2a *right);
protected:
   void cmpUb1();
   void cmpUb2(double knownBest);
   void cmpUb3(double knownBest);

};

WindowPair findBoxes2a(int **imAssign1, int imH1, int imW1, 
                      int **imAssign2, int imH2, int imW2, 
                      double *binWeights, int nHistBin, 
                      double C, double tolFactor, double knownBest,vector<double> Mu, vector<double> S, bool FlexWin);

#endif
