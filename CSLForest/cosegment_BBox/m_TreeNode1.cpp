#include <iostream>
#include <fstream>
#include <cmath>
#include <queue>
#include <string>
#include <sstream>
#include "m_malloc.h"
#include "m_utils.h"
#include "time.h"
#include "m_TreeNode1.h"

TreeNode1::TreeNode1(WindowPair winPair_){
   winPair = winPair_;
};


// Split the TreeNode1 into 2 new one.
// Split the dimension with beggest size.
void TreeNode1::split(TreeNode1 *left, TreeNode1 *right){
   winPair.split(&(left->winPair), &(right->winPair));
};


//TreeNode1a::TreeNode1a(WindowPair winPair_){
//}


