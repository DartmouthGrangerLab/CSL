#ifndef M_UTILS_H
#define M_UTILS_H

#include<string>
#include "m_malloc.h"
#include <limits>
#include <vector>

using namespace std;

#define INF numeric_limits<double>::infinity()
#define EPS 0.0000000001
#define PYR_LVLS  1




/* Compute Integral image
 * im: 2D array of int. Each entry must be a POSITIVE integer
 * which is less than or equal to nHistBin
 * Compute Integral Images for histograms using dynamic programming.
 */
int*** cmpIntegralIms(int **im, int imH, int imW, int nHistBin);

/* The lower bound is obtained by minimize:
 * abs(h1 - h_target) - C*h1 with h1_min <= h1 <= h1_max
 * This assume 0 <= C <= 1
 */
double getLowerBnd1_helper(int h1_min, int h1_max, int h_target, double C);

/* The lower bound is obtained by minimize:
 * abs(h1 - h2) - C*(h1 + h2) 
 * s.t. h1_min <= h1 <= h1_max and h2_min <= h2 <= h2_max
 * This assume 0 <= C <= 1 and h1_max <= h2_max;
 */
double getLowerBnd2_helper2(int h1_min, int h1_max, int h2_min, int h2_max, double C);

/* The lower bound is obtained by minimize:
 * abs(h1 - h2) - C*(h1 + h2) 
 * s.t. h1_min <= h1 <= h1_max and h2_min <= h2 <= h2_max
 * This assume 0 <= C <= 1
 */
double getLowerBnd2_helper(int h1_min, int h1_max, int h2_min, int h2_max, double C);
double getLowerBnd1(int* hist1_min, int* hist1_max, int* hist_target, double *weights,
                    int nHistBin, int K, double C);
double getLowerBnd2(int* hist1_min, int* hist1_max, int* hist2_min, int* hist2_max, double *weights,
                    int nHistBin, double C);
double cmpEnergy(int* hist1, int* hist2, double *weights, int nHistBin, int K, double C);
double cmpEnergy2(int *hist1, double *weights, int nHistBin, int K);

// ASHOK
int GetPyrCellCount();

class Res{
public:
   int x, y;
   Res(int x_ =1, int y_ = 1):x(x_), y(y_){};
};


class Window{
public:
   int ul_x, ul_y, lr_x, lr_y; // upper left and lower right corner
   Window(int ul_x_, int ul_y_, int lr_x_, int lr_y_);
   Window();
   Window(const Window &win);
   Window(const Window &win, Res winRes);

   /* Code added by Ashok for Pyramid histograms */
   void QuadSplit(Window *tl, Window *tr, Window *bl, Window *br);
   int* getPyrHist(int*** integralIms, int nHistBin, int K);

   int* getHist(int*** integralIms, int nHistBin, int K);
   int* getHist(int ***integralIms, int nHistBin, int K, Res winRes);
   int getMaxDim();
   void copy(Window *newWin);
   void split(Window *left, Window *right);
   Window getSubWin(int x, int y, int xDev, int yDev);
   bool operator ==(const Window& win);
   string str();
};


/* Contain 2 windows
 */
class WindowPair{
public:
   Window win1, win2;
   Window getSmallestWin();
   Window getLargestWin();
   Window getRandomWin();
   WindowPair(Window win1_, Window win2_);
   WindowPair();
   int getMaxDim();
   void copy(WindowPair *newWinPair);
   void split(WindowPair *left, WindowPair *right);   
   WindowPair getSubWinPair(int x, int y, int xDev, int yDev);
   string str();
private:
   int getRandNum(int minNum, int maxNum);
};


class SizeRange{
public:
   int hmin, hmax, wmin, wmax;
   SizeRange(int hmin_, int hmax_, int wmin_, int wmax_):
      hmin(hmin_), hmax(hmax_), wmin(wmin_), wmax(wmax_){};
   SizeRange(){};
   string str();
};



template <class AType>
class TreeNodeCompare{
public:
   bool operator() (const AType& lhs, const AType& rhs){
      return (lhs.lb > rhs.lb);      
   };
};


int **readImMatrix(char *fileName, int *imH_, int *imW_, int *nHistBin_);

bool isImAssignGood(int **imAssign, int imH, int imW);
bool isWithinTolFactor(double bestUb, double lb, double tolFactor);







double CalcLogGauss(vector<double>& x, vector<double> mu, vector<double> S, bool FlexWin);
vector<double> GetBestWin(Window smallestWin, Window largestWin, 
						  vector<double> Prior_Win_Mu, vector<double> Prior_Win_S, double dimX, double dimY, bool FlexWin);



#endif 
