% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
% DESCRIPTION: Routine to generate histogram map for all images in a given directory
function QuantImg = GetQuantizedImg_MSHarris(ImgFile, vocab)
    ImgInfo = imfinfo(char(ImgFile));
    QuantImg = zeros(ImgInfo.Height, ImgInfo.Width, 1);
    [ImgFeatures, ImgLocs] = GetMSHarrisFeaturesFromFile(char(ImgFile));
    
    for feat = 1:size(ImgFeatures, 1)
        QuantImg(ceil(ImgLocs(feat,2)), ceil(ImgLocs(feat,1)), 1) = CalculateBestFitVocabIndex(ImgFeatures(feat,:), vocab);
    end
end
