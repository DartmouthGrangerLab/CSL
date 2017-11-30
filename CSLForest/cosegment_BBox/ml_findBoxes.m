function [bestBox1, bestBox2] = ml_findBoxes(im1Assign, im2Assign, binWeights, ...
    C, tolFac, knownBest, shldSeekSameSz, res, Win_Prior_Mean, Win_Prior_Variance, FlexWin)
%function bestBox = ml_findBoxes(imAssign1, imAssign2, binWeights, ...
%    C, tolFac, knownBest, shldSeekSameSz, res)
% Simultaneously find similar rectangles in 2 images. 
% The energy that this minimize is:
%   sum_i {binWeights(i)*[|hist1(i) - hist2(i)| - C*(hist1(i) + hist2(i))]}
% Inputs:
%   im1Assign: a im1H*im1W matrix for histogram bin assignments of pixels, 
%       entries must be integers from 1 to k, where k is number of
%       histogram bins
%   im2Assign: a im2H*im2W matrix for histogram bin assignments of pixels, 
%       entries must be integers from 1 to k, where k is number of
%       histogram bins
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
%   shldSeekSameSz: enforcing the common rectangles to be of same sizes?
%       turn this on will speed up the optimization enormously.
%   res: resolution of grid to search. The bigger res, the coarser the
%       search is and the faster the optimization terminate.
%       In the current implementation, if shldSeekSameSz = 0, res is always
%       one. In other words, res is only effective if shldSeekSameSz = 1;
% Output:
%   bestBox1, bestBox2: a 4*1 vector for the left, top, right, bottom of 
%       the rectangles in two images.
% By: Minh Hoai Nguyen (minhhoai@gmail.com)
% Date: 30 Aug 2008

nHistBin = max(max(im1Assign(:)), max(im2Assign(:)));
if ~exist('binWeights', 'var') || isempty(binWeights)
    binWeights = ones(nHistBin, 1);
end

if ~exist('C', 'var') || isempty(C)
    C = 0.2;
end

if ~exist('tolFac', 'var') || isempty(tolFac)
    tolFac = 0.2;
end;

if ~exist('knownBest', 'var') || isempty(knownBest)
    knownBest = 0;
end;

if ~exist('shldSeekSameSz', 'var') || isempty(shldSeekSameSz)
    shldSeekSameSz = 1;
end;

if ~exist('res', 'var') || isempty(res)
    res = 1;
end;

% check the inputs
if size(binWeights, 2) ~= 1
    error('ml_findBoxes.m: binWeights should be a column vector');
end;

if sum(im1Assign(:) <= 0) > 0
    error('ml_findBoxes.m: entries of im1Assign should be positive integers');
end

if sum(im2Assign(:) <= 0) > 0
    error('ml_findBoxes.m: entries of im2Assign should be positive integers');
end

if (C > 1 ) || ( C < 0)
    error('ml_findBox1a.m: C must be from 0 to 1');
end;

if (tolFac > 1) || (tolFac < 0)
    error('ml_findBox1a.m: tolFac must be from 0 to 1');
end;

[bestBox1, bestBox2] = m_mexFindBoxes(im1Assign, im2Assign, binWeights, ...
    C, tolFac, knownBest, shldSeekSameSz, res, Win_Prior_Mean, Win_Prior_Variance, FlexWin);

