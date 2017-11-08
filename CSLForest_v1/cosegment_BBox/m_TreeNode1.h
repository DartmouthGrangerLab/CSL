#ifndef M_TREENODE1_H
#define M_TREENODE1_H
#include "m_utils.h"

class TreeNode1{   
public:
   WindowPair winPair;
   double lb, ub;   
   TreeNode1(WindowPair winPair_);
   TreeNode1(){};   

   // Split the TreeNode1 into 2 new one.
   // Split the dimension with beggest size.
   void split(TreeNode1 *left, TreeNode1 *right);
   void cmpBnds();
};


#endif