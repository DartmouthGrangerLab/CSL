function [bestNode] = m_branch_bound (rootNode, tolFac, integralIms, hist_target, binWeights, PYR_LEVELS, C, K, nHistBin)
    hist_target = floor(hist_target); %mex code used ints
    myQ = PriorityQueue(logical(0));
    rootNode = rootNode.cmpBnds(integralIms, hist_target, binWeights, PYR_LEVELS, C, K, nHistBin);
    bestUb = rootNode.ub;
    myQ.add(rootNode.lb, rootNode);
    bestNode = rootNode;
    itr = 0;

    while (1)
        itr = itr + 1;
        if (myQ.size() == 0)
            break;
        end
        [priority, topNode] = myQ.pop();

        if (isWithinTolFactor(bestUb, topNode.lb, tolFac))
            break;
        end
        if (itr > 100000)
            break;
        end

        [leftWinPair, rightWinPair] = topNode.split();

        left = TreeNode1a(leftWinPair);
        right = TreeNode1a(rightWinPair);

        left = left.cmpBnds(integralIms, hist_target, binWeights, PYR_LEVELS, C, K, nHistBin);
        right = right.cmpBnds(integralIms, hist_target, binWeights, PYR_LEVELS, C, K, nHistBin);
        
        if ~isWithinTolFactor(bestUb, left.lb, tolFac)
            myQ.add(left.lb, left);
            newUb = left.ub;
            if (bestUb > newUb)
                bestUb = newUb;
                bestNode = left;
            end
        end
        
        if ~isWithinTolFactor(bestUb, right.lb, tolFac)
            myQ.add(right.lb, right);
            newUb = right.ub;
            if (bestUb > newUb)
                bestUb = newUb;
                bestNode = right;
            end
        end
    end
end

function [result] = isWithinTolFactor(bestUb, lb, tolFactor)
    if (bestUb - lb) <= tolFactor*abs(bestUb)
        result = 1;
    else
        result = 0;
    end
end
