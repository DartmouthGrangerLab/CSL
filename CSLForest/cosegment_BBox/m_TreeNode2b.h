#ifndef M_TREENODE2B_H
#define M_TREENODE2B_H




class TreeNode2b{
public:
   static int ***integralIms1, imH1, imW1, ***integralIms2, imH2, imW2, nHistBin;
   static double *weights, C;
   static Res winRes1, winRes2;


   double lb, ub;
   Window win1, win2;
   WindowPair bestBoxes;
   SizeRange szRange;
   bool isEmpty;

   void cmpBnds();
   TreeNode2b(Window win1_, Window win2_, SizeRange szRange_):
      win1(win1_),win2(win2_), szRange(szRange_){};
   TreeNode2b(){};
   void split(TreeNode2b *left, TreeNode2b *right);   
   // refine the parameter space by croping the rectangle for uper left corners
   // or by limiting the size of the rectangles.
   void refine();
   string str();
protected:
   Window getIntersection(Window win, SizeRange szRange);
   Window getUnion(Window win, SizeRange szRange, int imH, int imW);
   int *getMinHist(int ***integralIm, int nHistBin, Window win, Res winRes);
   int *getMaxHist(int ***integralIm, int nHistBin, Window win, int imH, int imW, Res winRes);

};

WindowPair 
findBoxes2b(int **imAssign1, int imH1, int imW1, 
          int **imAssign2, int imH2, int imW2, 
          double *weights, int nHistBin, 
          double C, double tolFactor, double knownBest,
          Res winRes1 = Res(), Res winRes2 = Res());

#endif