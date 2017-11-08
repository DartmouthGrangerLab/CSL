#include <iostream>
#include <cmath>
#include <queue>
#include <string>
#include <sstream>
#include <fstream>
#include "m_utils.h"
#include "m_malloc.h"
#include "m_tests.h"
#include "m_TreeNode2b.h"

using namespace std;

void test2b_1(){
   int imH1 = 3;
   int imW1 = 4;
   int imH2 = 4;
   int imW2 = 3;
   int nHistBin = 3;
   int nTest = 9;
   double *weights = buildVector<double>(nHistBin);
   for (int i =0; i < nHistBin; i++) {weights[i] = 1;}
   double *Cs = buildVector<double>(nTest);
   double C;
   for (int i = 0; i < nTest; i++) {Cs[i] = 0.2;}

   int ***imAssign1 = buildArrayThree<int>(imH1, imW1, nTest);
   int ***imAssign2 = buildArrayThree<int>(imH2, imW2, nTest);
   WindowPair *expBBoxes = new WindowPair[nTest];
   
   int i = 0;
   imAssign1[0][0][i] = 1; imAssign1[1][0][i] = 1; imAssign1[2][0][i] = 1;
   imAssign1[0][1][i] = 2; imAssign1[1][1][i] = 2; imAssign1[2][1][i] = 2;
   imAssign1[0][2][i] = 3; imAssign1[1][2][i] = 3; imAssign1[2][2][i] = 3;
   imAssign1[0][3][i] = 1; imAssign1[1][3][i] = 1; imAssign1[2][3][i] = 1;

   imAssign2[0][0][i] = 1; imAssign2[1][0][i] = 2; imAssign2[2][0][i] = 3; imAssign2[3][0][i] = 1;
   imAssign2[0][1][i] = 1; imAssign2[1][1][i] = 2; imAssign2[2][1][i] = 3; imAssign2[3][1][i] = 1;
   imAssign2[0][2][i] = 1; imAssign2[1][2][i] = 2; imAssign2[2][2][i] = 3; imAssign2[3][2][i] = 1;

   expBBoxes[i] = WindowPair(Window(0,0,2,2), Window(0,0,2,2));

   i = 1;
   imAssign1[0][0][i] = 1; imAssign1[1][0][i] = 1; imAssign1[2][0][i] = 1;
   imAssign1[0][1][i] = 2; imAssign1[1][1][i] = 2; imAssign1[2][1][i] = 2;
   imAssign1[0][2][i] = 3; imAssign1[1][2][i] = 3; imAssign1[2][2][i] = 3;
   imAssign1[0][3][i] = 1; imAssign1[1][3][i] = 1; imAssign1[2][3][i] = 1;

   imAssign2[0][0][i] = 1; imAssign2[1][0][i] = 2; imAssign2[2][0][i] = 3; imAssign2[3][0][i] = 3;
   imAssign2[0][1][i] = 1; imAssign2[1][1][i] = 2; imAssign2[2][1][i] = 3; imAssign2[3][1][i] = 3;
   imAssign2[0][2][i] = 1; imAssign2[1][2][i] = 2; imAssign2[2][2][i] = 3; imAssign2[3][2][i] = 3;

   expBBoxes[i] = WindowPair(Window(0,0,2,2), Window(0,0,2,2));

   i = 2;
   imAssign1[0][0][i] = 1; imAssign1[1][0][i] = 1; imAssign1[2][0][i] = 1;
   imAssign1[0][1][i] = 2; imAssign1[1][1][i] = 2; imAssign1[2][1][i] = 2;
   imAssign1[0][2][i] = 3; imAssign1[1][2][i] = 3; imAssign1[2][2][i] = 3;
   imAssign1[0][3][i] = 1; imAssign1[1][3][i] = 1; imAssign1[2][3][i] = 1;

   imAssign2[0][0][i] = 1; imAssign2[1][0][i] = 2; imAssign2[2][0][i] = 3; imAssign2[3][0][i] = 3;
   imAssign2[0][1][i] = 2; imAssign2[1][1][i] = 2; imAssign2[2][1][i] = 3; imAssign2[3][1][i] = 3;
   imAssign2[0][2][i] = 3; imAssign2[1][2][i] = 2; imAssign2[2][2][i] = 3; imAssign2[3][2][i] = 3;

   expBBoxes[i] = WindowPair(Window(1,0,2,2), Window(0,1,2,2));

   i = 3;
   imAssign1[0][0][i] = 1; imAssign1[1][0][i] = 1; imAssign1[2][0][i] = 1;
   imAssign1[0][1][i] = 2; imAssign1[1][1][i] = 2; imAssign1[2][1][i] = 2;
   imAssign1[0][2][i] = 3; imAssign1[1][2][i] = 3; imAssign1[2][2][i] = 3;
   imAssign1[0][3][i] = 1; imAssign1[1][3][i] = 1; imAssign1[2][3][i] = 1;

   imAssign2[0][0][i] = 1; imAssign2[1][0][i] = 2; imAssign2[2][0][i] = 3; imAssign2[3][0][i] = 3;
   imAssign2[0][1][i] = 2; imAssign2[1][1][i] = 2; imAssign2[2][1][i] = 3; imAssign2[3][1][i] = 3;
   imAssign2[0][2][i] = 3; imAssign2[1][2][i] = 1; imAssign2[2][2][i] = 3; imAssign2[3][2][i] = 3;

   expBBoxes[i] = WindowPair(Window(0,0,2,2), Window(0,0,2,2));

   i = 4;
   imAssign1[0][0][i] = 3; imAssign1[1][0][i] = 3; imAssign1[2][0][i] = 3;
   imAssign1[0][1][i] = 3; imAssign1[1][1][i] = 3; imAssign1[2][1][i] = 1;
   imAssign1[0][2][i] = 3; imAssign1[1][2][i] = 2; imAssign1[2][2][i] = 2;
   imAssign1[0][3][i] = 3; imAssign1[1][3][i] = 1; imAssign1[2][3][i] = 2;

   imAssign2[0][0][i] = 3; imAssign2[1][0][i] = 1; imAssign2[2][0][i] = 1; imAssign2[3][0][i] = 2;
   imAssign2[0][1][i] = 3; imAssign2[1][1][i] = 2; imAssign2[2][1][i] = 3; imAssign2[3][1][i] = 2;
   imAssign2[0][2][i] = 3; imAssign2[1][2][i] = 2; imAssign2[2][2][i] = 2; imAssign2[3][2][i] = 2;

   expBBoxes[i] = WindowPair(Window(1,0,3,2), Window(0,0,2,2));

   i = 5;
   imAssign1[0][0][i] = 3; imAssign1[1][0][i] = 3; imAssign1[2][0][i] = 3;
   imAssign1[0][1][i] = 3; imAssign1[1][1][i] = 3; imAssign1[2][1][i] = 1;
   imAssign1[0][2][i] = 2; imAssign1[1][2][i] = 2; imAssign1[2][2][i] = 2;
   imAssign1[0][3][i] = 3; imAssign1[1][3][i] = 1; imAssign1[2][3][i] = 2;

   imAssign2[0][0][i] = 3; imAssign2[1][0][i] = 1; imAssign2[2][0][i] = 1; imAssign2[3][0][i] = 2;
   imAssign2[0][1][i] = 3; imAssign2[1][1][i] = 2; imAssign2[2][1][i] = 3; imAssign2[3][1][i] = 2;
   imAssign2[0][2][i] = 3; imAssign2[1][2][i] = 2; imAssign2[2][2][i] = 2; imAssign2[3][2][i] = 2;

   expBBoxes[i] = WindowPair(Window(1,1,3,2), Window(0,1,2,2));

   i = 6;
   imAssign1[0][0][i] = 2; imAssign1[1][0][i] = 2; imAssign1[2][0][i] = 2;
   imAssign1[0][1][i] = 1; imAssign1[1][1][i] = 1; imAssign1[2][1][i] = 1;
   imAssign1[0][2][i] = 1; imAssign1[1][2][i] = 1; imAssign1[2][2][i] = 1;
   imAssign1[0][3][i] = 1; imAssign1[1][3][i] = 1; imAssign1[2][3][i] = 2;

   imAssign2[0][0][i] = 1; imAssign2[1][0][i] = 1; imAssign2[2][0][i] = 1; imAssign2[3][0][i] = 2;
   imAssign2[0][1][i] = 1; imAssign2[1][1][i] = 2; imAssign2[2][1][i] = 1; imAssign2[3][1][i] = 2;
   imAssign2[0][2][i] = 1; imAssign2[1][2][i] = 1; imAssign2[2][2][i] = 1; imAssign2[3][2][i] = 2;

   expBBoxes[i] = WindowPair(Window(1,0,3,2), Window(0,0,2,2));

   i = 7; Cs[i] = 0.4;
   imAssign1[0][0][i] = 2; imAssign1[1][0][i] = 2; imAssign1[2][0][i] = 2;
   imAssign1[0][1][i] = 1; imAssign1[1][1][i] = 1; imAssign1[2][1][i] = 1;
   imAssign1[0][2][i] = 1; imAssign1[1][2][i] = 1; imAssign1[2][2][i] = 1;
   imAssign1[0][3][i] = 1; imAssign1[1][3][i] = 1; imAssign1[2][3][i] = 3;

   imAssign2[0][0][i] = 1; imAssign2[1][0][i] = 1; imAssign2[2][0][i] = 1; imAssign2[3][0][i] = 2;
   imAssign2[0][1][i] = 1; imAssign2[1][1][i] = 2; imAssign2[2][1][i] = 1; imAssign2[3][1][i] = 2;
   imAssign2[0][2][i] = 1; imAssign2[1][2][i] = 1; imAssign2[2][2][i] = 1; imAssign2[3][2][i] = 2;

   expBBoxes[i] = WindowPair(Window(1,0,3,2), Window(0,0,2,2));

   i = 8; Cs[i] = 0.2;
   imAssign1[0][0][i] = 2; imAssign1[1][0][i] = 2; imAssign1[2][0][i] = 2;
   imAssign1[0][1][i] = 1; imAssign1[1][1][i] = 1; imAssign1[2][1][i] = 1;
   imAssign1[0][2][i] = 1; imAssign1[1][2][i] = 1; imAssign1[2][2][i] = 1;
   imAssign1[0][3][i] = 1; imAssign1[1][3][i] = 1; imAssign1[2][3][i] = 3;

   imAssign2[0][0][i] = 1; imAssign2[1][0][i] = 1; imAssign2[2][0][i] = 1; imAssign2[3][0][i] = 2;
   imAssign2[0][1][i] = 1; imAssign2[1][1][i] = 2; imAssign2[2][1][i] = 1; imAssign2[3][1][i] = 2;
   imAssign2[0][2][i] = 1; imAssign2[1][2][i] = 1; imAssign2[2][2][i] = 1; imAssign2[3][2][i] = 2;

   expBBoxes[i] = WindowPair(Window(0,0,1,2), Window(0,1,1,3));

   int **im1 = buildMatrix<int>(imH1, imW1);
   int **im2 = buildMatrix<int>(imH2, imW2);

   
            
   for (int k= 0; k < nTest; k++){
      cout << "==============Testing 10." << k << endl;
      cout << "image 1: " << endl;
      C = Cs[k];
      for (int i = 0; i< imH1; i++){
         for (int j= 0; j < imW1; j++){
            im1[i][j] = imAssign1[i][j][k];
            printf("%2d ", im1[i][j]);
         }      
         cout << endl;
      }
      cout << endl << "image 2: " << endl;

      for (int i = 0; i< imH2; i++){
         for (int j= 0; j < imW2; j++){
            im2[i][j] = imAssign2[i][j][k];
            printf("%2d ", im2[i][j]);
         }      
         cout << endl;
      }

      int ***integralIms1 = cmpIntegralIms(im1, imH1, imW1, nHistBin);
      int ***integralIms2 = cmpIntegralIms(im2, imH2, imW2, nHistBin);
      WindowPair bestBBoxes = findBoxes2b(im1, imH1, imW1,
                                         im2, imH2, imW2, weights, nHistBin, C, 0, 0, Res(1,1), Res(1,1));
      int *hist1_best = bestBBoxes.win1.getHist(integralIms1, nHistBin);
      int *hist2_best = bestBBoxes.win2.getHist(integralIms2, nHistBin);
      double energy_best = cmpEnergy(hist1_best, hist2_best, weights, nHistBin, C);
      cout << "Best window " << bestBBoxes.win1.str() << " and " << bestBBoxes.win2.str() 
           << ", energy: " << energy_best << endl;      

      int *hist1_exp = expBBoxes[k].win1.getHist(integralIms1, nHistBin);
      int *hist2_exp = expBBoxes[k].win2.getHist(integralIms2, nHistBin);
      double energy_exp = cmpEnergy(hist1_exp, hist2_exp, weights, nHistBin, C);

      if (((bestBBoxes.win1.lr_x - bestBBoxes.win1.ul_x) != (bestBBoxes.win2.lr_x - bestBBoxes.win2.ul_x)) ||
         ((bestBBoxes.win1.lr_y - bestBBoxes.win1.ul_y) != (bestBBoxes.win2.lr_y - bestBBoxes.win2.ul_y))){
            cout << "FAILED: the size of two rectangels are not the same " << endl;
      } else {

         if (energy_best < energy_exp - EPS){
            cout << "WARNING: expected energy is bigger than returned energy" << endl;
         } else if (energy_best > energy_exp){
            cout << "FAILED, expected BBoxes: " << expBBoxes[k].win1.str() 
                 << " and " << expBBoxes[k].win2.str() << endl;
         } else {
            cout << "PASSED" << endl;
         }
      }
      destroyArrayThree<int>(integralIms1, imH1, imW1, nHistBin);
      destroyArrayThree<int>(integralIms2, imH2, imW2, nHistBin);
      destroyVector<int>(hist1_best, nHistBin);
      destroyVector<int>(hist2_best, nHistBin);
      destroyVector<int>(hist1_exp, nHistBin);
      destroyVector<int>(hist2_exp, nHistBin);      
      cout << endl; 
   }
   destroyVector<double>(weights, nHistBin);
   destroyVector<double>(Cs, nTest);
   destroyMatrix<int>(im1, imH1, imW1);
   destroyMatrix<int>(im2, imH2, imW2);
   destroyArrayThree<int>(imAssign1, imH1, imW1, nTest);
   destroyArrayThree<int>(imAssign2, imH2, imW2, nTest);
   delete [] expBBoxes;
}


void test2b_2(){
   int imH1, imW1, imH2, imW2, nHistBin;
   //char *im1File = "../test2b_pair1_im1.txt";
   //char *im2File = "../test2b_pair1_im2.txt";
   //char *im1File = "../test2b_pair2_im1.txt";
   //char *im2File = "../test2b_pair2_im2.txt";
   char *im1File = "../test2b_pair3_im1.txt";
   char *im2File = "../test2b_pair3_im2.txt";
      
   int **imAssign1 = readImMatrix(im1File, &imH1, &imW1, &nHistBin);  
   int **imAssign2 = readImMatrix(im2File, &imH2, &imW2, &nHistBin);
   int ***integralIms1 = cmpIntegralIms(imAssign1, imH1, imW1, nHistBin);
   int ***integralIms2 = cmpIntegralIms(imAssign2, imH2, imW2, nHistBin);
   double C = 0.2;

   double *weights = buildVector<double>(nHistBin);
   for (int i =0; i < nHistBin; i++) {weights[i] = 1;}

   WindowPair bestBBoxes = findBoxes2b(imAssign1, imH1, imW1,
                                       imAssign2, imH2, imW2, weights, nHistBin, 
                                       C, 0, 0, Res(2, 2), Res(2, 2));
   int *hist1_best = bestBBoxes.win1.getHist(integralIms1, nHistBin);
   int *hist2_best = bestBBoxes.win2.getHist(integralIms2, nHistBin);
   double energy_best = cmpEnergy(hist1_best, hist2_best, weights, nHistBin, C);

   cout << "Best window " << bestBBoxes.win1.str() << " and " << bestBBoxes.win2.str() 
        << ", energy: " << energy_best << endl;     

   destroyArrayThree<int>(integralIms1, imH1, imW1, nHistBin);
   destroyArrayThree<int>(integralIms2, imH2, imW2, nHistBin);
   destroyMatrix<int>(imAssign1, imH1, imW1);
   destroyMatrix<int>(imAssign2, imH2, imW2);
   destroyVector<int>(hist1_best, nHistBin);
   destroyVector<int>(hist2_best, nHistBin);
   destroyVector<double>(weights, nHistBin);
}