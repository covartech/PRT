function colors = prtPlotUtilClassColorsBW(nClasses)
% Internal function, default color specs.
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



% colors = [55  126 184; % Blue
%           228 26  28;  % Red
%           77  175 74;  % Green
%           255 127 0;   % Orange
%           153 153 153; % Gray
%           166 86  40;  % Brown
%           152 78  163; % Purple
%           255 255 51;  % Yello
%           247 129 191; % Pink
%           ]/255;

%255, 255, 191;
colors = [215,  25,  28;
          253, 174,  97;
          171, 221, 164;
           43, 131, 186;]/255;


% colors = gray(5);
% colors = colors(1:4,:);


colorMapInd = repmat((1:size(colors,1))',ceil(nClasses/size(colors,1)),1);
colorMapInd = colorMapInd(1:nClasses);

colors = colors(colorMapInd,:);
