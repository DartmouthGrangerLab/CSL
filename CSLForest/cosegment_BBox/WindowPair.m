classdef WindowPair
    properties
        win1;
        win2;
    end
    
    methods
        function [obj] = WindowPair(win1_, win2_)
            obj.win1 = win1_;
            obj.win2 = win2_;
        end
        
        %does NOT do what the function name suggests
        function [result] = getSmallestWin (obj)
            result = Window();
            if (obj.win1.lr_x < obj.win2.ul_x) && (obj.win1.lr_y < obj.win2.ul_y)
                result = result.SetWindow(obj.win1.lr_x, obj.win1.lr_y, obj.win2.ul_x, obj.win2.ul_y);
            end
        end

        %does NOT do what the function name suggests
        function [result] = getLargestWin (obj)
            result = Window();
            if (obj.win1.ul_x <= obj.win2.lr_x) && (obj.win1.ul_y <= obj.win2.lr_y)
                result = result.SetWindow(obj.win1.ul_x, obj.win1.ul_y, obj.win2.lr_x, obj.win2.lr_y);
            %else
            %    w1 = obj.win1.AsArray();
            %    w2 = obj.win2.AsArray();
            %    fprintf('oh noes windowpair! considered [%d,%d,%d,%d], [%d,%d,%d,%d]\n',w1(1),w1(2),w1(3),w1(4),w2(1),w2(2),w2(3),w2(4));
            end
        end

%         function [result] = getRandomWin (obj)
%            rUL_x = getRandNum(win1.ul_x, win1.lr_x);
%            rUL_y = getRandNum(win1.ul_y, win1.lr_y);
%            rLR_x = getRandNum(win2.ul_x, win2.lr_x);
%            rLR_y = getRandNum(win2.ul_y, win2.lr_y);
%            if (rUL_x <= rLR_x) && (rUL_y <= rLR_y)
%               result = Window(rUL_x, rUL_y, rLR_x, rLR_y);
%            else
%               result = getLargestWin();
%            end
%         end
% 
%         function [result] = getRandNum (minNum, maxNum)
%            srand((unsigned int)time(0));
%            result = mod(rand(), (maxNum + 1- minNum)) + minNum;
%         end
        
        function [rslt] = getSubWinPair (obj, x, y, xDev, yDev)
           rslt = WindowPair(Window(), Window());
           w1 = Window();
           w2 = Window();
           w1 = w1.SetWindow(obj.win1.ul_x, obj.win1.ul_y, obj.win2.ul_x, obj.win2.ul_y);
           w2 = w2.SetWindow(obj.win1.lr_x, obj.win1.lr_y, obj.win2.lr_x, obj.win2.lr_y);
           w1 = w1.getSubWin(x, y, xDev, yDev);
           w2 = w2.getSubWin(x, y, xDev, yDev);

           rslt.win1 = rslt.win1.SetWindow(w1.ul_x, w1.ul_y, w2.ul_x, w2.ul_y);
           rslt.win2 = rslt.win2.SetWindow(w1.lr_x, w1.lr_y, w2.lr_x, w2.lr_y);
        end
        
        function [left, right] = split (obj)
            if obj.win1.getMaxDim() > obj.win2.getMaxDim() %split the first rectangle
                [lwin, rwin] = obj.win1.split();
                left = WindowPair(lwin, obj.win2);
                right = WindowPair(rwin, obj.win2);
            else
                [lwin, rwin] = obj.win2.split();
                left = WindowPair(obj.win1, lwin);
                right = WindowPair(obj.win1, rwin);
            end
        end
	end
end