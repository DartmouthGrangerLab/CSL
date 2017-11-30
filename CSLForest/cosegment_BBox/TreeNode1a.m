classdef TreeNode1a
    properties
        lb;
        ub;
        winPair;
    end
    
    methods
        function [obj] = TreeNode1a(winPair_)
            obj.winPair = winPair_;
        end

        function [left, right] = split (obj) %returns WindowPairs
            [left, right] = obj.winPair.split();
        end

        function [obj] = cmpBnds (obj, integralIms, hist_target, binWeights, PYR_LEVELS, C, K, nHistBin)
            global FG_Prior_Mu;
            global FG_Prior_S;
            global ImgDimX;
            global ImgDimY;
            global isWinFlexible;
            %toc
            %tic;
            smallestWin = obj.winPair.getSmallestWin();
            %toc
            %tic;
            %2X PROBLEM:::0.001550
            hist1_min = smallestWin.getPyrHist(integralIms, nHistBin, K, PYR_LEVELS);
            hist1_min = floor(hist1_min); %mex code used ints
            %toc
            %tic;
            largestWin = obj.winPair.getLargestWin();
            %toc
            %tic;
            %2X PROBLEM:::0.001550
            hist1_max = largestWin.getPyrHist(integralIms, nHistBin, K, PYR_LEVELS);
            hist1_max = floor(hist1_max); %mex code used ints
            %toc
            %tic;
            %PROBLEM:::0.000915
            obj.lb = getLowerBnd1(hist1_min, hist1_max, hist_target, binWeights);
            %toc
            %tic;
            bestwin = GetBestWin(smallestWin, largestWin, FG_Prior_Mu, FG_Prior_S, ImgDimX, ImgDimY, isWinFlexible);
            pr1 = CalcLogGauss(bestwin, FG_Prior_Mu, FG_Prior_S, isWinFlexible);
            %toc
            %tic;
            obj.lb = obj.lb - pr1;

            obj.ub = cmpEnergy(hist1_max, hist_target, binWeights, nHistBin, K, C);
            %toc
            %tic;
            x = [];
            x(1) = (largestWin.lr_x - largestWin.ul_x)/ImgDimX;
            x(2) = (largestWin.lr_y - largestWin.ul_y)/ImgDimY;
            pr2 = CalcLogGauss(x, FG_Prior_Mu, FG_Prior_S, isWinFlexible);
            obj.ub = obj.ub - pr2;
            %toc
            %w1 = obj.winPair.win1.AsArray();
            %w2 = obj.winPair.win2.AsArray();
            %fprintf('processing [%d,%d,%d,%d], [%d,%d,%d,%d], %.2f, %.2f, %.2f, %.2f\n',w1(1),w1(2),w1(3),w1(4),w2(1),w2(2),w2(3),w2(4),obj.lb,obj.ub,obj.lb + pr1,obj.ub + pr2);
            %fprintf('---\n');
        end
    end
end

function [x] = GetBestWin (smallestWin, largestWin, Prior_Win_Mu, Prior_Win_S, dimX, dimY, FlexWin)
	x = [];
	smallDimX = (smallestWin.lr_x - smallestWin.ul_x)/dimX;
	smallDimY = (smallestWin.lr_y - smallestWin.ul_y)/dimY;
	largeDimX = (largestWin.lr_x - largestWin.ul_x)/dimX;
	largeDimY = (largestWin.lr_y - largestWin.ul_y)/dimY;

    if ~FlexWin
        % First X dim
        if Prior_Win_Mu(1) >= largeDimX
            x(1) = largeDimX;
        elseif Prior_Win_Mu(1) <= smallDimX
            x(1) = smallDimX;
        elseif (Prior_Win_Mu(1) > smallDimX && Prior_Win_Mu(1) < largeDimX)
            x(1) = Prior_Win_Mu(1);
        end

        % now Y dim
        if Prior_Win_Mu(2) >= largeDimY
            x(2) = largeDimY;
        elseif Prior_Win_Mu(2) <= smallDimY
            x(2) = smallDimY;
        elseif Prior_Win_Mu(2) > smallDimY && Prior_Win_Mu(2) < largeDimY
            x(2) = Prior_Win_Mu(2);
        end
    else
        if Prior_Win_Mu(1)*Prior_Win_Mu(2) >= largeDimX*largeDimY
            x(1) = largeDimX;
            x(2) = largeDimY;
        elseif Prior_Win_Mu(1)*Prior_Win_Mu(2) <= smallDimX*smallDimY
            x(1) = smallDimX;
            x(2) = smallDimY;
        elseif Prior_Win_Mu(1)*Prior_Win_Mu(2) > smallDimX*smallDimY && Prior_Win_Mu(1)*Prior_Win_Mu(2) < largeDimX*largeDimY
            x(1) = Prior_Win_Mu(1);
            x(2) = Prior_Win_Mu(2);
        end
    end
end

function [result] = CalcLogGauss (x, mu, S, FlexWin)
    if ~FlexWin
        M = numel(x);
        Denom = -0.5*M*log(2*pi);
        Sum = 0;
        for i = 1:M
            Sum = Sum + log(S(i));
        end
        Denom = Denom - 0.5 * Sum;

        Numer = sum(((x - mu).^2) ./ S);
    else
        M = 1;
        Denom = -0.5*M*log(2*pi);
        Sum = 0;
        for i = 1:M
            Sum = Sum + log(S(i));
        end
        Denom = Denom - 0.5 * Sum;

        Numer = 0;
        for i = 1:M
            Numer = Numer + ((x(i)*x(i+1)) - (mu(i)*mu(i+1)))^2 / S(i);
        end
    end
    Numer = Numer * -0.5;
    result = Numer + Denom;
end

% function [energy] = cmpEnergy (hist1, hist2, weights, nHistBin, K, C)
% 	%PyrCells = GetPyrCellCount();
% 	%energy = 0;
%     if K == 1
%         temp = weights .* (abs(hist1 - hist2) - (hist1 + hist2)*C);
%     else
%         temp = weights .* (hist1 - hist2).^2;
%     end
%     energy = sum(temp);
%         %for k = 1:PyrCells*nHistBin*K
% % 		if K == 1
% % 			energy = energy + weights(k) * (abs(hist1(k) - hist2(k)) - C*(hist1(k) + hist2(k)));
% % 		else
% % 			energy = energy + weights(k) * (hist1(k) - hist2(k))*(hist1(k) - hist2(k));
% %         end
%     %end
% end

function [energy] = cmpEnergy (hist1, hist2, weights, nHistBin, K, C)
	%PyrCells = GetPyrCellCount();
    %PyrCells = 1; %TEMP
    if K == 1
        answer = weights .* (abs(hist1 - hist2) - (hist1 + hist2)*C);
    else
        answer = weights .* (hist1 - hist2).^2;
    end
    energy = sum(answer);
end

% function [Count] = GetPyrCellCount ()
%     global PYR_LEVELS;
% 	Count = 0;
% 	for i = 0:PYR_LEVELS-1
% 		Dims = 2^i;
% 		Count = Count + Dims*Dims;
%     end
% end

function [lb] = getLowerBnd1 (hist1_min, hist1_max, hist_target, weights)
    temp = zeros(numel(weights),1);
    for k = 1:numel(weights)
        if hist_target(k) < hist1_min(k)
            temp(k) = hist1_min(k);
        elseif hist_target(k) > hist1_max(k)
            temp(k) = hist1_max(k);
        else
            temp(k) = hist_target(k);
        end
    end
    temp = ((temp-hist_target).^2).*weights;
    lb = sum(temp);
end

% function [lb] = getLowerBnd1 (hist1_min, hist1_max, hist_target, weights, nHistBin, K, C)
%     lb = 0;
%     %PyrCells = GetPyrCellCount();
%     for k = 1:numel(weights)
%         lb = lb + weights(k)*getLowerBnd1_helper(hist1_min(k), hist1_max(k), hist_target(k), C);
%     end
% end
% 
% function [lb] = getLowerBnd1_helper (h1_min, h1_max, h_target, C)
%     if h_target < h1_min
%     	h1 = h1_min;
%     elseif h_target > h1_max
%     	h1 = h1_max;
%     else
%     	h1 = h_target;
%     end
%     %lb = abs(h1 - h_target) - C*(h1 + h_target);
%     lb = (h1 - h_target)^2;
% end
