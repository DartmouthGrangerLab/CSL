% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [ImgLinks,Labels] = LoadImages(N_CATS, filesPerCat, rstream, imageExclusions)
    global ResourcePath
    global CatFile
    global ImgPath
    
    ImgLinks = [];
    Labels = [];
    PrevImgCnt = 0;
    
    [CatDirs] = importdata(strcat(ResourcePath, CatFile), ' ');
    for nDir = 1:min(N_CATS, numel(CatDirs))
        CatImgDir = strcat(ImgPath, char(CatDirs(nDir)));
        DirEntries = dir(strcat(CatImgDir, '/*.pgm'));
        if numel(DirEntries) == 0
            DirEntries = dir(strcat(CatImgDir, '/*.jpg'));
            DirEntries = [DirEntries; dir(strcat(CatImgDir, '/*.JPG'))];
            DirEntries = [DirEntries; dir(strcat(CatImgDir, '/*.jpeg'))];
            DirEntries = [DirEntries; dir(strcat(CatImgDir, '/*.JPEG'))];
        end
        if numel(DirEntries) == 0
            DirEntries = dir(strcat(CatImgDir, '/*.tif'));
        end
        
        index = randperm(rstream, numel(DirEntries));
        DirEntries = DirEntries(index);
        
        images = {};
        for i = 1:numel(DirEntries)
            tempImage = strcat(CatImgDir, '/', cellstr(DirEntries(i).name));
            for j = 1:numel(imageExclusions)
                %next line means "if imageExclusions{j}==tempImage"
                if numel(char(imageExclusions{j})) == numel(char(tempImage)) && sum(char(imageExclusions{j}) == char(tempImage)) == numel(char(tempImage))
                    tempImage = {};
                    break
                end
            end
            if numel(tempImage) > 0
                images{numel(images)+1} = tempImage;
            end
        end
        
        nFile = 1;
        while nFile <= filesPerCat(nDir) && nFile <= numel(images)
            ImgLinks{nFile + PrevImgCnt} = images{nFile};
            Labels(nFile + PrevImgCnt) = nDir;
            nFile = nFile+1;
        end
        PrevImgCnt = PrevImgCnt + min(filesPerCat(nDir), numel(DirEntries));
    end
end