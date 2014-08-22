function [MM,JJ] = prtUtilGetSubplotDimensions(nPlots)
%[MM,JJ] = prtUtilGetSubplotDimensions(nPlots);
% xxx Need Help xxx

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.


if nPlots <= 3
    MM = nPlots;
    JJ = 1;
elseif nPlots == 4
    MM = 2;
    JJ = 2;
elseif nPlots <= 6
    MM = 2;
    JJ = 3;
elseif nPlots <= 8
    MM = 2;
    JJ = 4;
elseif nPlots <= 9
    MM = 3;
    JJ = 3;
else
    % make the best rectangle we can
    root = ceil(sqrt(nPlots));
    for i = root:-1:1;
        if root*(i-1) < nPlots;
            MM = i;
            JJ = root;
            return;
        end
    end
end
% elseif nPlots <= 12
%     MM = 3;
%     JJ = 4;
% elseif nPlots <= 15
%     MM = 5;
%     JJ = 3;    
% elseif nPlots <= 16
%     MM = 4;
%     JJ = 4; 
% elseif nPlots <= 25
%     MM = 5;
%     JJ = 5; 
% elseif nPlots <= 36
%     MM = 6;
%     JJ = 6;
% elseif nPlots <= 45
%     MM = 9;
%     JJ = 5;
% elseif nPlots <= 50
%     MM = 10;
%     JJ = 5;
% elseif nPlots <= 100
%     MM = 10;
%     JJ = 10;
% elseif nPlots <= 200
%     MM = 10;
%     JJ = 20;
% else 
%     warning('Nplots too large');
%     MM = inf;
%     JJ = inf;
% end
   
    
    
