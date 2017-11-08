#include <iostream>
#include <cmath>
#include <queue>
#include <string>
#include <sstream>
#include <fstream>
#include "m_utils.h"
#include "m_malloc.h"
#include "m_TreeNode1a.h"
#include "m_BranchBound.cpp"
#include "m_tests.h"

void test1a_1(){
   int imH = 3;
   int imW = 4;
   int** imAssign = buildMatrix<int>(imH, imW);
   for (int i = 0; i< imH; i++){
      for (int j= 0; j < imW-1; j++){
         imAssign[i][j] = j+1;
         cout << imAssign[i][j] << " ";
      }
      imAssign[i][imW-1] = 1;
      cout << imAssign[i][imW-1] << endl;
   }

   cout << endl << "Integral images " << endl;
   
   int nHistBin = 3;
   double *weights = buildVector<double>(nHistBin);
   weights[0] = 1;
   weights[1] = 1;
   weights[2] = 1;

   int*** integralIms = cmpIntegralIms(imAssign, imH, imW, nHistBin);
   
   for (int k=0; k < nHistBin; k++){
      for (int i=0; i < imH; i++){
         for (int j=0; j < imW; j++){
            printf("%d ", integralIms[i][j][k]);
         }
         printf("\n");
      }
      printf("\n\n");
   }

   double C = 0.2;
   
   int nTest = 13;
   int **targets = buildMatrix<int>(nTest, nHistBin);
   int **expects = buildMatrix<int>(nTest, 4);
   int i;
   i = 0; targets[i][0] = 3; targets[i][1] = 3; targets[i][2] = 0;
   expects[i][0] = 0; expects[i][1] = 0; expects[i][2] = 1; expects[i][3] = 2;
   i = 1; targets[i][0] = 6; targets[i][1] = 3; targets[i][2] = 3;
   expects[i][0] = 0; expects[i][1] = 0; expects[i][2] = 3; expects[i][3] = 2;
   i = 2; targets[i][0] = 0; targets[i][1] = 0; targets[i][2] = 0;
   expects[i][0] = -1; expects[i][1] = -1; expects[i][2] = -1; expects[i][3] = -1;
   i = 3; targets[i][0] = 0; targets[i][1] = 2; targets[i][2] = 0;
   expects[i][0] = 1; expects[i][1] = 0; expects[i][2] = 1; expects[i][3] = 1;

   i = 4; targets[i][0] = 0; targets[i][1] = 2; targets[i][2] = 2;
   expects[i][0] = 1; expects[i][1] = 0; expects[i][2] = 2; expects[i][3] = 1;

   i = 5; targets[i][0] = 2; targets[i][1] = 0; targets[i][2] = 2;
   expects[i][0] = 2; expects[i][1] = 0; expects[i][2] = 3; expects[i][3] = 1;
   i = 6; targets[i][0] = 0; targets[i][1] = 0; targets[i][2] = 1;
   expects[i][0] = 2; expects[i][1] = 0; expects[i][2] = 2; expects[i][3] = 0;
   
   i = 7; targets[i][0] = 2; targets[i][1] = 2; targets[i][2] = 2;
   expects[i][0] = 0; expects[i][1] = 0; expects[i][2] = 2; expects[i][3] = 1;

   i = 8; targets[i][0] = 3; targets[i][1] = 2; targets[i][2] = 2;
   expects[i][0] = 0; expects[i][1] = 0; expects[i][2] = 3; expects[i][3] = 1;

   i = 9; targets[i][0] = 4; targets[i][1] = 2; targets[i][2] = 2;
   expects[i][0] = 0; expects[i][1] = 0; expects[i][2] = 3; expects[i][3] = 1;

   i = 10; targets[i][0] = 5; targets[i][1] = 2; targets[i][2] = 2;
   expects[i][0] = 0; expects[i][1] = 0; expects[i][2] = 3; expects[i][3] = 1;
   
   i = 11; targets[i][0] = 5; targets[i][1] = 2; targets[i][2] = 3;
   expects[i][0] = 0; expects[i][1] = 0; expects[i][2] = 3; expects[i][3] = 2;

   i = 12; targets[i][0] = 5; targets[i][1] = 3; targets[i][2] = 3;
   expects[i][0] = 0; expects[i][1] = 0; expects[i][2] = 3; expects[i][3] = 2;

   for (i=0; i<nTest; i++){
      cout << "=========> Testing m_TreeNode_tests1a_1." << i << endl;
      Window bestWin = findBox1a(imAssign, imH, imW, targets[i], weights, nHistBin, C, 0, 1000000);
      int *hist_best = bestWin.getHist(integralIms, nHistBin);
      double energy_best = cmpEnergy(hist_best, targets[i], weights, nHistBin, C);

      cout << "Best window " << bestWin.str() << ", energy: " << energy_best << endl;
      
      Window expWin(expects[i][0], expects[i][1], expects[i][2], expects[i][3]);
      if (bestWin == expWin){
         cout << "PASSED" << endl;
      } else {
         int *hist_exp = expWin.getHist(integralIms, nHistBin);
         double energy_exp = cmpEnergy(hist_exp, targets[i], weights, nHistBin, C);
         
         if (energy_exp > energy_best){
            cout << "WARNING: expected energy is bigger the returned energy" << endl;
         } else if (energy_exp < energy_best){
            cout << "FAILED" << endl;
            printf("   Expected window ul_x: %d, ul_y: %d, lr_x: %d, lr_y: %d\n", 
               expects[i][0], expects[i][1], expects[i][2], expects[i][3]);
         } else {
            cout << "PASSED" << endl;
         }
         destroyVector<int>(hist_exp, nHistBin);
      }
      cout << endl;
      destroyVector<int>(hist_best, nHistBin);
   }
   destroyMatrix<int>(targets, nTest, nHistBin);
   destroyMatrix<int>(expects, nTest, nHistBin);
   destroyArrayThree<int>(integralIms, imH, imW, nHistBin);
   destroyMatrix<int>(imAssign, imH, imW);
   destroyVector<double>(weights, nHistBin);
}


void test1a_2(){
   int imH = 30;
   int imW = 40;
   int nHistBin = 3;
   int** imAssign = buildMatrix<int>(imH, imW);
   for (int i = 0; i< imH; i++){
      for (int j= 0; j < imW-1; j++){
         imAssign[i][j] = (j % nHistBin) + 1;
         cout << imAssign[i][j] << " ";
      }
      imAssign[i][imW-1] = 1;
      cout << imAssign[i][imW-1] << endl;
   }

   int*** integralIms = cmpIntegralIms(imAssign, imH, imW, nHistBin);
   double *weights = buildVector<double>(nHistBin);
   weights[0] = 1;
   weights[1] = 1;
   weights[2] = 1;

   double C = 0.2;
   
   int nTest = 13;
   int **targets = buildMatrix<int>(nTest, nHistBin);
   int **expects = buildMatrix<int>(nTest, 4);
   int i;
   i = 0; targets[i][0] = 3; targets[i][1] = 3; targets[i][2] = 0;
   expects[i][0] = 0; expects[i][1] = 0; expects[i][2] = 1; expects[i][3] = 2;
   i = 1; targets[i][0] = 6; targets[i][1] = 3; targets[i][2] = 3;
   expects[i][0] = 0; expects[i][1] = 0; expects[i][2] = 3; expects[i][3] = 2;
   i = 2; targets[i][0] = 0; targets[i][1] = 0; targets[i][2] = 0;
   expects[i][0] = -1; expects[i][1] = -1; expects[i][2] = -1; expects[i][3] = -1;
   i = 3; targets[i][0] = 0; targets[i][1] = 2; targets[i][2] = 0;
   expects[i][0] = 1; expects[i][1] = 0; expects[i][2] = 1; expects[i][3] = 1;

   i = 4; targets[i][0] = 0; targets[i][1] = 2; targets[i][2] = 2;
   expects[i][0] = 1; expects[i][1] = 0; expects[i][2] = 2; expects[i][3] = 1;

   i = 5; targets[i][0] = 2; targets[i][1] = 0; targets[i][2] = 2;
   expects[i][0] = 2; expects[i][1] = 0; expects[i][2] = 3; expects[i][3] = 1;
   i = 6; targets[i][0] = 0; targets[i][1] = 0; targets[i][2] = 1;
   expects[i][0] = 2; expects[i][1] = 0; expects[i][2] = 2; expects[i][3] = 0;
   
   i = 7; targets[i][0] = 2; targets[i][1] = 2; targets[i][2] = 2;
   expects[i][0] = 0; expects[i][1] = 0; expects[i][2] = 2; expects[i][3] = 1;

   i = 8; targets[i][0] = 3; targets[i][1] = 2; targets[i][2] = 2;
   expects[i][0] = 0; expects[i][1] = 0; expects[i][2] = 6; expects[i][3] = 0;

   i = 9; targets[i][0] = 4; targets[i][1] = 2; targets[i][2] = 2;
   expects[i][0] = 0; expects[i][1] = 0; expects[i][2] = 3; expects[i][3] = 1;

   i = 10; targets[i][0] = 5; targets[i][1] = 2; targets[i][2] = 2;
   expects[i][0] = 0; expects[i][1] = 0; expects[i][2] = 3; expects[i][3] = 1;
   
   i = 11; targets[i][0] = 5; targets[i][1] = 2; targets[i][2] = 3;
   expects[i][0] = 0; expects[i][1] = 0; expects[i][2] = 3; expects[i][3] = 2;

   i = 12; targets[i][0] = 5; targets[i][1] = 3; targets[i][2] = 3;
   expects[i][0] = 0; expects[i][1] = 0; expects[i][2] = 3; expects[i][3] = 2;

   for (i=0; i<nTest; i++){
      cout << "=========> Testing m_TreeNode_tests1a_2." << i << endl;
      Window bestWin = findBox1a(imAssign, imH, imW, targets[i], weights, nHistBin, C,0, 100000000);
      int *hist_best = bestWin.getHist(integralIms, nHistBin);
      double energy_best = cmpEnergy(hist_best, targets[i], weights, nHistBin, C);

      cout << "Best window " << bestWin.str() << ", energy: " << energy_best << endl;
      
      Window expWin(expects[i][0], expects[i][1], expects[i][2], expects[i][3]);
      if (bestWin == expWin){
         cout << "PASSED" << endl;
      } else {
         int *hist_exp = expWin.getHist(integralIms, nHistBin);
         double energy_exp = cmpEnergy(hist_exp, targets[i], weights, nHistBin, C);
         
         if (energy_exp > energy_best){
            cout << "WARNING: expected energy is bigger the returned energy" << endl;
         } else if (energy_exp < energy_best){
            cout << "FAILED" << endl;
            printf("   Expected window ul_x: %d, ul_y: %d, lr_x: %d, lr_y: %d\n", 
               expects[i][0], expects[i][1], expects[i][2], expects[i][3]);
         } else {
            cout << "PASSED" << endl;
         }
         destroyVector<int>(hist_exp, nHistBin);
      }
      cout << endl;
      destroyVector<int>(hist_best, nHistBin);
   }
   destroyMatrix<int>(targets, nTest, nHistBin);
   destroyMatrix<int>(expects, nTest, nHistBin);
   destroyArrayThree<int>(integralIms, imH, imW, nHistBin);
   destroyMatrix<int>(imAssign, imH, imW);
   destroyVector<double>(weights, nHistBin);
}

void test1a_3(){
   int imH = 40;
   int imW = 30;
   int nHistBin = 10;
   int** imAssign = buildMatrix<int>(imH, imW);
   for (int i = 0; i< imH; i++){
      for (int j= 0; j < imW; j++){
         imAssign[i][j] = (j % (nHistBin-3)) + 4;         
      }      
   }

   imAssign[30][20] = 1; imAssign[31][20] = 1; imAssign[32][20] = 1;
   imAssign[30][21] = 2; imAssign[31][21] = 2; imAssign[32][21] = 2;
   imAssign[30][22] = 3; imAssign[31][22] = 3; imAssign[32][22] = 3;
   imAssign[30][23] = 1; imAssign[31][23] = 1; imAssign[32][23] = 1;
   for (int i = 0; i< imH; i++){
      for (int j= 0; j < imW; j++){
         //printf("%2d ", imAssign[i][j]);
      }      
      cout << endl;
   }

   double *weights = buildVector<double>(nHistBin);
   for (int i =0; i < nHistBin; i++) {weights[i] = 1;}

   int*** integralIms = cmpIntegralIms(imAssign, imH, imW, nHistBin);

   double C = 0.2;
   
   int nTest = 13;
   int **targets = buildMatrix<int>(nTest, nHistBin);
   int **expects = buildMatrix<int>(nTest, 4);
   int i;
   i = 0; targets[i][0] = 3; targets[i][1] = 3; targets[i][2] = 0;
   expects[i][0] = 20; expects[i][1] = 30; expects[i][2] = 21; expects[i][3] = 32;
   i = 1; targets[i][0] = 6; targets[i][1] = 3; targets[i][2] = 3;
   expects[i][0] = 20; expects[i][1] = 30; expects[i][2] = 23; expects[i][3] = 32;
   i = 2; targets[i][0] = 0; targets[i][1] = 0; targets[i][2] = 0;
   expects[i][0] = -1; expects[i][1] = -1; expects[i][2] = -1; expects[i][3] = -1;
   i = 3; targets[i][0] = 0; targets[i][1] = 2; targets[i][2] = 0;
   expects[i][0] = 21; expects[i][1] = 30; expects[i][2] = 21; expects[i][3] = 31;
   i = 4; targets[i][0] = 0; targets[i][1] = 2; targets[i][2] = 2;
   expects[i][0] = 21; expects[i][1] = 30; expects[i][2] = 22; expects[i][3] = 31;
   i = 5; targets[i][0] = 2; targets[i][1] = 0; targets[i][2] = 2;
   expects[i][0] = 22; expects[i][1] = 30; expects[i][2] = 23; expects[i][3] = 31;
   i = 6; targets[i][0] = 0; targets[i][1] = 0; targets[i][2] = 1;
   expects[i][0] = 22; expects[i][1] = 30; expects[i][2] = 22; expects[i][3] = 30;   
   i = 7; targets[i][0] = 2; targets[i][1] = 2; targets[i][2] = 2;
   expects[i][0] = 20; expects[i][1] = 30; expects[i][2] = 22; expects[i][3] = 31;
   i = 8; targets[i][0] = 3; targets[i][1] = 2; targets[i][2] = 2;
   expects[i][0] = 20; expects[i][1] = 30; expects[i][2] = 23; expects[i][3] = 31;
   i = 9; targets[i][0] = 4; targets[i][1] = 2; targets[i][2] = 2;
   expects[i][0] = 20; expects[i][1] = 30; expects[i][2] = 23; expects[i][3] = 31;
   i = 10; targets[i][0] = 5; targets[i][1] = 2; targets[i][2] = 2;
   expects[i][0] = 20; expects[i][1] = 30; expects[i][2] = 23; expects[i][3] = 31;   
   i = 11; targets[i][0] = 5; targets[i][1] = 2; targets[i][2] = 3;
   expects[i][0] = 20; expects[i][1] = 30; expects[i][2] = 23; expects[i][3] = 32;
   i = 12; targets[i][0] = 5; targets[i][1] = 3; targets[i][2] = 3;
   expects[i][0] = 20; expects[i][1] = 30; expects[i][2] = 23; expects[i][3] = 32;


   for (i=0; i<nTest; i++){
      cout << "=========> Testing test1a_3." << i << endl;
      Window bestWin = findBox1a(imAssign, imH, imW, targets[i], weights, nHistBin, C, 0, 10000000);
      int *hist_best = bestWin.getHist(integralIms, nHistBin);
      double energy_best = cmpEnergy(hist_best, targets[i], weights, nHistBin, C);

      cout << "Best window " << bestWin.str() << ", energy: " << energy_best << endl;
      
      Window expWin(expects[i][0], expects[i][1], expects[i][2], expects[i][3]);
      if (bestWin == expWin){
         cout << "PASSED" << endl;
      } else {
         int *hist_exp = expWin.getHist(integralIms, nHistBin);
         double energy_exp = cmpEnergy(hist_exp, targets[i], weights, nHistBin, C);
         
         if (energy_exp > energy_best){
            cout << "WARNING: expected energy is bigger the returned energy" << endl;
         } else if (energy_exp < energy_best){
            cout << "FAILED" << endl;
            printf("   Expected window ul_x: %d, ul_y: %d, lr_x: %d, lr_y: %d\n", 
               expects[i][0], expects[i][1], expects[i][2], expects[i][3]);
         } else {
            cout << "PASSED" << endl;
         }
         destroyVector<int>(hist_exp, nHistBin);
      }
      cout << endl;
      destroyVector<int>(hist_best, nHistBin);
   }
   destroyMatrix<int>(targets, nTest, nHistBin);
   destroyMatrix<int>(expects, nTest, nHistBin);
   destroyArrayThree<int>(integralIms, imH, imW, nHistBin);
   destroyMatrix<int>(imAssign, imH, imW);
   destroyVector<double>(weights, nHistBin);
}

void test1a_4(){
   char *fileName = "../test1a_4_data.txt";
   fstream myfile;
   myfile.open(fileName, fstream::in);

   double tmp;   
    
   cout << "==========Testing test1a_4"<< endl;
   int imH, imW, nHistBin;
   myfile >> imH >> imW >> nHistBin;

   //reading matrix
   int **imAssign = buildMatrix<int>(imH, imW);
   for (int i =0; i < imH; i++){
      for (int j = 0; j < imW; j++){
         myfile >> tmp;
         imAssign[i][j] = (int) tmp;
         //printf("%2d ", imAssign[i][j]);
      }
      //cout << endl;
   };

   double C;
   myfile >> C;

   //reading bin weights
   cout << "Bin weights" << endl;
   double *binWeights = buildVector<double>(nHistBin);      
   for (int i= 0; i < nHistBin; i++){
      myfile >> binWeights[i];
      cout << binWeights[i] << " ";
   }
   cout << endl;

   cout << "target histogram" << endl;
   int *targetHist = buildVector<int>(nHistBin);
   for (int i = 0; i < nHistBin; i++){
      myfile >> tmp;
      targetHist[i] = (int) tmp;      
      cout << targetHist[i] << " ";
   }
   cout << endl;

   int*** integralIms = cmpIntegralIms(imAssign, imH, imW, nHistBin);   
   
   cout << "imH: " << imH << ", imW: " << imW << ", nHistBin: " << nHistBin  << ", C: " << C << endl;

   Window bestWin = findBox1a(imAssign, imH, imW, targetHist, binWeights, nHistBin, C, 0, 1000000);
   int *hist_best = bestWin.getHist(integralIms, nHistBin);
   double energy_best = cmpEnergy(hist_best, targetHist, binWeights, nHistBin, C);

   cout << "Best window " << bestWin.str() << ", energy: " << energy_best << endl;   
   destroyArrayThree<int>(integralIms, imH, imW, nHistBin);
   destroyMatrix<int>(imAssign, imH, imW);
   destroyVector<double>(binWeights, nHistBin);
   destroyVector<int>(targetHist, nHistBin);
   destroyVector<int>(hist_best, nHistBin);
   myfile.close();
};