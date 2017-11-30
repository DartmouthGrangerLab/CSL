#include <iostream>
#include <fstream>
#include <cmath>
#include <queue>
#include <string>
#include <sstream>
#include "m_malloc.h"
#include "m_utils.h"
#include "time.h"
#include "mex.h"

using namespace std;

vector<double> GetBestWin(Window smallestWin, Window largestWin, vector<double> Prior_Win_Mu, vector<double> Prior_Win_S, double dimX, double dimY, bool FlexWin)
{
	vector<double> x;
	double smallDimX = ((double)(smallestWin.lr_x - smallestWin.ul_x))/dimX;
	double smallDimY = ((double)(smallestWin.lr_y - smallestWin.ul_y))/dimY;
	double largeDimX = ((double)(largestWin.lr_x - largestWin.ul_x))/dimX;
	double largeDimY = ((double)(largestWin.lr_y - largestWin.ul_y))/dimY;

    if (!FlexWin)
    {
        // First X dim
        if (Prior_Win_Mu[0] >= largeDimX)
            x.push_back(largeDimX);
        else if (Prior_Win_Mu[0] <= smallDimX )
            x.push_back(smallDimX);
        else if (Prior_Win_Mu[0] > smallDimX && Prior_Win_Mu[0] < largeDimX)
            x.push_back(Prior_Win_Mu[0]);

        // now Y dim
        if (Prior_Win_Mu[1] >= largeDimY)
            x.push_back(largeDimY);
        else if (Prior_Win_Mu[1] <= smallDimY )
            x.push_back(smallDimY);
        else if (Prior_Win_Mu[1] > smallDimY && Prior_Win_Mu[1] < largeDimY)
            x.push_back(Prior_Win_Mu[1]);
    }
    else
    {
        if (Prior_Win_Mu[0]*Prior_Win_Mu[1] >= largeDimX*largeDimY)
        {
            x.push_back(largeDimX);
            x.push_back(largeDimY);
        }
        else if (Prior_Win_Mu[0]*Prior_Win_Mu[1] <= smallDimX*smallDimY)
        {
            x.push_back(smallDimX);
            x.push_back(smallDimY);
        }
        else if (Prior_Win_Mu[0]*Prior_Win_Mu[1] > smallDimX*smallDimY && Prior_Win_Mu[0]*Prior_Win_Mu[1] < largeDimX*largeDimY)
        {
            x.push_back(Prior_Win_Mu[0]);
            x.push_back(Prior_Win_Mu[1]);
        }
    }

    return x;
}


double CalcLogGauss(vector<double>& x, vector<double> mu, vector<double> S, bool FlexWin)
{
#define PI 3.14159265
    if (!FlexWin )
    {
        int M = x.size();
        double Denom = -0.5*M*log(2*PI);
        double Sum =0;
        for (int i = 0; i < M; i++)
         Sum += log (S[i]);
        Denom -=  0.5 * Sum;

        double Numer = 0;
        for (int i = 0; i < M; i++)
         Numer +=  (pow((x[i] - mu[i]), 2)/ S[i]);
        Numer *= -0.5;
        return (Numer + Denom);
    }
    else
    {
        int M = 1;
        double Denom = -0.5*M*log(2*PI);
        double Sum =0;
        for (int i = 0; i < M; i++)
        Sum += log (S[i]);
        Denom -=  0.5 * Sum;

        double Numer = 0;
        for (int i = 0; i < M; i++)
        Numer +=  (pow(((x[i]*x[i+1]) - (mu[i]*mu[i+1])), 2)/ S[i]);
        Numer *= -0.5;
        return (Numer + Denom);
    }
}







/* Compute Integral image
 * im: 2D array of int. Each entry must be a POSITIVE integer
 * which is less than or equal to nHistBin
 * Compute Integral Images for histograms using dynamic programming.

 The key here is dynamic programming
 */
extern double dimX;
int*** cmpIntegralIms(int **im, int imH, int imW, int nHistBin)
{
   int*** integralIms = buildArrayThree<int>(imH, imW, nHistBin);

   integralIms[0][0][im[0][0]-1] = 1;
   for (int j=1; j < imW; j++){
      for (int u=0; u < nHistBin; u++){
         integralIms[0][j][u] = integralIms[0][j-1][u];
      }
      integralIms[0][j][im[0][j] - 1]++;
   }

   for (int i=1; i < imH; i++){
      for (int u=0; u < nHistBin; u++){
         integralIms[i][0][u] = integralIms[i-1][0][u];
      }
      integralIms[i][0][im[i][0] - 1]++;
   }


   for (int i=1; i < imH; i++){
      for (int j=1; j < imW; j++){
         for (int k=0; k < nHistBin; k++){
            integralIms[i][j][k] = integralIms[i][j-1][k] + integralIms[i-1][j][k]
            - integralIms[i-1][j-1][k];
         }
         integralIms[i][j][im[i][j] - 1]++;
      }
   }
   return integralIms;
}


int GetPyrCellCount()
{
	int Count  = 0;
	for (int i = 0; i < PYR_LVLS; i++)
	{
		int Dims = pow((double)2.0, i);
		Count += Dims*Dims;
	}
	return Count;
}


/* The lower bound is obtained by minimize:
 * abs(h1 - h_target) - C*h1 with h1_min <= h1 <= h1_max
 * This assume 0 <= C <= 1
 */
double getLowerBnd1_helper(int h1_min, int h1_max, int h_target, double C){
   double lb;
   int h1;
   if (h_target < h1_min){
      h1 = h1_min;
   }else if (h_target > h1_max){
      h1 = h1_max;
   } else {
      h1 = h_target;
   }
   //lb = abs(h1 - h_target) - C*(h1 + h_target);
   lb = (h1 - h_target)*(h1 - h_target);
#if 0
   if (h1 + h_target > 0)
		lb = ((double)(h1 - h_target)*(h1 - h_target))    /    (double)(h1 + h_target);
	else
		lb = 0;
#endif
   return lb;
}

/* The lower bound is obtained by minimize:
 * abs(h1 - h2) - C*(h1 + h2)
 * s.t. h1_min <= h1 <= h1_max and h2_min <= h2 <= h2_max
 * This assume 0 <= C <= 1 and h1_max <= h2_max;
 */
double getLowerBnd2_helper2(int h1_min, int h1_max, int h2_min, int h2_max, double C){
   int h1, h2;

   h1 = h1_max;
   if (h2_min <= h1_max){
      h2 = h1_max;
   } else {
      h2 = h2_min;
   }
   double lb = abs(h1 - h2) - C*(h1 + h2);
   return lb;
}

/* The lower bound is obtained by minimize:
 * abs(h1 - h2) - C*(h1 + h2)
 * s.t. h1_min <= h1 <= h1_max and h2_min <= h2 <= h2_max
 * This assume 0 <= C <= 1
 */
double getLowerBnd2_helper(int h1_min, int h1_max, int h2_min, int h2_max, double C){
   double lb;
   if (h1_max <= h2_max){
      lb = getLowerBnd2_helper2(h1_min, h1_max, h2_min, h2_max, C);
   } else {
      lb = getLowerBnd2_helper2(h2_min, h2_max, h1_min, h1_max, C);
   }
   return lb;
}

double getLowerBnd1(int* hist1_min, int* hist1_max, int* hist_target, double *weights,
                    int nHistBin, int K, double C){
   double lb = 0;
   int PyrCells = GetPyrCellCount();
   for (int k=0; k < PyrCells*nHistBin*K; k++){
      lb += weights[k]*getLowerBnd1_helper(hist1_min[k], hist1_max[k], hist_target[k], C);
   }
   return lb;
}

double getLowerBnd2(int* hist1_min, int* hist1_max, int* hist2_min, int* hist2_max, double *weights,
                    int nHistBin, double C){
   double lb = 0;

   for (int k=0; k < nHistBin; k++){
      lb = lb + weights[k]*getLowerBnd2_helper(hist1_min[k], hist1_max[k], hist2_min[k], hist2_max[k], C);
   }
   return lb;
}



double cmpEnergy(int* hist1, int* hist2, double *weights, int nHistBin, int K, double C){
	int PyrCells = GetPyrCellCount();
	double energy = 0;
	for (int k= 0; k < PyrCells*nHistBin*K; k++){
		if (K == 1)
			energy += weights[k]*(abs(hist1[k] - hist2[k]) - C*(hist1[k] + hist2[k]));
		else
			energy += weights[k] * (hist1[k] - hist2[k])*(hist1[k] - hist2[k]);
	}
	return energy;
}


Window::Window(int ul_x_, int ul_y_, int lr_x_, int lr_y_):
   ul_x(ul_x_), ul_y(ul_y_), lr_x(lr_x_), lr_y(lr_y_){
};

Window::Window(){
   ul_x = -1;
   ul_y = -1;
   lr_x = -1;
   lr_y = -1;
};

Window::Window(const Window &win){
   ul_x = win.ul_x;
   ul_y = win.ul_y;
   lr_x = win.lr_x;
   lr_y = win.lr_y;
}

Window::Window(const Window &win, Res winRes){
   ul_x = win.ul_x*winRes.x;
   ul_y = win.ul_y*winRes.y;
   lr_x = win.lr_x*winRes.x;
   lr_y = win.lr_y*winRes.y;
};

/*
 * Code added by Ashok for Pyramid Histograms
 */
 void Window::QuadSplit(Window *tl, Window *tr, Window *bl, Window *br)
{
    copy(tl);
    copy(tr);
    copy(bl);
    copy(br);

	if (ul_x < 0 || ul_y < 0 || lr_x < 0 || lr_y < 0)
		return;

	int x1 = (ul_x + lr_x)/2;
	int y1 = (ul_y + lr_y)/2;

	int x2;
    int y2;

	if (ul_x < lr_x)
		x2 = x1 + 1;
	else
		x2 = x1;

    if (ul_y < lr_y)
		y2 = y1 + 1;
	else
		y2 = y1;

	tl->lr_x = x1;
    tl->lr_y = y1;

	tr->ul_x = x2;
	tr->lr_y = y1;

	bl->ul_y = y2;
	bl->lr_x = x1;

	br->ul_x = x2;
	br->ul_y = y2;

}

int* Window::getPyrHist(int*** integralIms, int nHistBin, int K){

	vector<int*> HistQ (0, NULL);
	vector<Window> CurrQ(1, *this) ;
	vector<Window> NxtQ ;
	for (int lvl = 0; lvl < PYR_LVLS; lvl++)
	{
		while (!CurrQ.empty())
		{
			// get the front window and pop it
			Window w = CurrQ[0];
			CurrQ.erase(CurrQ.begin());
			// Get  the histogram
			HistQ.push_back(w.getHist(integralIms, nHistBin, K));
			// split it into 4 peices and save the windows to the NxtQ
			Window tl, tr, bl, br;
			w.QuadSplit(&tl, &tr, &bl, &br);
			NxtQ.push_back(tl);
			NxtQ.push_back(tr);
			NxtQ.push_back(bl);
			NxtQ.push_back(br);
		}
		CurrQ = NxtQ;
		NxtQ.clear();
	}
	int* FinalHist = buildVector<int>(HistQ.size()*nHistBin*K);
	//mexPrintf("[%d,%d,%d,%d]-->|\n",ul_x+1,ul_y+1,lr_x+1,lr_y+1);
	for (int i = 0; i < HistQ.size(); i++){
		for(int j = 0; j < nHistBin*K; j++){
			FinalHist[i*nHistBin*K + j] = HistQ[i][j];
			//if (FinalHist[i*nHistBin*K + j] != 0 && i*nHistBin*K + j < 50){
			//	mexPrintf("%d,",FinalHist[i*nHistBin*K + j]);
			//}
		}
	}
	//mexPrintf("\n");
	// delete the hist Q
	for (int i = 0; i < HistQ.size(); i++)
		destroyVector<int>(HistQ[i], nHistBin*K);
	HistQ.clear();
	return FinalHist;
}

int* Window::getHist(int*** integralIms, int nHistBin, int K){
   int* hist = buildVector<int>(nHistBin*K);
   //mexPrintf("[%d,%d,%d,%d]-->",ul_x,ul_y,lr_x,lr_y);
   if (ul_x > -1){
      if ((ul_x > 0) && (ul_y > 0)){
         for (int k=0; k <nHistBin; k++){
			 for (int kk = 0; kk < K; kk++){
				hist[kk*nHistBin + k] = integralIms[lr_y][lr_x][k] + integralIms[ul_y-1][ul_x-1][k] - integralIms[lr_y][ul_x-1][k] - integralIms[ul_y-1][lr_x][k];
				//if (hist[kk*nHistBin + k] != 0 && kk*nHistBin + k < 50){
				//					mexPrintf("%d,",hist[kk*nHistBin + k]);
				//}
			}
         }
      } else if (ul_x > 0) {
         for (int k=0; k <nHistBin; k++){
            for (int kk = 0; kk < K; kk++){
				hist[kk*nHistBin + k] = integralIms[lr_y][lr_x][k] - integralIms[lr_y][ul_x-1][k];
				//if (hist[kk*nHistBin + k] != 0 && kk*nHistBin + k < 50){
				//	mexPrintf("%d,",hist[kk*nHistBin + k]);
				//}
			}
         }
      } else if (ul_y > 0) {
         for (int k=0; k <nHistBin; k++){
            for (int kk = 0; kk < K; kk++){
				hist[kk*nHistBin + k] = integralIms[lr_y][lr_x][k] - integralIms[ul_y-1][lr_x][k];
				//if (hist[kk*nHistBin + k] != 0 && kk*nHistBin + k < 50){
				//					mexPrintf("%d,",hist[kk*nHistBin + k]);
				//}
			}
         }
      } else {
         for (int k=0; k <nHistBin; k++){
            for (int kk = 0; kk < K; kk++){
				hist[kk*nHistBin + k] = integralIms[lr_y][lr_x][k];
				//if (hist[kk*nHistBin + k] != 0 && kk*nHistBin + k < 50){
				//					mexPrintf("%d,",hist[kk*nHistBin + k]);
				//}
			}
         }
      }
   }
   //mexPrintf("\n");
   return hist;
}

int* Window::getHist(int ***integralIms, int nHistBin, int K, Res winRes){
   Window newWin(ul_x*winRes.x, ul_y*winRes.y, lr_x*winRes.x, lr_y*winRes.y);
   return newWin.getPyrHist(integralIms, nHistBin, K);
}


int Window::getMaxDim(){
   return max(lr_x - ul_x, lr_y - ul_y);
};

void Window::copy(Window *newWin){
   newWin->lr_x = lr_x;
   newWin->lr_y = lr_y;
   newWin->ul_x = ul_x;
   newWin->ul_y = ul_y;
}

void Window::split(Window *left, Window *right){

   if (lr_x - ul_x >= lr_y -  ul_y){ // split along horizontal dim
      int x1 = floor((double)(ul_x + lr_x)/2);
      int x2 = x1 + 1;
      copy(left);
      left->lr_x = x1;
      copy(right);
      right->ul_x = x2;
   } else {
      int y1 = floor((double)(ul_y + lr_y)/2);
      int y2 = y1+1;
      copy(left);
      left->lr_y = y1;
      copy(right);
      right->ul_y = y2;
   }
}

bool Window::operator ==(const Window& win){
   return ((ul_x == win.ul_x) && (ul_y == win.ul_y) &&
      (lr_x == win.lr_x) && (lr_y == win.lr_y));
};

string Window::str(){
   ostringstream rslt;
   rslt << "(" << ul_x << ", " << ul_y << ", " << lr_x << ", " << lr_y << ")";
   return rslt.str();
};


WindowPair::WindowPair(Window win1_, Window win2_){
   win1 = win1_;
   win2 = win2_;
}
WindowPair::WindowPair(){};


Window
WindowPair::getSmallestWin(){
   if ((win1.lr_x < win2.ul_x) && (win1.lr_y < win2.ul_y)){
      return Window(win1.lr_x, win1.lr_y, win2.ul_x, win2.ul_y);
   } else {
      return Window();
   }
}

Window
WindowPair::getLargestWin(){
   if ((win1.ul_x <= win2.lr_x) && (win1.ul_y <= win2.lr_y)){
      return Window(win1.ul_x, win1.ul_y, win2.lr_x, win2.lr_y);
   } else {
	   //mexPrintf("oh noes mex! considered [%d,%d,%d,%d], [%d,%d,%d,%d]\n",win1.ul_x+1,win1.ul_y+1,win1.lr_x+1,win1.lr_y+1,win2.ul_x+1,win2.ul_y+1,win2.lr_x+1,win2.lr_y+1);
      return Window();
   }
}




Window
WindowPair::getRandomWin(){
   int rUL_x = getRandNum(win1.ul_x, win1.lr_x);
   int rUL_y = getRandNum(win1.ul_y, win1.lr_y);
   int rLR_x = getRandNum(win2.ul_x, win2.lr_x);
   int rLR_y = getRandNum(win2.ul_y, win2.lr_y);
   if ((rUL_x <= rLR_x) && (rUL_y <= rLR_y)){
      return Window(rUL_x, rUL_y, rLR_x, rLR_y);
   } else {
      return getLargestWin();
   }
}

int
WindowPair::getRandNum(int minNum, int maxNum){
   srand((unsigned int)time(0));
   return (rand()% (maxNum + 1- minNum)) + minNum;
}
WindowPair
WindowPair::getSubWinPair(int x, int y, int xDev, int yDev){
   WindowPair rslt;
   Window w1 = Window(win1.ul_x, win1.ul_y, win2.ul_x, win2.ul_y).getSubWin(x, y, xDev, yDev);
   Window w2 = Window(win1.lr_x, win1.lr_y, win2.lr_x, win2.lr_y).getSubWin(x, y, xDev, yDev);

   rslt.win1 = Window(w1.ul_x, w1.ul_y, w2.ul_x, w2.ul_y);
   rslt.win2 = Window(w1.lr_x, w1.lr_y, w2.lr_x, w2.lr_y);
   return rslt;
}

Window
Window::getSubWin(int x, int y, int xDev, int yDev){
   Window rslt;
   rslt.ul_x = ul_x + (int)ceil(((double)lr_x - ul_x + 1)*(x-1)/xDev);
   rslt.lr_x = ul_x + (int)ceil(((double)lr_x - ul_x + 1)*x/xDev)  - 1;

   rslt.ul_y = ul_y + (int)ceil(((double)lr_y - ul_y + 1)*(y-1)/yDev);
   rslt.lr_y = ul_y + (int)ceil(((double)lr_y - ul_y + 1)*y/yDev) - 1;
   if ((rslt.ul_x > rslt.lr_x) || (rslt.ul_y > rslt.lr_y)){
      return Window();
   } else {
      return rslt;
   }
}


int
WindowPair::getMaxDim(){
   return max(win1.getMaxDim(), win2.getMaxDim());
};

void WindowPair::copy(WindowPair *newWinPair){
   newWinPair->win1 = win1;
   newWinPair->win2 = win2;
}

void WindowPair::split(WindowPair *left, WindowPair *right){
   if (win1.getMaxDim() > win2.getMaxDim()) { //split the first rectangle
      left->win2 = win2;
      right->win2 = win2;
      win1.split(&left->win1, &right->win1);
   } else {
      left->win1 = win1;
      right->win1 = win1;
      win2.split(&left->win2, &right->win2);
   }
}

string WindowPair::str(){
   return win1.str() + " " + win2.str();
}


string
SizeRange::str(){
   ostringstream rslt;
   rslt << "(" << hmin << ", " << hmax << ", " << wmin << ", " << wmax << ")";
   return rslt.str();
}


double
cmpEnergy2(int *hist1, double *weights, int nHistBin, int K){
   double energy = 0;
   for (int i=0; i < nHistBin*K; i++){
      energy += hist1[i]*weights[i];
   }
   return energy;
}



bool isImAssignGood(int **imAssign, int imH, int imW){
   bool isGood = true;
   for (int i=0; i < imH; i++){
      for (int j=0; j < imW; j++){
         if (imAssign[i][j] < 1) isGood = false;
      }
   }
   return isGood;
}

bool isWithinTolFactor(double bestUb, double lb, double tolFactor){
   if ((bestUb - lb) <= tolFactor*abs(bestUb)){
      return true;
   } else {
      return false;
   }
}

int **readImMatrix(char *fileName, int *imH_, int *imW_, int *nHistBin_){
   fstream myfile;
   myfile.open(fileName, fstream::in);
   int imH, imW, nHistBin;
   double tmp;
   myfile >> imH >> imW >> nHistBin;
   cout << imH << " " << imW << endl;
   int **imAssign = buildMatrix<int>(imH, imW);

   for (int i =0; i < imH; i++){
      for (int j = 0; j < imW; j++){
         myfile >> tmp;
         imAssign[i][j] = (int)floor(tmp);
         printf("%2d ", imAssign[i][j]);
      }
      cout << endl;
   };
   myfile.close();
   *imH_ = imH;
   *imW_ = imW;
   *nHistBin_ = nHistBin;
   return imAssign;
}
