function [bestBox] = m_matFindBox1a (imAssign, targetHist, binWeights, nHistBin, K, C, tolFac, knownBest, Win_Prior_Mean, Win_Prior_Variance, FlexWin, PYR_LEVELS)

   [rows, cols, chans] = size(imAssign);

   %ASHOK
   %Gaussian Prior for windows
   Mu = Win_Prior_Mean;
   S = Win_Prior_Variance;

   %fprintf('rows: %d, cols: %d, histSize: %d, C: %g \n', rows, cols, nHistBin, C);

   bestBB = findBox1a(imAssign, rows, cols, chans, targetHist, binWeights, nHistBin, K, C, tolFac, knownBest, Mu, S, FlexWin, PYR_LEVELS);

   bestBox(1) = max(bestBB.ul_x, 1);
   bestBox(2) = max(bestBB.ul_y, 1);
   bestBox(3) = max(bestBB.lr_x, 1);
   bestBox(4) = max(bestBB.lr_y, 1);
   %if numel(bestBox(bestBox==1)) > 2
   %    fprintf('o noes m_matFindBox1a!\n');
   %end
end