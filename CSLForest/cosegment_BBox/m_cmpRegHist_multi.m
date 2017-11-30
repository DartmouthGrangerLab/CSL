function histos = m_cmpRegHist_multi(imAssigns, nHistBins, mask)
% function m_cmpRegHist(imAssign, mask)
% Compute the histogram of the pixels inside a region.
% Inputs:
%   imAssigns: a 3D imH*imW*nHistType array of positive integers, 
%       imAssigns(i,j,k) indicates which histogram bin in the k^th histogram 
%       the pixel (i,j) is assigned to.
%   nHistBins: 1D array for no of bins in the histograms.
%   mask: a 2D array, the mask for the region of interest. Postive entries
%       of mask define the region of interest.
% Outputs:
%   histos: 2D array for the histograms of the region.
% By: Minh Hoai Nguyen (t-minguy@microsoft.com)
% Date: 6 June 2008.

nHistBin_max = max(nHistBins);
nHistType = length(nHistBins);
histos = zeros(nHistBin_max, nHistType);

for i=1:nHistType
    imAssign = imAssigns(:,:,i);
    nHistBin = nHistBins(i);
    regAssign = imAssign(mask > 0);
    histo = hist(regAssign, 1:nHistBin);
    histos(1:nHistBin,i) = histo(:);
end;