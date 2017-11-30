% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [x,y,w,h] = GetFileDimensions (ImgLink, frontend, border)
    temp = ImgLink(regexp(ImgLink, '_i\d*j\d*.tif'):size(ImgLink,2));
    indexi = regexp(temp, 'i\d*');
    x = str2double(temp(indexi(1)+1:regexp(temp, 'j')-1));
    y = str2double(temp(regexp(temp, 'j')+1:regexp(temp, '\.')-1));
    temp2 = ImgLink(regexp(ImgLink, 'w\d*h\d*_'):size(ImgLink,2));
    indexw = regexp(temp2, 'w\d*');
    w = str2double(temp2(indexw(1)+1:regexp(temp2, 'h')-1));
    h = str2double(temp2(regexp(temp2, 'h')+1:regexp(temp2, '_')-1));
    if strcmp (frontend,'sift')
        x = x + border;
        y = y + border;
        w = w - 2*border;
        h = h - 2*border;
    end
end