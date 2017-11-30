% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [randff_data,ff_points] = randfeat_supervised (data, pts, ff)
    %% Random selection of features for clustering
    % INPUT:
    % data : Training dataset
    % pts : Data points at a particular node
    % ff : feature fraction

    % OUTPUT:
    % randff_data: data with selected features only
    % ff_points : random features selected to split the data
    
    node_data = data(pts,:);
    dim = size(node_data,2);
    features = ceil(ff * dim);
    points = randperm(dim);
    ff_points = points(1:features);
    randff_data = node_data(:, ff_points);
end
