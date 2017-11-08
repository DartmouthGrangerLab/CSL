#include <iostream>
#include <cmath>
#include <queue>
#include <string>
#include <sstream>
#include <fstream>
#include "m_utils.h"
#include "m_malloc.h"
#include "m_TreeNode1c.h"
#include "m_BranchBound.cpp"
#include "m_tests.h"
#include "m_TreeNode2a.h"

void test2a_1(){
   int imH1 = 40;
   int imW1 = 30;
   int nHistBin = 10;
   double *weights = buildVector<double>(nHistBin);
   for (int i =0; i < nHistBin; i++) {weights[i] = 1;}

   int** imAssign1 = buildMatrix<int>(imH1, imW1);
   for (int i = 0; i< imH1; i++){
      for (int j= 0; j < imW1; j++){
         imAssign1[i][j] = (j % (nHistBin-7)) + 8;         
      }      
   }

   imAssign1[30][20] = 1; imAssign1[31][20] = 1; imAssign1[32][20] = 1;
   imAssign1[30][21] = 2; imAssign1[31][21] = 2; imAssign1[32][21] = 2;
   imAssign1[30][22] = 3; imAssign1[31][22] = 3; imAssign1[32][22] = 3;
   imAssign1[30][23] = 1; imAssign1[31][23] = 1; imAssign1[32][23] = 1;

   cout << "Image 1" << endl;
   for (int i = 0; i< imH1; i++){
      for (int j= 0; j < imW1; j++){
         printf("%2d ", imAssign1[i][j]);
      }      
      cout << endl;
   }

   int imH2 = 45;
   int imW2 = 35;
   int** imAssign2 = buildMatrix<int>(imH2, imW2);
   cout << "Image 2" << endl;
   for (int i = 0; i< imH2; i++){
      for (int j= 0; j < imW2; j++){
         imAssign2[i][j] = (i % 5) + 4;         
      }      
   }

   imAssign2[30][20] = 1; imAssign2[31][20] = 1; imAssign2[32][20] = 1;
   imAssign2[30][21] = 2; imAssign2[31][21] = 2; imAssign2[32][21] = 2;
   imAssign2[30][22] = 3; imAssign2[31][22] = 3; imAssign2[32][22] = 3;
   imAssign2[30][23] = 1; imAssign2[31][23] = 1; imAssign2[32][23] = 1;
   for (int i = 0; i< imH2; i++){
      for (int j= 0; j < imW2; j++){
         printf("%2d ", imAssign2[i][j]);
      }      
      cout << endl;
   }

   int ***integralIms1 = cmpIntegralIms(imAssign1, imH1, imW1, nHistBin);
   int ***integralIms2 = cmpIntegralIms(imAssign2, imH2, imW2, nHistBin);
   double C = 0.2;

   WindowPair bestBBoxes = findBoxes2a(imAssign1, imH1, imW1,
                                      imAssign2, imH2, imW2, weights, nHistBin, C, 0, 100000);
   int *hist1_best = bestBBoxes.win1.getHist(integralIms1, nHistBin);
   int *hist2_best = bestBBoxes.win2.getHist(integralIms2, nHistBin);
   double energy_best = cmpEnergy(hist1_best, hist2_best, weights, nHistBin, C);

   cout << "Best window " << bestBBoxes.win1.str() << " and " << bestBBoxes.win2.str() 
        << ", energy: " << energy_best << endl;      
}

void test2a_2(){
   int imH1 = 3;
   int imW1 = 4;
   int imH2 = 4;
   int imW2 = 3;
   int nHistBin = 3;
   int nTest = 4;
   double *weights = buildVector<double>(nHistBin);
   for (int i =0; i < nHistBin; i++) {weights[i] = 1;}

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

   expBBoxes[i] = WindowPair(Window(0,0,3,2), Window(0,0,2,3));

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


   int **im1 = buildMatrix<int>(imH1, imW1);
   int **im2 = buildMatrix<int>(imH2, imW2);
   double C = 0.2;
            
   for (int k= 0; k < nTest; k++){
      cout << "==============Testing test2_2." << k << endl;
      cout << "image 1: " << endl;
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
      WindowPair bestBBoxes = findBoxes2a(im1, imH1, imW1,
                                         im2, imH2, imW2, weights, nHistBin, C, 0, 0);
      int *hist1_best = bestBBoxes.win1.getHist(integralIms1, nHistBin);
      int *hist2_best = bestBBoxes.win2.getHist(integralIms2, nHistBin);
      double energy_best = cmpEnergy(hist1_best, hist2_best, weights, nHistBin, C);
      cout << "Best window " << bestBBoxes.win1.str() << " and " << bestBBoxes.win2.str() 
           << ", energy: " << energy_best << endl;      

      int *hist1_exp = expBBoxes[k].win1.getHist(integralIms1, nHistBin);
      int *hist2_exp = expBBoxes[k].win2.getHist(integralIms2, nHistBin);
      double energy_exp = cmpEnergy(hist1_exp, hist2_exp, weights, nHistBin, C);

      if (energy_best < energy_exp){
         cout << "WARNING: expected energy is bigger than returned energy" << endl;
      } else if (energy_best > energy_exp){
         cout << "FAILED, expected BBoxes: " << expBBoxes[k].win1.str() 
              << " and " << expBBoxes[k].win2.str() << endl;
      } else {
         cout << "PASSED" << endl;
      }
      destroyArrayThree<int>(integralIms1, imH1, imW1, nHistBin);
      destroyArrayThree<int>(integralIms2, imH2, imW2, nHistBin);
      destroyVector<int>(hist1_best, nHistBin);
      destroyVector<int>(hist2_best, nHistBin);
      destroyVector<int>(hist1_exp, nHistBin);
      destroyVector<int>(hist2_exp, nHistBin);
      cout << endl; 
   }
}

void test2a_3(){
   int imH1, imW1, imH2, imW2, nHistBin;
   int **imAssign1 = readImMatrix("../test2b_pair3_im1.txt", &imH1, &imW1, &nHistBin);  
   int **imAssign2 = readImMatrix("../test2b_pair3_im2.txt", &imH2, &imW2, &nHistBin);
   int ***integralIms1 = cmpIntegralIms(imAssign1, imH1, imW1, nHistBin);
   int ***integralIms2 = cmpIntegralIms(imAssign2, imH2, imW2, nHistBin);
   double C = 0.7;

   double *weights = buildVector<double>(nHistBin);
   for (int i =0; i < nHistBin; i++) {weights[i] = 1;}

   WindowPair bestBBoxes = findBoxes2a(imAssign1, imH1, imW1,
                                      imAssign2, imH2, imW2, weights, nHistBin, C, 0, -10);
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
}
