#ifndef M_BRANCHBOUND_H
#define M_BRANCHBOUND_H
#include <ctime>
#include <iostream>
#include <cmath>
#include <queue>
#include <string>
#include <vector>
#include "m_utils.h"
#include "mex.h"
using namespace std;

template<class TreeNode>
TreeNode m_branch_bound(TreeNode rootNode, double tolFac){
   double bestUb, newUb;
   TreeNode topNode, bestNode;
   priority_queue < TreeNode, vector<TreeNode>, TreeNodeCompare<TreeNode> > myQ;
   rootNode.cmpBnds();
   bestUb = rootNode.ub;
   myQ.push(rootNode);
   bestNode = rootNode;
   int itr = 0;
#ifdef RUN_DEBUG_FROM_C
   int count =0;
   time_t curTime = time(NULL);
   time_t startTime = curTime;
   time_t pastTime = curTime;
#endif

   while (1){
	  itr++;
      if (myQ.size() == 0) break;
      topNode = myQ.top(); myQ.pop();
      if (isWithinTolFactor(bestUb, topNode.lb, tolFac)) break;
	  if (itr > 100000) break;
      TreeNode left, right;
      topNode.split(&left, &right);
      left.cmpBnds();
      right.cmpBnds();

      if (!isWithinTolFactor(bestUb, left.lb, tolFac)) {
         myQ.push(left);
         newUb = left.ub;
         if (bestUb > newUb){
            bestUb = newUb;
            bestNode = left;
         }
      }

      if (!isWithinTolFactor(bestUb, right.lb, tolFac)){
         myQ.push(right);
         newUb = right.ub;
         if (bestUb > newUb){
            bestUb = newUb;
            bestNode = right;
         }
      }

#ifdef RUN_DEBUG_FROM_C
      count++;
      if ((count % 1000) == 0){
         curTime = time(NULL);
         cout << count << " " << myQ.size() << ", bestUb: " << bestUb << ", top lb: " << topNode.lb <<
            ", left: " << left.lb << ", right: " << right.lb <<
            ", time: " << difftime(curTime, pastTime) << endl;
         pastTime = curTime;
      }
#endif
   }
#ifdef RUN_DEBUG_FROM_C
   cout << "Total iters: " << count << ", time: " << difftime(time(NULL), startTime) << endl;
#endif

   return bestNode;
   //_CrtDumpMemoryLeaks();
}
#endif
