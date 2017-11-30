% This code was written by Richard Granger's Brain Engineering Laboratory at Dartmouth.
% Contributors: Ashok Chandrashekar (originator), Richard Granger, Brett Tofel, Elijah FW Bowen, Kevin Kenneally, Richard Addo
% Anyone is free to use this code. When using this code, you must cite:
% 1)  CSL [Computer software]. Retrieved from GitHub: https://github.com/DartmouthGrangerLab/CSL
% 2)  Chandrashekar, A., & Granger, R. (2012). Derivation of a novel efficient supervised learning algorithm from cortical-subcortical loops. Frontiers in computational neuroscience, 5, 50.
%        available from: http://www.frontiersin.org/computational_neuroscience/10.3389/fncom.2011.00050/abstract
% 3)  Bowen, E. F. W., Tofel, B. B., Parcak, S., & Granger, R. (2017). Algorithmic Identification of Looted Archaeological Sites from Space. Frontiers in ICT, 4, 4.
%        available from: http://journal.frontiersin.org/article/10.3389/fict.2017.00004/abstract
function [] = DetermineVocabData (rstream)
    global N_VOCAB_PER_CAT;
    global ResourcePath;
    global CatFile;
    global ImgPath;

    CatDirs = importdata(strcat(ResourcePath, CatFile), ' ');
    VocabFileList = cell(numel(CatDirs), N_VOCAB_PER_CAT);
    % determine file count for each category
    for nDir = 1:numel(CatDirs)
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
        FileList = randperm(rstream, numel(DirEntries));
        
        for j = 1:N_VOCAB_PER_CAT
            VocabFileList(nDir,j) = cellstr(DirEntries(FileList(j)).name);
        end
    end

    WriteCellMatToFile(strcat(ResourcePath, 'VocabFileList'), VocabFileList);
end
