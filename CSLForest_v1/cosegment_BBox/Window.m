classdef Window
    properties
        
        ul_x = -1;
        ul_y = -1;
        lr_x = -1;
        lr_y = -1;
       
    end

    methods
        
        %by Eli since constructor overloading sucks so much in matlab
        function [obj] = SetWindow (obj, ul_x, ul_y, lr_x, lr_y)
            obj.ul_x = ul_x;
            obj.ul_y = ul_y;
            obj.lr_x = lr_x;
            obj.lr_y = lr_y;
        end
        
        %by Eli
        function [pts] = AsArray (obj)
            pts = [obj.ul_x, obj.ul_y, obj.lr_x, obj.lr_y];
        end
        
        %by Eli
        function [pts] = XPoints (obj)
            pts = [obj.ul_x, obj.lr_x];
        end
        
        %by Eli
        function [pts] = YPoints (obj)
            pts = [obj.ul_y, obj.lr_y];
        end
        
        %by Eli
        function [obj] = SetFromArray (obj, pts)
            obj.ul_x = pts(1);
            obj.ul_y = pts(2);
            obj.lr_x = pts(3);
            obj.lr_y = pts(4);
        end

        %Code added by Ashok for Pyramid Histograms
        function [tl, tr, bl, br] = QuadSplit (obj)
            tl = obj.copy();
            tr = obj.copy();
            bl = obj.copy();
            br = obj.copy();
            if obj.ul_x < 1 || obj.ul_y < 1 || obj.lr_x < 1 || obj.lr_y < 1
                return;
            end
            x1 = round((obj.ul_x + obj.lr_x)/2);
            y1 = round((obj.ul_y + obj.lr_y)/2);
            %x2 = 0;
            %y2 = 0;
            if obj.ul_x < obj.lr_x
                x2 = x1 + 1;
            else
                x2 = x1;
            end
            if obj.ul_y < obj.lr_y
                y2 = y1 + 1;
            else
                y2 = y1;
            end
            tl.lr_x = x1;
            tl.lr_y = y1;
            tr.ul_x = x2;
            tr.lr_y = y1;
            bl.ul_y = y2;
            bl.lr_x = x1;
            br.ul_x = x2;
            br.ul_y = y2;
        end

        function [FinalHist] = getPyrHist (obj, integralIms, nHistBin, K, PYR_LEVELS)
            %import java.util.LinkedList;
            %HistQ = LinkedList();
            %fprintf('--start\n');

            HistQ = QueueHack();
            %maxLengthNeeded = 0;
            %for i = 1:PYR_LEVELS
            %    maxLengthNeeded = maxLengthNeeded + 4^i;
            %end
            CurrQ = QueueHack();
            CurrQ.add(obj);
            NxtQ = QueueHack();

            for lvl = 1:PYR_LEVELS
                %Elapsed time is 0.000185 seconds.
                %Elapsed time is 0.001098 seconds.
                %Elapsed time is 0.000209 seconds.
                while CurrQ.size() > 0
                    %fprintf('----sub\n');
                    %Elapsed time is 0.000064 seconds.
                    %Elapsed time is 0.000160 seconds.
                    %Elapsed time is 0.000432 seconds.
                    %Elapsed time is 0.000002 seconds.
                    %Elapsed time is 0.000216 seconds.
                    %get the front window and pop it
                    w = CurrQ.remove();
                    %get the histogram
                    HistQ.add(w.getHist(integralIms, nHistBin, K));
                    %split it into 4 peices and save the windows to the NxtQ
                    %[tl, tr, bl, br] = w.QuadSplit();
                    %-------------
                    tl = w.copy();
                    tr = w.copy();
                    bl = w.copy();
                    br = w.copy();
                    if ~(w.ul_x < 1 || w.ul_y < 1 || w.lr_x < 1 || w.lr_y < 1)
                        x1 = round((w.ul_x + w.lr_x)/2);
                        y1 = round((w.ul_y + w.lr_y)/2);
                        %x2 = 0;
                        %y2 = 0;
                        if w.ul_x < w.lr_x
                            x2 = x1 + 1;
                        else
                            x2 = x1;
                        end
                        if w.ul_y < w.lr_y
                            y2 = y1 + 1;
                        else
                            y2 = y1;
                        end
                        tl.lr_x = x1;
                        tl.lr_y = y1;
                        tr.ul_x = x2;
                        tr.lr_y = y1;
                        bl.ul_y = y2;
                        bl.lr_x = x1;
                        br.ul_x = x2;
                        br.ul_y = y2;
                    end
                    %-------------
                    NxtQ.add(tl);
                    NxtQ.add(tr);
                    NxtQ.add(bl);
                    NxtQ.add(br);
                    %fprintf('----/sub\n');
                end
                CurrQ = NxtQ;
                NxtQ = QueueHack();
            end
            
            FinalHist = zeros(HistQ.size()*nHistBin*K,1);
            %fprintf('[%d,%d,%d,%d]-->|\n',obj.ul_x,obj.ul_y,obj.lr_x,obj.lr_y);
            for i = 0:HistQ.size()-1
                hist = HistQ.remove();
                for j = 1:nHistBin*K
                    FinalHist(i*nHistBin*K + j) = hist(j);
                    %if FinalHist(i*nHistBin*K + j) ~= 0 && i*nHistBin*K + j < 50
                    %	fprintf('%d,',FinalHist(i*nHistBin*K + j));
                    %end
                end
            end

            %fprintf('--end\n');
            %fprintf('\n');
        end

        function [hist] = getHist (obj, integralIms, nHistBin, K)
            hist = zeros(nHistBin*K,1);
            if obj.ul_x > -1
                if (obj.ul_x > 1) && (obj.ul_y > 1)
                    %temp = integralIms(obj.lr_y,obj.lr_x,:,1) + integralIms(obj.ul_y-1,obj.ul_x-1,:,1) - integralIms(obj.lr_y,obj.ul_x-1,:,1) - integralIms(obj.ul_y-1,obj.lr_x,:,1);
                    for k = 1:nHistBin
                        for kk = 0:K-1
                            hist(kk*nHistBin + k) = integralIms(obj.lr_y,obj.lr_x,k,1) + integralIms(obj.ul_y-1,obj.ul_x-1,k,1) - integralIms(obj.lr_y,obj.ul_x-1,k,1) - integralIms(obj.ul_y-1,obj.lr_x,k,1);
                        end
                    end
                elseif (obj.ul_x > 1)
                    %temp = integralIms(obj.lr_y,obj.lr_x,:,1) - integralIms(obj.lr_y,obj.ul_x-1,:,1);
                    for k = 1:nHistBin
                        for kk = 0:K-1
                            hist(kk*nHistBin + k) = integralIms(obj.lr_y,obj.lr_x,k,1) - integralIms(obj.lr_y,obj.ul_x-1,k,1);
                        end
                    end
                elseif (obj.ul_y > 1)
                    %temp = integralIms(obj.lr_y,obj.lr_x,:,1) - integralIms(obj.ul_y-1,obj.lr_x,:,1);
                    for k = 1:nHistBin
                        for kk = 0:K-1
                            hist(kk*nHistBin + k) = integralIms(obj.lr_y,obj.lr_x,k,1) - integralIms(obj.ul_y-1,obj.lr_x,k,1);
                        end
                    end
                else
                    for k = 1:nHistBin
                        for kk = 0:K-1
                            hist(kk*nHistBin + k) = integralIms(obj.lr_y,obj.lr_x,k,1);
                        end
                    end
                end
            end
        end
            
%         function [result] = getHist (obj, integralIms, nHistBin, K, winRes)
%             newWin = Window(obj.ul_x*winRes.x, obj.ul_y*winRes.y, obj.lr_x*winRes.x, obj.lr_y*winRes.y);
%             result = newWin.getPyrHist(integralIms, nHistBin, K);
%         end
        
        function [result] = getMaxDim (obj)
            result = max(obj.lr_x - obj.ul_x, obj.lr_y - obj.ul_y);
        end
        
        function [newWin] = copy (obj)
            newWin = Window();
            newWin.lr_x = obj.lr_x;
            newWin.lr_y = obj.lr_y;
            newWin.ul_x = obj.ul_x;
            newWin.ul_y = obj.ul_y;
        end

        function [left, right] = split (obj)
            if obj.lr_x - obj.ul_x >= obj.lr_y - obj.ul_y %split along horizontal dim
                x1 = floor((obj.ul_x + obj.lr_x)/2);
                x2 = x1 + 1;
                left = obj.copy();
                left.lr_x = x1;
                right = obj.copy();
                right.ul_x = x2;
            else
                y1 = floor((obj.ul_y + obj.lr_y)/2);
                y2 = y1+1;
                left = obj.copy();
                left.lr_y = y1;
                right = obj.copy();
                right.ul_y = y2;
            end
        end

        function [result] = isEqual (obj, win)
            result = ((obj.ul_x == win.ul_x) && (obj.ul_y == win.ul_y) && (obj.lr_x == win.lr_x) && (obj.lr_y == win.lr_y));
        end
        
        function [rslt] = getSubWin (obj, x, y, xDev, yDev)
            rslt = Window();
            rslt.ul_x = obj.ul_x + ceil((obj.lr_x - obj.ul_x + 1)*(x-1)/xDev);
            rslt.lr_x = obj.ul_x + ceil((obj.lr_x - obj.ul_x + 1)*x/xDev) - 1;

            rslt.ul_y = obj.ul_y + ceil((obj.lr_y - obj.ul_y + 1)*(y-1)/yDev);
            rslt.lr_y = obj.ul_y + ceil((obj.lr_y - obj.ul_y + 1)*y/yDev) - 1;
            if (rslt.ul_x > rslt.lr_x) || (rslt.ul_y > rslt.lr_y)
                rslt = Window();
            end
        end

    end
end