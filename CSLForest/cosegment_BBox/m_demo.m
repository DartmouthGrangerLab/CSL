function m_demo()
    %demo_findBox1a();
    %demo_findBox1b();
    %demo_findBox1c();
    %demo_findBox1d();
    demo_findBoxes();

function demo_findBox1a()
    % Get the target histogram from image 1.
    load('../data/sift1.mat', 'imAssign', 'nClust');
    imAssign1 = imAssign(:,:,1);
    nHistBin = nClust(1);
    mask1 = imread('../data/mask1.bmp');    
    targetHist = m_cmpRegHist_multi(imAssign1, nHistBin, mask1);
    
    % Find the best box in second image
    load('../data/sift2.mat', 'imAssign', 'nClust');
    imAssign2 = imAssign(:,:,1);
    C = 0.2;
    tolFac = 0;
    tic;
    bestBox = ml_findBox1a(imAssign2, targetHist, [], C, tolFac);
    toc;
    % display
    im1 = imread('../data/im1.jpg');
    im2 = imread('../data/im2.jpg');
    figure; nR = 2; nC = 2;
    subplot(nR, nC, 1); imshow(im1); hold on;
    drawBoundary(mask1, 'red', 2);
    title('Target');
    subplot(nR, nC, 2); imshow(im2); hold on;
    drawRect(bestBox, 'red', 2);
    title('Best matched');
    subplot(nR, nC, 3); imagesc(imAssign1); hold on; axis image;
    drawBoundary(mask1, 'black', 2);
    title('Target');
    subplot(nR, nC, 4); imagesc(imAssign2); hold on; axis image;
    drawRect(bestBox, 'black', 2);
    title('Best matched');    
    
function demo_findBox1b()
    % Find the largest enclosing box of the mask of image 1.
    mask = imread('../data/mask1.bmp'); 
    imAssign = mask + 1;
    binWeights = [10000; -1];
    
    tic;
    bestBox = ml_findBox1b(imAssign, binWeights);
    toc;   
    
    % display
    im1 = imread('../data/im1.jpg');
    figure; nR = 2; nC = 1;
    subplot(nR, nC, 1); imshow(im1); hold on;
    drawBoundary(mask, 'red', 2);
    title('Mask');
    subplot(nR, nC, 2); imshow(im1); hold on;
    drawBoundary(mask, 'red', 2);
    drawRect(bestBox, 'green', 2);
    title('Largest Enclosing box');
        
function demo_findBox1c()
    % Get the target histograms from image 1.
    load('../data/sift1.mat', 'imAssign', 'nClust');
    imAssign1 = imAssign(:,:,1);
    nHistBin = nClust(1);
    mask1 = imread('../data/mask1.bmp');    
    
    % Get the bounding box of the mask
    BBox = regionprops(double(mask1), 'BoundingBox');
    BBox = BBox.BoundingBox;
    xStart = ceil(BBox(1));
    yStart = ceil(BBox(2));
    xEnd = floor(BBox(1) + BBox(3));
    yEnd = floor(BBox(2) + BBox(4));
    BBox = [xStart yStart xEnd yEnd];
    
    nBranch = 4;
    levelWeights = [0.5; 1];
    nLevel = length(levelWeights);
    targetHists = m_cmpPyramidHists(imAssign1, nHistBin, BBox, nBranch, nLevel-1);

    
    % Find the best box in second image
    load('../data/sift2.mat', 'imAssign', 'nClust');
    imAssign2 = imAssign(:,:,1);
    C = 0.2;
    tolFac = 0.2;
    
    tic;
    bestBox = ml_findBox1c(imAssign2, targetHists, [], levelWeights, ...
        nBranch, C, tolFac);
    toc;
    % display
    im1 = imread('../data/im1.jpg');
    im2 = imread('../data/im2.jpg');
    figure; nR = 2; nC = 2;
    subplot(nR, nC, 1); imshow(im1); hold on;
    drawRect(BBox, 'red', 2);
    title('Target');
    subplot(nR, nC, 2); imshow(im2); hold on;
    drawRect(bestBox, 'red', 2);
    title('Best matched');
    subplot(nR, nC, 3); imagesc(imAssign1); hold on; axis image;
    drawRect(BBox, 'black', 2);
    title('Target');
    subplot(nR, nC, 4); imagesc(imAssign2); hold on; axis image;
    drawRect(bestBox, 'black', 2);
    title('Best matched');    
    
function demo_findBox1d()
    % Get the target histogram from image 1.
    load('../data/sift1.mat', 'imAssign', 'nClust');
    layerIdxs = [1, 6];
    imAssigns1 = imAssign(:,:,layerIdxs);
    nHistBins = nClust(layerIdxs);
    mask1 = imread('../data/mask1.bmp');    
    targetHists = m_cmpRegHist_multi(imAssigns1, nHistBins, mask1);
    
    % Find the best box in second image
    load('../data/sift2.mat', 'imAssign', 'nClust');
    imAssigns2 = imAssign(:,:,layerIdxs);
    C = 0.2;
    tolFac = 0;
    tic;
    bestBox = ml_findBox1d(imAssigns2, targetHists, [], nHistBins, C, tolFac);
    toc;
    % display
    im1 = imread('../data/im1.jpg');
    im2 = imread('../data/im2.jpg');
    figure; nR = 3; nC = 2;
    subplot(nR, nC, 1); imshow(im1); hold on;
    drawBoundary(mask1, 'red', 2);
    title('Target');
    subplot(nR, nC, 2); imshow(im2); hold on;
    drawRect(bestBox, 'red', 2);
    title('Best matched');
    subplot(nR, nC, 3); imagesc(imAssigns1(:,:,1)); hold on; axis image;
    drawBoundary(mask1, 'black', 2);
    title('Target, histogram assign 1');    
    subplot(nR, nC, 5); imagesc(imAssigns1(:,:,2)); hold on; axis image;
    drawBoundary(mask1, 'black', 2);
    title('Target, histogram assign 2');
    
    subplot(nR, nC, 4); imagesc(imAssigns2(:,:,1)); hold on; axis image;
    drawRect(bestBox, 'black', 2);
    title('Best matched, histogram assign 1');   
    
    subplot(nR, nC, 6); imagesc(imAssigns2(:,:,2)); hold on; axis image;
    drawRect(bestBox, 'black', 2);
    title('Best matched, histogram assign 2'); 
    
    
function demo_findBoxes()
    % Get the target histogram from image 1.
    %load('../data/sift1.mat', 'imAssign', 'nClust');
    load DMap60;
    
    %im1Assign = imAssign(:,:,1);
    im1Assign = DMap{31};
    
    % Find the best box in second image
    %load('../data/sift2.mat', 'imAssign', 'nClust');
    %im2Assign = imAssign(:,:,1);
    im2Assign = DMap{32};
    C = 0.2;
    tolFac = 0.3;
    tic;
    [bestBox1, bestBox2] = ml_findBoxes(im1Assign, im2Assign, ...
        [], C, tolFac, 0, 0, 1);    
    toc;
    % display
    im1 = imread('D:\Projects\NatImgCateg\Datasets\caltech101pgm\dalmatian\image_0001.pgm');
    im2 = imread('D:\Projects\NatImgCateg\Datasets\caltech101pgm\dalmatian\image_0002.pgm');
    %im2 = imread('../data/im2.jpg');
    figure; nR = 2; nC = 2;
    subplot(nR, nC, 1); imshow(im1); hold on;
    drawRect(bestBox1, 'red', 2);
    title('image 1');
    subplot(nR, nC, 2); imshow(im2); hold on;
    drawRect(bestBox2, 'red', 2);
    title('image 2');
    subplot(nR, nC, 3); imagesc(im1Assign); hold on; axis image;
    drawRect(bestBox1, 'black', 2);
    title('image 1');
    subplot(nR, nC, 4); imagesc(im2Assign); hold on; axis image;
    drawRect(bestBox2, 'black', 2);
    title('image 2');    
    
% Draw the boundary of the mask
% Inputs:
%   mask: the mask, imH*imW matrix
%   color: a string for the color, e.g. 'r', 'b', 'k'
%   lineWidth: a number of the width of the boundary
% Output:
%   draw on the current figure  the boundary of the mask
% By: Minh Hoai Nguyen (t-minguy@microsoft.com)
% Date: 5 Aug 2008
function drawBoundary(mask, color, lineWidth)
    B = bwboundaries(mask, 8, 'noholes');
    for k=1:length(B),
       boundary = B{k};
       plot(boundary(:,2),...
           boundary(:,1), color,'LineWidth', lineWidth);
    end

function drawRect(box, color, lineWidth)    
    rectangle('Position', [box(1), box(2), box(3) - box(1), box(4) - box(2)], ...
     'LineWidth', lineWidth, 'EdgeColor', color);    
