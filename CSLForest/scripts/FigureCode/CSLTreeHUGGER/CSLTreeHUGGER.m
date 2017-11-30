% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract

%Tree Highly Useful Gui for Getting Everything Relevant out of CSL (CSL Tree HUGGER)
%By Eli with some xml parsing bits from http://www.mathworks.com/help/matlab/ref/xmlread.html
%takes either an xml file or variable forest, always takes the mat file
%This code looks to a .mat file with the same name as the xml file. Here is what it should contain:
%PARAMETERS:
    %fileName (REQUIRED) - name of a .mat file containing the below variables.
    %forest (OPTIONAL) - variable containing the tree structure. if absent, an XML file with the same name as fileName must be available in the path.
%MANDITORY MAT FILE CONTENTS:
    %TrainRefI - reference images, ie the original images we want to display (cell array of matrices)
    %TestRefI - reference images, ie the original images we want to display (cell array of matrices)
    %TrainDMapI - array (row #) indices of the training data
    %TestDMapI - array (row #) indices of the testing data
    %TrainL - training labels
    %TestL - testing labels
%OPTIONAL MAT FILE CONTENTS:
    %description - text describing the run params and purpose
    %frontend
    %SIFTBorder - required only if nonzero
    %ImgLinks - required only if executing the hacky code at the bottom of RenderTree()
    %windows - always useful, but required only if executing the hacky code at the bottom of RenderTree()
function [] = CSLTreeHUGGER (fileName, forest)
    clearvars -except fileName forest;
    global TREEROOTS;
    global F1; %figure 1
    global MEMBERTYPE;
    global CURRTREE;
    global COLORMAP;
    
    %% User Params
    global PURITYTHRESHOLD; PURITYTHRESHOLD = 0.8; %.8 is reasonable
    % RED for impure bottom rank
    global ORANGEPURETHRESH; ORANGEPURETHRESH = .6;
    global YELLOWPURETHRESH; YELLOWPURETHRESH = .75;
    global GREENPURETHRESH; GREENPURETHRESH = .95;
    
    global BRANCHINGFACTOR; BRANCHINGFACTOR = 6;
    
    %first one is from Rick
    COLORMAP = [0.392156869173050,0.0156862754374743,0.0588235296308994;0.393277317285538,0.0231559295207262,0.0606909431517124;0.394397765398026,0.0306255854666233,0.0625583603978157;0.395518213510513,0.0380952395498753,0.0644257739186287;0.396638661623001,0.0455648936331272,0.0662931874394417;0.397759109735489,0.0530345477163792,0.0681606009602547;0.398879557847977,0.0605042055249214,0.0700280144810677;0.400000005960465,0.0679738596081734,0.0718954280018807;0.401120454072952,0.0754435136914253,0.0737628415226936;0.402240902185440,0.0829131677746773,0.0756302550435066;0.403361350297928,0.0903828218579292,0.0774976685643196;0.404481798410416,0.0978524759411812,0.0793650820851326;0.405602246522903,0.105322130024433,0.0812324956059456;0.406722694635391,0.112791784107685,0.0830999091267586;0.407843142747879,0.120261445641518,0.0849673226475716;0.408963590860367,0.127731099724770,0.0868347361683846;0.410084038972855,0.135200753808022,0.0887021496891975;0.411204487085342,0.142670407891274,0.0905695632100105;0.412324935197830,0.150140061974525,0.0924369767308235;0.413445383310318,0.157609716057777,0.0943043902516365;0.414565831422806,0.165079370141029,0.0961718037724495;0.415686279535294,0.172549024224281,0.0980392172932625;0.416806727647781,0.180018678307533,0.0999066308140755;0.417927175760269,0.187488332390785,0.101774044334888;0.419047623872757,0.194957986474037,0.103641457855701;0.420168071985245,0.202427640557289,0.105508871376514;0.421288520097733,0.209897294640541,0.107376284897327;0.422408968210220,0.217366948723793,0.109243698418140;0.423529416322708,0.224836602807045,0.111111119389534;0.424649864435196,0.232306256890297,0.112978532910347;0.425770312547684,0.239775910973549,0.114845946431160;0.426890760660172,0.247245579957962,0.116713359951973;0.428011208772659,0.254715234041214,0.118580773472786;0.429131656885147,0.262184888124466,0.120448186993599;0.430252104997635,0.269654542207718,0.122315600514412;0.431372553110123,0.277124196290970,0.124183014035225;0.432493001222611,0.284593850374222,0.126050427556038;0.433613449335098,0.292063504457474,0.127917841076851;0.434733897447586,0.299533158540726,0.129785254597664;0.435854345560074,0.307002812623978,0.131652668118477;0.436974793672562,0.314472466707230,0.133520081639290;0.438095241785049,0.321942120790482,0.135387495160103;0.439215689897537,0.329411774873734,0.137254908680916;0.457352936267853,0.346568644046783,0.127450987696648;0.475490212440491,0.363725483417511,0.117647066712379;0.493627458810806,0.380882352590561,0.107843138277531;0.511764705181122,0.398039221763611,0.0980392172932625;0.529901981353760,0.415196090936661,0.0882352963089943;0.548039257526398,0.432352960109711,0.0784313753247261;0.566176474094391,0.449509799480438,0.0686274543404579;0.584313750267029,0.466666668653488,0.0588235296308994;0.616289615631104,0.507692337036133,0.0542986430227757;0.648265480995178,0.548717975616455,0.0497737564146519;0.680241346359253,0.589743614196777,0.0452488698065281;0.712217211723328,0.630769252777100,0.0407239831984043;0.744193077087402,0.671794891357422,0.0361990965902805;0.776168942451477,0.712820529937744,0.0316742099821568;0.808144807815552,0.753846168518066,0.0271493215113878;0.840120673179627,0.794871807098389,0.0226244349032640;0.872096538543701,0.835897445678711,0.0180995482951403;0.904072403907776,0.876923084259033,0.0135746607556939;0.936048269271851,0.917948722839356,0.00904977414757013;0.968024134635925,0.958974361419678,0.00452488707378507;1,1,0];
    %second one is from Brett
%     COLORMAP = [1 0 0;1 0.0284619592130184 0;1 0.0569239184260368 0;1 0.0853858813643456 ...
%                     0;1 0.113847836852074 0;1 0.142309799790382 0;1 0.170771762728691 0;1 0.199233725667 0;...
%                     1 0.227695673704147 0;1 0.256157636642456 0;1 0.284619599580765 0;1 0.313081562519073 0;...
%                     1 0.341543525457382 0;1 0.370005488395691 0;1 0.398467451334 0;1 0.426929384469986 0;...
%                     1 0.455391347408295 0;1 0.483853310346603 0;1 0.512315273284912 0;1 0.540777266025543 0;...
%                     1 0.56923919916153 0;1 0.597701132297516 0;1 0.626163125038147 0;1 0.654625058174133 0;...
%                     1 0.683087050914764 0;1 0.711548984050751 0;1 0.740010976791382 0;1 0.768472909927368 0;...
%                     1 0.796934902667999 0;1 0.825396835803986 0;1 0.830532193183899 0;1 0.835667610168457 0;...
%                     1 0.840803027153015 0;1 0.845938384532928 0;1 0.851073741912842 0;1 0.8562091588974 0;...
%                     1 0.861344575881958 0;1 0.866479933261871 0;1 0.871615290641785 0;1 0.876750707626343 0;...
%                     1 0.881886124610901 0;1 0.887021481990814 0;1 0.892156839370728 0;1 0.897292256355286 0;...
%                     1 0.902427673339844 0;1 0.907563030719757 0;1 0.91269838809967 0;1 0.917833805084229 0;...
%                     1 0.922969222068787 0;1 0.9281045794487 0;1 0.933239936828613 0;1 0.938375353813171 0;...
%                     1 0.943510770797729 0;1 0.948646128177643 0;1 0.953781485557556 0;1 0.958916902542114 0;...
%                     1 0.964052319526672 0;1 0.969187676906586 0;1 0.974323034286499 0;1 0.979458451271057 0;...
%                     1 0.984593868255615 0;1 0.989729225635529 0;1 0.994864583015442 0;1 1 0];
                
    %% Init Code
    F1 = figure('name','CSL Tree HUGGER');
    imshow('treehugger.jpg');
    pause(1);
    
    MEMBERTYPE = 'TRAINMEMBER'; %MUST be 'TRAINMEMBER' or 'TESTMEMBER'
    
    if ~exist('forest','var')
        try
            load(strrep(fileName, '.mat', '_xml_converted.mat')); %loads forest
        catch 
            try
                load(strrep(fileName, '.mat', '_forest.mat')); %loads forest
            catch
                xmlDoc = xmlread(strrep(fileName, '.mat', '.xml'));
                xmlRoot = xmlDoc.getDocumentElement;

                childNodes = xmlRoot.getChildNodes;
                numChildNodes = childNodes.getLength;

                forest = {};
                for count = 1:numChildNodes
                    theChild = childNodes.item(count-1);
                    name = char(theChild.getNodeName);
                    switch name
                        case 'MAXK'
                            %unused
                        case 'BF'
                            %unused
                        case 'FF'
                            %unused
                        case 'MINSIZE'
                            %unused
                        case 'MAXNODELEVEL'
                            %unused
                        case 'STARTTIME'
                            %unused
                        case 'TREE'
                            forest(numel(forest)+1) = {ParseTree(theChild)};
                    end
                end
            end
            save(strrep(fileName, '.mat', '_xml_converted.mat'), 'forest');
        end
    else
        save(strrep(fileName, '.mat', '_xml_converted.mat'), 'forest');
    end
    
    LoadSupportingData(fileName);
    
    TREEROOTS = forest;
    CURRTREE = 1;
    RenderTree(TREEROOTS{1});
end


function [] = RenderTree (rootNode)
    global F1;
    global GUINODEHANDLES;
    global NODEPOINTERS;
    % RED for impure bottom rank
    global ORANGEPURETHRESH; 
    global YELLOWPURETHRESH;
    global GREENPURETHRESH;
    global TRAINREFIMGS;
    global TESTREFIMGS;
    global TRAINLABELS;
    global TESTLABELS;
    global TRAINIMGLINKS;
    global TESTIMGLINKS;
    global FRONTEND;
    global SIFTBORDER;
    global TRAINWINDOWS;
    global TESTWINDOWS;
    global TRAINDMAPI;
    global TRAINDMAP;
    global TESTDMAP;
    global DMAP;
    global TREEROOTS;
    global MEMBERTYPE;
    global CURRTREE;
    global JOINTSTILLS_CSL_JOINTSTILLS_CSL;
    
    figure(F1);
%     set(gcf,'Color','black'); % better for on screen viewing
%     whitebg(1,'k')
    
    %clear things
    clf;
    NODEPOINTERS = TREEROOTS{CURRTREE};
    
    %1. generate a nice set of parent pointers
    parentPointers = [0,0];
    children = determine_children(rootNode, 1);
    for i = 1:numel(children)
        parentPointers = [parentPointers; GetParentPointers(rootNode, children(i), 0)];
    end
    myMembers = [];
    parentPointers(1,:) = [];
    parentPointers(parentPointers==0) = 1;
    parents(parentPointers(:,2)) = parentPointers(:,1);
    %2. use treelayout to figure out where to plot each node
    [x,y] = treelayout(parents);
    %3. loop over every node and plot it
    y = y+.05; %bump the tree up a little from the bottom of the figure.
    for i = 1:numel(x)
        [isLeaf, purity, pitPurity, members] = RatePurity(i);
            if JOINTSTILLS_CSL_JOINTSTILLS_CSL == 1
                ORANGEPURETHRESH = 2;
                YELLOWPURETHRESH = 2;
                GREENPURETHRESH = 2;
            end
        if (pitPurity >= ORANGEPURETHRESH && pitPurity < YELLOWPURETHRESH)
            color = 'c'; % cyan temp as simple fix to have orange color without much fuss
        elseif (pitPurity >= YELLOWPURETHRESH && pitPurity < GREENPURETHRESH)
            color = 'y';
        elseif pitPurity > GREENPURETHRESH
            color = 'g';
        else
            if isLeaf == 1
                myMembers = [myMembers, members];
            end
            color = 'r';
        end
        GUINODEHANDLES(i) = line(x(i), y(i), 'LineWidth', 2, 'marker', 'o', 'MarkerSize', 15, 'Color', color, 'ButtonDownFcn', {@RenderNode,i,F1+i});
        if color == 'c' % replace cyan with orangey color
            set(GUINODEHANDLES(i),'color',[1 0.6 0]);
        end
        %text(x(i), y(i), num2str(i), 'color', 'k', 'FontSize', 8, 'HorizontalAlignment', 'center');
        if parents(i) > 0
            line([x(i), x(parents(i))],[y(i)+0.008, y(parents(i))-0.008]);
        end
        hold on;
    end
    set(findobj(F1, 'type','axes'),'xtick',[]);
    set(findobj(F1, 'type','axes'),'ytick',[]);
    uicontrol('Style', 'popup', 'String', 'Train|Test', 'Position', [20 65 100 50], 'Callback', @ChangeTrainTest); %popup function handle callback
    uicontrol('Style', 'popup', 'String', '1|2|3|4|5|6|7|8|9|10', 'Position', [20 40 100 50], 'Callback', @ChangeTree); %popup function handle callback
    if strcmp(MEMBERTYPE, 'TRAINMEMBER')
        trainTestStr = 'Train';
    else
        trainTestStr = 'Test';
    end
    uicontrol('Style', 'text', 'String', strcat('Tree: ', num2str(CURRTREE), ',', trainTestStr), 'Position', [20 20 150 20]);
    
    %please DO NOT DELETE the following
    if JOINTSTILLS_CSL_JOINTSTILLS_CSL == 1
        global ImgPath; %assumed from demo.m or demoJSCSLJSCSL.m
        for i = 1:numel(myMembers)
            imgLink = TESTIMGLINKS{myMembers(i)};
            [x,y,width,height] = GetFileDimensions(imgLink{1}, FRONTEND, SIFTBORDER);
            miniimage = TESTREFIMGS{myMembers(i)};
            windowX = TESTWINDOWS(myMembers(i),1);
            windowY = TESTWINDOWS(myMembers(i),2);
            windowXb = TESTWINDOWS(myMembers(i),3);
            windowYb = TESTWINDOWS(myMembers(i),4);
            x = x + windowX;
            y = y + windowY;
            if strcmp(FRONTEND, 'sift')
                miniimage = miniimage(windowY:windowYb+2*SIFTBORDER, windowX:windowXb+2*SIFTBORDER);
                x = x - SIFTBORDER;
                y = y - SIFTBORDER;
            else
                miniimage = miniimage(windowY:windowYb, windowX:windowXb);
            end
            if TESTLABELS(myMembers(i)) == 1
                imwrite(miniimage, strcat(ImgPath, 'looted/', 'w', num2str(size(miniimage,2)), 'h', num2str(size(miniimage,1)), '_looted_i', num2str(x), 'j', num2str(y), '.tif'));
            else
                imwrite(miniimage, strcat(ImgPath, 'unlooted/', 'w', num2str(size(miniimage,2)), 'h', num2str(size(miniimage,1)), '_unlooted_i', num2str(x), 'j', num2str(y), '.tif'));
                imwrite(miniimage, strcat(ImgPath, 'unlooted_vocab/', 'w', num2str(size(miniimage,2)), 'h', num2str(size(miniimage,1)), '_unlooted_vocab_i', num2str(x), 'j', num2str(y), '.tif'));
            end
        end
    end
end

%% RenderNode
function RenderNode (hObj, event, handleNum, figNum)
    global GUINODEHANDLES;
    global NODEPOINTERS;
    global TRAINLABELS;
    global TESTLABELS;
    global TRAINREFIMGS;
    global TRAINDMAPI;
    global TRAINDMAP;
    global TESTDMAP;
    global DMAP;
    global TESTREFIMGS;
    global TRAINWINDOWS;
    global TESTWINDOWS;
    global SIFTBORDER;
    global MEMBERTYPE;
    global FRONTEND;
    global VOCAB_SIZE;
    global K;
    global BRANCHINGFACTOR;
    global COLORMAP;
    
    val = get(hObj,'userdata'); %val of 0 = now off, val of 1 = now on
    if val == 1
        %it's currently open
        set(GUINODEHANDLES(handleNum), 'userdata', 0);
        set(GUINODEHANDLES(handleNum), 'MarkerSize',20);
        try
            close(figNum);
        end
    else
        set(GUINODEHANDLES(handleNum), 'userdata', 1);
        set(GUINODEHANDLES(handleNum), 'MarkerSize',30);
        vmfig = figure(figNum + numel(DMAP));
        figure(figNum);

        set(figNum,'OuterPosition',[figNum*5, 20, 700, 700])
        hold off;
        if strcmp(MEMBERTYPE, 'TRAINMEMBER')
            uicontrol('Style', 'text', 'String', 'Training Data Results', 'Position', [20 40 150 20]);
        else %'TESTMEMBER'
            uicontrol('Style', 'text', 'String', 'Testing Data Results', 'Position', [20 40 150 20]);
        end
        children = determine_children(NODEPOINTERS, handleNum);
        set(figNum, 'name', strcat('Node number:', num2str(handleNum)));
        text(20, 20, strcat('Level: ', 'N/A'));
        uicontrol('Style', 'text', 'String', strcat('Level: ', 'N/A'), 'Position', [20 20 150 20]);

        classList = BuildClassList(children);
        
        printedCount = 0;
        printedCountHeatmaps = 0;
        classTallies = zeros(max(classList), 1);
        pitTruthTallies = zeros(2, 1);
        if strcmp(MEMBERTYPE, 'TRAINMEMBER')
            members = NODEPOINTERS.Node{handleNum, 1};
            dmap = TRAINDMAP;
            labels = TRAINLABELS;
            windows = TRAINWINDOWS;
            imgs = TRAINREFIMGS;
        else %'TESTMEMBER'
            members = NODEPOINTERS.Node{handleNum, 4};
            dmap = TESTDMAP;
            labels = TESTLABELS;
            windows = TESTWINDOWS;
            imgs = TESTREFIMGS;
        end
        % This seems like the place to do the varianceHeatMap calcs for the node...
        heatMaps = varianceHeatMaps(labels, dmap, windows, FRONTEND, VOCAB_SIZE, K, 'NOFIGS', datestr(now, 'mmm_dd_yyyy_HH_MM_SS_FFF'));
        
        allMembers = members;
        
        uicontrol('Style', 'pushbutton', 'String', 'Save To Disk', 'Position', [200 40 100 20], 'Callback', {@SaveNodeToDisk, handleNum, allMembers, classList, labels, windows, imgs, heatMaps});
        
        memberCount2 = numel(allMembers);
        
        if numel(classList) > 0
            bf = BRANCHINGFACTOR;
        else
            bf = 1; %this is a leaf node
            classList = ones(1, numel(DMAP));
        end
        for temp1 = 1:bf
            for temp2 = 1:K
                figure(figNum);
                members = allMembers(classList(allMembers)==temp1);
                members = members(labels(members)==temp2);
                memberCount = numel(members);
        
                for i = 1:numel(members)
                    memberNum = members(i);
                    img = imgs{memberNum};

                    img = img(SIFTBORDER+1:size(img, 1)-SIFTBORDER,SIFTBORDER+1:size(img, 2)-SIFTBORDER);
                    subplot_tight((ceil(sqrt(memberCount2))+1) + bf * K, ceil(memberCount2/sqrt(memberCount2)), printedCount+1, [0.01,0.01]);

                    h = subimage(img);
                    haxes1 = gca; % handle to axes

                    set(haxes1,'Xtick',[],'Ytick',[]); % use axes as nice black 1 pixel border
                    set(haxes1,'XTickLabel','');
                    set(haxes1,'YTickLabel','');

                    if numel(windows) > 0
                        color = 'b';
                        x = windows(memberNum,1);
                        y = windows(memberNum,2);
                        xb = windows(memberNum,3);
                        yb = windows(memberNum,4);
                        width = xb-x;
                        height = yb-y;
                        if ~(xb==size(img,1) && yb==size(img,2))
                            rectangle('Position',[x y width height], 'EdgeColor', color);
                        end
                    end

                    imgSize = size(img);
                    try
                        classNum = classList(memberNum);
                        classTallies(classNum) = classTallies(classNum) + 1;
                    catch
                        classNum = 0;
                    end
                    if labels(memberNum) == 1
                        groundTruth = 'pits';
                        pitTruthTallies(1) = pitTruthTallies(1) + 1;
                    else
                        groundTruth = 'no pits';
                        pitTruthTallies(2) = pitTruthTallies(2) + 1;
                    end
                    %text(imgSize(2)/3.5, imgSize(1)/6, groundTruth, 'color', 'b', 'FontSize', 10, 'HorizontalAlignment', 'center');
                    %text(imgSize(2)/4, imgSize(1)/6, strcat('L', num2str(labels(memberNum)), '-', char(64+classNum)), 'color', 'b', 'FontSize', 10, 'HorizontalAlignment', 'center');
                    printedCount = printedCount + 1;
                end
                purity = max(classTallies) / memberCount;
                pitPurity = max(pitTruthTallies(1), memberCount-pitTruthTallies(1)) / memberCount;
                %uicontrol('Style', 'text', 'String', strcat(' True Pit Purity: ', num2str(pitPurity)), 'Position', [20 80 150 20]);
                %uicontrol('Style', 'text', 'String', strcat(' Cluster Purity: ', num2str(purity)), 'Position', [20 60 150 20]);

                %print variance heat maps in separate figure
                figure(vmfig);

                hms = {};
                for i = 1:numel(members)
                    memberNum = members(i);
                    hm = log(heatMaps{labels(memberNum),memberNum});
                    hms = horzcat(hms, hm);
                end
                clMin = flintmax;
                clMax = -flintmax;
                for i = 1:numel(hms)
                    clMin = min(clMin, min(min(hms{i})));
                    clMax = max(clMax, max(max(hms{i})));
                end
                cl = [clMin, clMax];

                for i = 1:numel(members)
                    memberNum = members(i);
                    heatMap = heatMaps{labels(memberNum),memberNum};

                    subplot_tight((ceil(sqrt(memberCount2))+1) + bf * K, ceil(memberCount2/sqrt(memberCount2)), printedCountHeatmaps+1, [0.01,0.01]);

                    colormap(COLORMAP);

                    heatMap = log(heatMap);
                    imagesc(1:160,1:160,heatMap);
                    axis off;
                    caxis(cl) % apply the same color limits to all images
                    %if i==1
                    %   cb = colorbar('SouthOutside'); 
                    %end
                    if numel(windows) > 0
                        color = 'b';
                        x = windows(memberNum,1)*160/size(heatMap,2);
                        y = windows(memberNum,2)*160/size(heatMap,1);
                        xb = windows(memberNum,3)*160/size(heatMap,2);
                        yb = windows(memberNum,4)*160/size(heatMap,1);

                        width = xb-x;
                        height = yb-y;
                        if ~(floor(xb * size(heatMap,2)/160) ==size(img,1) && floor(yb * size(heatMap,2)/160)==size(img,2))
                            rectangle('Position',[x y width height], 'EdgeColor', color);
                        end
                    end
                    printedCountHeatmaps = printedCountHeatmaps + 1;
                end

                printedCount = printedCount+ ceil(memberCount2/sqrt(memberCount2)); %skip a row
                printedCountHeatmaps = printedCountHeatmaps+ ceil(memberCount2/sqrt(memberCount2)); %skip a row
            end
        end
    end
end


function [parentPointers] = GetParentPointers (tree, myNum, parent)
    parentPointers = [];
    children = determine_children(tree, myNum);
    
    parentPointers = [parentPointers; parent, myNum];
    
    for i = 1:numel(children)
        parentPointers = [parentPointers; GetParentPointers(tree, children(i), myNum)];
    end
end


%% callbacks
function ChangeTree (hObj,event) %#ok<INUSD>
    global TREEROOTS;
    global F1;
    global CURRTREE;
    val = get(hObj,'Value');
    
    %figures to keep
    figs2keep = [F1];
    delete(setdiff(findobj(0, 'type', 'figure'), figs2keep));

    CURRTREE = val;
    
    hold off;
    RenderTree(TREEROOTS{val});
end


function ChangeTrainTest (hObj,event) %#ok<INUSD>
    global TREEROOTS;
    global F1;
    global MEMBERTYPE;
    global CURRTREE;
    val = get(hObj,'Value');
    
    %figures to keep
    figs2keep = [F1];
    delete(setdiff(findobj(0, 'type', 'figure'), figs2keep));
    
    if val == 1
        MEMBERTYPE = 'TRAINMEMBER';
    else
        MEMBERTYPE = 'TESTMEMBER';
    end

    hold off;
    RenderTree(TREEROOTS{CURRTREE});
end

function SaveNodeToDisk (hObj, event, handleNum, allMembers, classList, labels, windows, imgs, heatMaps) %#ok<INUSD>
    global GUINODEHANDLES;
    global SIFTBORDER;
    global MEMBERTYPE;
    global K;
    global BRANCHINGFACTOR;
    global COLORMAP;
    global DMAP;
    
    set(GUINODEHANDLES(handleNum), 'userdata', 1);
    set(GUINODEHANDLES(handleNum), 'MarkerSize',30);
    
    if strcmp(MEMBERTYPE, 'TRAINMEMBER')
        trainTest = 'train';
    else
        trainTest = 'test';
    end

    if numel(classList) > 0
        bf = BRANCHINGFACTOR;
    else
        bf = 1; %this is a leaf node
        classList = ones(1, numel(DMAP));
    end
    for temp1 = 1:bf
        for temp2 = 1:K
            members = allMembers(classList(allMembers)==temp1);
            members = members(labels(members)==temp2);

            for i = 1:numel(members)
                memberNum = members(i);
                fileName = strcat('node_', num2str(handleNum), '_', trainTest, '_clust_', num2str(temp1), '_class_', num2str(temp2), '_img_', num2str(memberNum), '.fig');
                img = imgs{memberNum};
                img = img(SIFTBORDER+1:size(img, 1)-SIFTBORDER,SIFTBORDER+1:size(img, 2)-SIFTBORDER);

                h = figure(123456789);
                clf;

                imshow(img);
                
                set(gca,'Xtick',[],'Ytick',[]); % use axes as nice black 1 pixel border
                set(gca,'XTickLabel','');
                set(gca,'YTickLabel','');

                if numel(windows) > 0
                    color = 'b';
                    x = windows(memberNum,1);
                    y = windows(memberNum,2);
                    xb = windows(memberNum,3);
                    yb = windows(memberNum,4);
                    width = xb-x;
                    height = yb-y;
                    if ~(xb==size(img,1) && yb==size(img,2))
                        rectangle('Position',[x y width height], 'EdgeColor', color);
                    end
                end
                savefig(h, fileName);
                close(h);
            end

            hms = {};
            for i = 1:numel(members)
                memberNum = members(i);
                hm = log(heatMaps{labels(memberNum),memberNum});
                hms = horzcat(hms, hm);
            end
            clMin = flintmax;
            clMax = -flintmax;
            for i = 1:numel(hms)
                clMin = min(clMin, min(min(hms{i})));
                clMax = max(clMax, max(max(hms{i})));
            end
            cl = [clMin, clMax];

            for i = 1:numel(members)
                memberNum = members(i);
                fileName = strcat('node_', num2str(handleNum), '_', trainTest, '_clust_', num2str(temp1), '_class_', num2str(temp2), '_img_', num2str(memberNum), '_heatmap.fig');
                heatMap = heatMaps{labels(memberNum),memberNum};

                h = figure(123456789);
                clf;
                
                colormap(COLORMAP);

                heatMap = log(heatMap);
                imagesc(1:160,1:160,heatMap);
                axis off;
                caxis(cl) % apply the same color limits to all images
                if numel(windows) > 0
                    color = 'b';
                    x = windows(memberNum,1)*160/size(heatMap,2);
                    y = windows(memberNum,2)*160/size(heatMap,1);
                    xb = windows(memberNum,3)*160/size(heatMap,2);
                    yb = windows(memberNum,4)*160/size(heatMap,1);

                    width = xb-x;
                    height = yb-y;
                    if ~(floor(xb * size(heatMap,2)/160) ==size(img,1) && floor(yb * size(heatMap,2)/160)==size(img,2))
                        rectangle('Position',[x y width height], 'EdgeColor', color);
                    end
                end
                savefig(h, fileName);
                close(h);
            end
        end
    end
end
