function cMap = prtPlotUtilTwoClassColorMap(n,colors)
% cMap = prtPlotUtilTwoClassColorMap(n=256)
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


if nargin < 1 || isempty(n)
    n = 256;
end

if nargin < 2 || isempty(colors)
    plotOptions = prtOptionsGet('prtOptionsDataSetClassPlot');
    colors = feval(plotOptions.colorsFunction,2);
end

% Lighten the colors
colors = prtPlotUtilLightenColors(colors);

cMap1 = prtPlotUtilLinspaceColormap(colors(1,:),[1 1 1],floor(n/2));
cMap2 = prtPlotUtilLinspaceColormap([1 1 1],colors(2,:),ceil(n/2));

cMap = cat(1,cMap1,cMap2);
