function [linGrid,gridSize,xx,yy,zz] = prtPlotUtilGenerateGrid(plotMins, plotMaxs, nSamplesPerDim, includePoints)
% [linGrid,gridSize,xx,yy,zz] = prtPlotUtilGenerateGrid(plotMins, plotMaxs, nSamplesPerDim, includePoints)
% Internal function, 
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


yy = [];
zz = [];

nDims = length(plotMins);

if ~isnumeric(nSamplesPerDim)
    try
        nSamplesPerDim = nSamplesPerDim.nSamplesPerDim;
    catch  %#ok<CTCH>
        error('prt:prtPlotUtilGenerateGrid','Invalid nSamplesPerDim input');
    end
end

xx = linspace(plotMins(1),plotMaxs(1),nSamplesPerDim(nDims));
if nargin > 3 && ~isempty(includePoints)
    xx = cat(2,xx,includePoints(:,1)');
    xx = sort(xx,'ascend');
end

if nDims > 1
    yy = linspace(plotMins(2),plotMaxs(2),nSamplesPerDim(nDims));
    if nargin > 3 && ~isempty(includePoints)
        yy = cat(2,yy,includePoints(:,2)');
        yy = sort(yy,'ascend');
    end
end

if nDims > 2
    zz = linspace(plotMins(3),plotMaxs(3),nSamplesPerDim(nDims));
    if nargin > 3 && ~isempty(includePoints)
        zz = cat(2,zz,includePoints(:,3)');
        zz = sort(zz,'ascend');
    end
end

switch nDims
     case 1
        linGrid = xx(:);
        gridSize = size(xx);
        yy = ones(size(xx));
    case 2
        [xx,yy] = meshgrid(xx,yy);
        linGrid = [xx(:),yy(:)];
        gridSize = size(xx);
    case 3
        [xx,yy,zz] = meshgrid(xx,yy,zz);
        gridSize = size(xx);
        linGrid = [xx(:), yy(:), zz(:)];
end
