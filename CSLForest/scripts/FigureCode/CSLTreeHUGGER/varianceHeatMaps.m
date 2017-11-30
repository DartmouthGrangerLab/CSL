% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [heatMaps] = varianceHeatMaps(PARAMSTRUCT, sortByClass)
    %REQUIRED:
    %PARAMSTRUCT.PredLabels
    %PARAMSTRUCT.DMap
    %PARAMSTRUCT.frontend
    %PARAMSTRUCT.VOCAB_SIZE
    %PARAMSTRUCT.K
    %PARAMSTRUCT.filePrefix
    %PARAMSTRUCT.dateString
    %PARAMSTRUCT.OutputPath
	%Creates heatmaps showing each values variance from mean, sorted by class
    %   Classes come from PredLabels;
    %   DMap are the images in vocab summarized form;
    heatMaps = {};
    purity = {}; % variances for each word count from mean for each cluster
    
    %% sort DMap so images from each cluster are groupable
    PARAMSTRUCT.PredLabels = PARAMSTRUCT.PredLabels';
    numClusters = numel(unique(PARAMSTRUCT.PredLabels));
    ClassSortedDmaps = cell(numClusters, size(PARAMSTRUCT.PredLabels, 2)); %assumes labels are contiguous starting at 1
    for i = 1:size(PARAMSTRUCT.PredLabels, 2)
        label = PARAMSTRUCT.PredLabels(i);
        ClassSortedDmaps{label,i} = PARAMSTRUCT.DMap{i};
    end
    allWordCounts = [];
    meansForAllClusters = {};
    clusterSize = zeros(1,numClusters);
    
    %% purity calcs
    %http://nlp.stanford.edu/IR-book/html/htmledition/evaluation-of-clustering-1.html
    empties = 0;
    idx = 1;
    while idx <= numClusters
        cluster = ClassSortedDmaps(idx,1:end);

        emptyStrippedCluster = cluster(~cellfun('isempty', cluster));
        clusterSize(idx) = size(emptyStrippedCluster,2);
        clusterWordCounts = [];
        for idx2 = 1:size(cluster,2)
            if isempty(cluster{idx2})
                continue;
            end
            [rowSize, colSize] = size(PARAMSTRUCT.DMap{idx2});
            imageVec = reshape(cluster{idx2},1,rowSize*colSize);
            imageWordCounts = hist(imageVec, PARAMSTRUCT.VOCAB_SIZE);
            clusterWordCounts = vertcat(clusterWordCounts, imageWordCounts);
        end
        allWordCounts = vertcat(allWordCounts, clusterWordCounts);
        
        meanClusterWordCounts = mean(clusterWordCounts);
        meansForAllClusters{idx} = meanClusterWordCounts;
        meanClusterWordCounts = repmat(meanClusterWordCounts, size(clusterWordCounts,1),1);
        purity{idx} = (sum((clusterWordCounts - meanClusterWordCounts).^2,1))/(size(clusterWordCounts,1)-PARAMSTRUCT.K);
        if isnan(mean(purity{idx})) 
            purity(:,idx) = []; % NaN when cluster is empty, needs to be fixed or will mess up calcs TEMP FIX
            ClassSortedDmaps(idx, :) = [];
            idx = idx -1;
            numClusters = numClusters - 1;
        end
        idx = idx + 1;
    end
    
    allClassMean = mean(allWordCounts);
    
    %% "distinctiveness" calcs
    distinctiveness = [];
    allOther = [];
    for idx3 = 1:numClusters
        temp = purity;
        temp(idx3) = []; % make the one with k = i go away
        for tmpidx = 1:(numClusters-1)
            allOther = vertcat(allOther,temp{tmpidx});
        end
        allOther = mean(allOther);
        distinctiveness(idx3,:) = allOther;
        allOther = [];
    end
    
    heatSubs = {};
    
    for idx4 = 1:numClusters
        heatSubs{idx4} = distinctiveness(idx4) ./ purity{idx4};
    end
    
    %% Do subs for each class for each DMAP
    SubbedSortedDMap = {};
    heatCntEmpties = 0;
    for label = 1:size(ClassSortedDmaps, 1)
        for idx5 = 1:size(ClassSortedDmaps, 2)
            if isempty(ClassSortedDmaps{label,idx5})
                heatCntEmpties = heatCntEmpties+1;
                continue;
            end
            SubbedSortedDMap{label, idx5} = chngVals(heatSubs{label}, ClassSortedDmaps{label,idx5}, PARAMSTRUCT.VOCAB_SIZE);
        end
    end
    
    heatMaps = SubbedSortedDMap;
    %% Do the plotting of the variance heat maps
    if ~strcmp(PARAMSTRUCT.filePrefix,'NOFIGS')
        placeCnt = 1;
        cnt = 0;
        figHandle = figure;
        if sortByClass == 1
            for label = 1:size(SubbedSortedDMap, 1)
                for idx6 = 1:size(SubbedSortedDMap, 2)
                    cnt = cnt+1;
                    if isempty(ClassSortedDmaps{label,idx6})
                        continue;
                    end
                    h = subplot_tight(5, 5, placeCnt);
                    RenderFig(PARAMSTRUCT, SubbedSortedDMap, h, cnt, label, idx6);

                    placeCnt = placeCnt + 1;
                    if placeCnt > 25
                        placeCnt = 1;

                        set(figHandle, 'PaperPosition', [0, 0, 16, 10]);
                        outputFn = strcat(PARAMSTRUCT.filePrefix, PARAMSTRUCT.frontend, '_heatmap_', num2str(label), '_', num2str(idx6), '_', PARAMSTRUCT.dateString, '.fig');
                        saveas(figHandle, outputFn);
                        outputFn = strcat(PARAMSTRUCT.filePrefix, PARAMSTRUCT.frontend, '_heatmap_', num2str(label), '_', num2str(idx6), '_', PARAMSTRUCT.dateString, '.tif');
                        saveas(figHandle, outputFn);
                        figHandle = figure;
                    end
                end
                cnt = 0;
            end
        else
            figCount = 1;
            for idx6 = 1:size(SubbedSortedDMap, 2)
                for label = 1:size(SubbedSortedDMap, 1)
                    if isempty(ClassSortedDmaps{label,idx6})
                        continue;
                    end
                    h = subplot_tight(5, 5, placeCnt);
                    RenderFig(PARAMSTRUCT, SubbedSortedDMap, h, idx6, label, idx6);

                    placeCnt = placeCnt + 1;
                    if placeCnt > 25
                        placeCnt = 1;

                        set(figHandle, 'PaperPosition', [0, 0, 16, 10]);
                        outputFn = strcat(PARAMSTRUCT.filePrefix, PARAMSTRUCT.frontend, '_heatmap_', num2str(figCount), '_', PARAMSTRUCT.dateString, '.fig');
                        saveas(figHandle, outputFn);
                        outputFn = strcat(PARAMSTRUCT.filePrefix, PARAMSTRUCT.frontend, '_heatmap_', num2str(figCount), '_', PARAMSTRUCT.dateString, '.tif');
                        saveas(figHandle, outputFn);
                        figHandle = figure;
                        figCount = figCount + 1;
                    end
                end
            end
        end
    end
end

function subbed = chngVals(subs, DMap, VOCAB_SIZE)
    for idx = 1:VOCAB_SIZE
        DMap (DMap == idx) = subs(idx);
    end
    subbed = DMap;
end

function [] = RenderFig (PARAMSTRUCT, SubbedSortedDMap, h, cnt, label, idx6)
    COLORMAP = [0.392156869173050,0.0156862754374743,0.0588235296308994;0.393277317285538,0.0231559295207262,0.0606909431517124;0.394397765398026,0.0306255854666233,0.0625583603978157;0.395518213510513,0.0380952395498753,0.0644257739186287;0.396638661623001,0.0455648936331272,0.0662931874394417;0.397759109735489,0.0530345477163792,0.0681606009602547;0.398879557847977,0.0605042055249214,0.0700280144810677;0.400000005960465,0.0679738596081734,0.0718954280018807;0.401120454072952,0.0754435136914253,0.0737628415226936;0.402240902185440,0.0829131677746773,0.0756302550435066;0.403361350297928,0.0903828218579292,0.0774976685643196;0.404481798410416,0.0978524759411812,0.0793650820851326;0.405602246522903,0.105322130024433,0.0812324956059456;0.406722694635391,0.112791784107685,0.0830999091267586;0.407843142747879,0.120261445641518,0.0849673226475716;0.408963590860367,0.127731099724770,0.0868347361683846;0.410084038972855,0.135200753808022,0.0887021496891975;0.411204487085342,0.142670407891274,0.0905695632100105;0.412324935197830,0.150140061974525,0.0924369767308235;0.413445383310318,0.157609716057777,0.0943043902516365;0.414565831422806,0.165079370141029,0.0961718037724495;0.415686279535294,0.172549024224281,0.0980392172932625;0.416806727647781,0.180018678307533,0.0999066308140755;0.417927175760269,0.187488332390785,0.101774044334888;0.419047623872757,0.194957986474037,0.103641457855701;0.420168071985245,0.202427640557289,0.105508871376514;0.421288520097733,0.209897294640541,0.107376284897327;0.422408968210220,0.217366948723793,0.109243698418140;0.423529416322708,0.224836602807045,0.111111119389534;0.424649864435196,0.232306256890297,0.112978532910347;0.425770312547684,0.239775910973549,0.114845946431160;0.426890760660172,0.247245579957962,0.116713359951973;0.428011208772659,0.254715234041214,0.118580773472786;0.429131656885147,0.262184888124466,0.120448186993599;0.430252104997635,0.269654542207718,0.122315600514412;0.431372553110123,0.277124196290970,0.124183014035225;0.432493001222611,0.284593850374222,0.126050427556038;0.433613449335098,0.292063504457474,0.127917841076851;0.434733897447586,0.299533158540726,0.129785254597664;0.435854345560074,0.307002812623978,0.131652668118477;0.436974793672562,0.314472466707230,0.133520081639290;0.438095241785049,0.321942120790482,0.135387495160103;0.439215689897537,0.329411774873734,0.137254908680916;0.457352936267853,0.346568644046783,0.127450987696648;0.475490212440491,0.363725483417511,0.117647066712379;0.493627458810806,0.380882352590561,0.107843138277531;0.511764705181122,0.398039221763611,0.0980392172932625;0.529901981353760,0.415196090936661,0.0882352963089943;0.548039257526398,0.432352960109711,0.0784313753247261;0.566176474094391,0.449509799480438,0.0686274543404579;0.584313750267029,0.466666668653488,0.0588235296308994;0.616289615631104,0.507692337036133,0.0542986430227757;0.648265480995178,0.548717975616455,0.0497737564146519;0.680241346359253,0.589743614196777,0.0452488698065281;0.712217211723328,0.630769252777100,0.0407239831984043;0.744193077087402,0.671794891357422,0.0361990965902805;0.776168942451477,0.712820529937744,0.0316742099821568;0.808144807815552,0.753846168518066,0.0271493215113878;0.840120673179627,0.794871807098389,0.0226244349032640;0.872096538543701,0.835897445678711,0.0180995482951403;0.904072403907776,0.876923084259033,0.0135746607556939;0.936048269271851,0.917948722839356,0.00904977414757013;0.968024134635925,0.958974361419678,0.00452488707378507;1,1,0];
    colormap(COLORMAP);
    imagesc(SubbedSortedDMap{label, idx6});
    axis off;
    colorbar;
%     rectangle('Position', [PARAMSTRUCT.OutRectWins(cnt,1), PARAMSTRUCT.OutRectWins(cnt,2), ...
%         PARAMSTRUCT.OutRectWins(cnt,3)-PARAMSTRUCT.OutRectWins(cnt,1), PARAMSTRUCT.OutRectWins(cnt,4)-PARAMSTRUCT.OutRectWins(cnt,2)],...
%         'EdgeColor', 'b');
    imgSize = size(SubbedSortedDMap{label, idx6});
    text(imgSize(2)/4, imgSize(1)/4, strcat(num2str(PARAMSTRUCT.PredLabels(cnt)), '-', num2str(cnt)), 'color', 'b', 'FontSize', 10, 'HorizontalAlignment', 'center');
end