function [linGrid,gridSize,xx,yy,zz] = prtPlotUtilGenerateGrid(plotMins, plotMaxs, nSamplesPerDim, includePoints)
% [linGrid,gridSize,xx,yy,zz] = prtPlotUtilGenerateGrid(plotMins, plotMaxs, nSamplesPerDim, includePoints)
% Internal function, 
% xxx Need Help xxx







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
