function [bestBB] = findBox1a (imAssign, imH, imW, imC, hist_target, weights, nHistBin, K, C, tolFactor, knownBest, Mu, S, FlexWin, PYR_LEVELS)
    integralIms = cmpIntegralIms(imAssign, imH, imW, imC, nHistBin);
    biggestWin = Window();
    biggestWin = biggestWin.SetWindow(1, 1, imW, imH);
    rootNode = TreeNode1a(WindowPair(biggestWin, biggestWin));

    global FG_Prior_Mu; FG_Prior_Mu = Mu;
    global FG_Prior_S; FG_Prior_S = S;
    global ImgDimX; ImgDimX = imW;
    global ImgDimY; ImgDimY = imH;
    global isWinFlexible; isWinFlexible = FlexWin;

    bestBB = findBox1a_helper(integralIms, rootNode, hist_target, weights, nHistBin, K, C, tolFactor, knownBest, PYR_LEVELS);
end

function [win] = findBox1a_helper (integralIms, rootNode, hist_target, binWeights, nHistBin, K, C, tolFactor, knownBest, PYR_LEVELS)
    bestNode = m_branch_bound(rootNode, tolFactor, integralIms, hist_target, binWeights, PYR_LEVELS, C, K, nHistBin);
    %fprintf('-->\n');
    win = bestNode.winPair.getLargestWin();
    %fprintf('<--\n');
end

function [integralIms] = cmpIntegralIms (im, imH, imW, imC, nHistBin)
    integralIms = zeros(imH, imW, nHistBin);

    integralIms(1,1,im(1,1,1)) = 1;
    for j = 2:imW
        for u = 1:nHistBin
            integralIms(1,j,u) = integralIms(1,j-1,u);
        end
        integralIms(1,j,im(1,j,1)) = integralIms(1,j,im(1,j,1)) + 1;
    end

    for i = 2:imH
        for u = 1:nHistBin
            integralIms(i,1,u) = integralIms(i-1,1,u);
        end
        integralIms(i,1,im(i,1,1)) = integralIms(i,1,im(i,1,1)) + 1;
    end

    for i = 2:imH
        for j = 2:imW
            for k = 1:nHistBin
                integralIms(i,j,k) = integralIms(i,j-1,k) + integralIms(i-1,j,k) - integralIms(i-1,j-1,k);
            end
            integralIms(i,j,im(i,j,1)) = integralIms(i,j,im(i,j,1)) + 1;
        end
    end
end