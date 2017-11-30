% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
% This will need some work
function [PyrmHist] = CalcPyramidWindowHist (Img, box, VOCAB_SIZE, PYR_LEVELS)
    PyrmHist = [];
    CurrQ = box;
    NxtQ = [];
    for lvl = 0:PYR_LEVELS-1
        while size(CurrQ, 1) > 0
            CurrWin = CurrQ(1,:);
            CurrQ(1,:) = [];
            Hist = CalcWindowHist(Img, CurrWin, VOCAB_SIZE);
            PyrmHist = horzcat(PyrmHist, Hist);
            [tl, tr, bl, br] = QuadSplit(CurrWin);
            NxtQ = vertcat(NxtQ, tl);
            NxtQ = vertcat(NxtQ, tr);
            NxtQ = vertcat(NxtQ, bl);
            NxtQ = vertcat(NxtQ, br);
        end
        CurrQ = NxtQ;
        NxtQ = [];
    end   
    
    %% Normalize the histogram
    %PyrmHist = PyrmHist / sum(PyrmHist);
end


function [tl,tr,bl,br] = QuadSplit (win)
    tl = win;
    tr = win;
    bl = win;
    br = win;
    
    % indices
    ul_x = win(1);
    ul_y = win(2);
    lr_x = win(3);
    lr_y = win(4);
    
	x1 = floor((ul_x + lr_x)/2);
	y1 = floor((ul_y + lr_y)/2);

    if  ul_x < lr_x
        x2 = x1 + 1;
    else
        x2 = x1;
    end
    
    if ul_y < lr_y
		y2 = y1 + 1;
	else
		y2 = y1;
    end
	
	tl(3) = x1;
    tl(4) = y1;
      
	tr(1) = x2;
	tr(4) = y1;
    
	bl(2) = y2;
	bl(3) = x1;
	
	br(1) = x2;
	br(2) = y2;
end


%has a different method for handling multi-channel images
function [Hist] = CalcWindowHist(Img, box, VOCAB_SIZE)
    Hist = zeros(1, VOCAB_SIZE * size(Img, 3));
    
    for row = box(2):box(4) %y
        for col = box(1):box(3) %x
            for chan = 1:size(Img, 3)
                idx = int32(Img(row, col, chan)); %TEMP - need to deal with this for multichannel images!!!!
                Hist(VOCAB_SIZE * (chan-1) + idx) = Hist(VOCAB_SIZE * (chan-1) + idx) + 1;
            end
        end
    end
end

