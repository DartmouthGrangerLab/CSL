% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function memcnt = determine_membercount(content, labelset, labels)
    %% Determines the member labels at a particular node
    % INPUT:
    % content : memeber of the node 
    % labelset : An array of all the categories used for training
    % labels : Training dataset labels
    % OUTPUT:
    % memcnt : returns the count for each label at the node

    memcnt = zeros(length(labelset),1);
    l = labels(content);
    for i = 1:length(labelset)
    	memcnt(i) = numel(find(l == labelset(i)));
    end
end
