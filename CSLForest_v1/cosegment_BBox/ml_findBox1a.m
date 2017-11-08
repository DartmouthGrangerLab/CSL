function bestBox = ml_findBox1a(imAssign, targetHist, binWeights, nHistBin, K, ...
    C, tolFac, PYR_LEVELS, knownBest, Win_Prior_Mean, Win_Prior_Variance, FlexWin)
    % function bestBox = ml_findBox1a(imAssign, targetHist, binWeights, ...
    %    C, tolFac, knownBest)
    % Find a rectangle with the histogram that best matches the target hisgoram
    % The energy that this minimize is:
    %   sum_i {binWeights(i)*[|hist(i) -targetHist(i)| -C*(hist(i) + targetHist(i)]}
    % Inputs:
    %   imAssign: a imH*imW matrix for histogram bin assignments of pixels, 
    %       entries must be integers from 1 to k, where k is number of
    %       histogram bins
    %   targetHist: a k*1 column vector for the target histogram
    %   binWeights: a k*1 vector of non-negative weights for histogram bins. 
    %   C: A number from 0 to 1, tradeoff between perfect histogram matching and
    %       the size of the sub-window. 
    %   tolFac: for stopping early. tolFac is from 0 to 1. 
    %       tolFactor = 0: stop when global optimum is reach
    %       tolFac > 0: stop when the difference between the global optimum
    %           and the best known is < tolFac of the best known value.
    %   knownBest: find the subwindow with the energy smaller than this value
    %       if no such subwindow exists, the algorithm returns an arbitary box.
    %       The default value is infinity.
    % Output:
    %   bestBox: a 4*1 vector for the left, top, right, bottom of the rectangle
    % By: Minh Hoai Nguyen (minhhoai@gmail.com)
    % Date: 29 Aug 2008

    if ~exist('binWeights', 'var') || isempty(binWeights)
        binWeights = ones(size(targetHist));
    end

    if ~exist('C', 'var') || isempty(C)
        C = 0.2;
    end

    if ~exist('tolFac', 'var') || isempty(tolFac)
        tolFac = 0;
    end;

    if ~exist('knownBest', 'var') || isempty(knownBest)
        knownBest = inf;
    end;

    % check the inputs
    if size(binWeights, 2) ~= 1
        error('ml_findBox1a.m: binWeights should be a column vector');
    end;

    CellCount  = 0;
    for i=0:PYR_LEVELS-1
        Dims = 2^i;
        CellCount = CellCount + Dims^2;
    end	
    if size(binWeights, 1) ~= CellCount*nHistBin*K
        error('ml_findBox1a.m: binWeights size is unexpected. Expected: %d, actual:%d\n', CellCount*nHistBin*K, size(binWeights, 1));
    end;

    if sum(imAssign(:) <= 0) > 0
        error('ml_findBox1a.m: entries of imAssign should be positive integers');
    end

    if sum(imAssign(:) > nHistBin) > 0
        error('ml_findBox1a.m: entries of imAssign must be smaller than the length of binWeights');
    end

    if (size(targetHist,1) ~= size(binWeights,1)) || ...
       (size(targetHist,2) ~= size(binWeights,2)) 
        error('ml_findBox1a.m: targetHist and binWeights must have the same size');
    end

    if (C > 1 ) || ( C < 0)
        error('ml_findBox1a.m: C must be from 0 to 1');
    end;

    if (tolFac > 1) || (tolFac < 0)
        error('ml_findBox1a.m: tolFac must be from 0 to 1');
    end;

    %mex version - only works on single-channel data frontends
    bestBox = m_mexFindBox1a(squeeze(imAssign(:,:,1)), targetHist, binWeights, nHistBin, K, C, tolFac, knownBest, Win_Prior_Mean, Win_Prior_Variance, FlexWin);
    %newer matlab version
%     if size(imAssign,1)==15 && size(imAssign,2)==17
%         asdf=1;
%     end
    %bestBox = m_matFindBox1a(imAssign, targetHist, binWeights, nHistBin, K, C, tolFac, knownBest, Win_Prior_Mean, Win_Prior_Variance, FlexWin, PYR_LEVELS);
    %fprintf('[%d,%d,%d,%d]vs[%d,%d,%d,%d]\n',bestBox(1),bestBox(2),bestBox(3),bestBox(4),bestBox2(1),bestBox2(2),bestBox2(3),bestBox2(4));
end
