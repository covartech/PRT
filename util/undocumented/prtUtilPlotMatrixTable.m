function varargout = prtUtilPlotMatrixTable(X,cLim,cMap,num2strFormat,textCMap)
% prtUtilPlotMatrixTable displays a matrix as a table. The table is actually an
%   image with lines between each pixel.
%
% Syntax: [axesHandle, textHandles, verticleLineHandles, horizontalLineHandles]
%           = prtUtilPlotMatrixTable(X,cLim,cMap,num2strFormat,textCMap)
%
% Inputs:
%   X - 2-D Matrix to plot
%   cLim - The limits for image scaling default = [min(X(:)), max(X(:))]
%   cMap - The colormap for image default = gray;
%   num2strFormat - The string format for each matrix element 
%       default = '%.2f'
%   textCMap - The colorMap to use for the text Color.
%       default - [cMap(end,:); cMap(1,:)];
%           If cMap has only 1 color the default = 1-cMap.
%
% Outputs: These names are all fairly descriptive
%   axesHandle
%   textHandles
%   verticleLineHandles
%   horizontalLineHandles
%
% Example:
%   prtUtilPlotMatrixTable(rand(5),[0 1],summer(128),'%.2f',[0 0 0])
%   prtUtilPlotMatrixTable(rand(5),[0 1],summer(128),'%.2f')
%   prtUtilPlotMatrixTable(rand(5),[0 1],[1 1 1],[],[0 0 0])
%
% Other m-files required: none
% Subfunctions: getBestFontSize
% MAT-files required: none
%
% See also: plotConfusionMatrix.m

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




if nargin < 2 || isempty(cLim)
    cLim = [min(X(:)) max(X(:))];
end

if nargin < 3 || isempty(cMap)
    cMap = gray;
end

if nargin < 4 || isempty(num2strFormat)
    num2strFormat = [];
end

if nargin < 5 || isempty(textCMap)
    if size(cMap,1) == 1;
        textCMap = 1-cMap;
    else
        textCMap = [cMap(end,:); cMap(1,:)];
    end
end

[nRows, nCols] = size(X);

imageAxes = gca;
imagesc(X,cLim);
colormap(cMap);
fontSize = max(getBestFontSize(imageAxes),1);
textHandles = nan(size(X));
verticleLineHandles = zeros(nRows,1);
horizontalLineHandles = zeros(nCols,1);
hold on;

[dontNeed, textCMapInds] = histc( (X-cLim(1))./(cLim(2)-cLim(1)) , linspace(0,1+eps,size(textCMap,1)+1)); %#ok<ASGLU>
textCMapInds(textCMapInds==0 | ~isfinite(textCMapInds)) = size(textCMap,1);
textCMapInds(textCMapInds==0 | ~isfinite(textCMapInds)) = 1;

for iRow = 1:nRows
    for jCol = 1:nCols
        cNum = X(iRow,jCol);

        cTextColor = textCMap(textCMapInds(iRow,jCol),:);
        
        cTextString = num2str(cNum,num2strFormat);
            
        % Some decimal place pruning
        done = false;
        while ~done
            if length(cTextString) > 1 && strcmpi(cTextString(end),'0') && any(cTextString == '.')
                cTextString(end) = [];
            else
                done = true;
            end
        end
        % Remove last decimal if necessary
        if strcmpi(cTextString(end),'.')
            cTextString(end) = [];
        end
        
        textHandles(iRow,jCol) = text(jCol,iRow,cTextString,...
            'color',cTextColor,'horizontalAlignment','center',...
            'fontsize',fontSize,'clipping','on','visible','on');
        
        if iRow == 1
            horizontalLineHandles(jCol) = plot([jCol jCol]+0.5,[0.5 0.5+nRows],'k','linewidth',1);
        end
    end
    verticleLineHandles(iRow) = plot([0.5 0.5+nCols],[iRow, iRow]+0.5,'k','linewidth',1);
end
hold off;

set(imageAxes,'YTick',1:nRows,'XTick',1:nCols,...
    'XTickLabel',num2str((1:nCols)'),'YTickLabel',num2str((1:nRows)'),...
    'Xlim',[0.5 nCols+0.5],'Ylim',[0.5 nRows+0.5],...
    'TickLength',[0 0]);

varargout = {};
if nargout > 0 
    varargout = {imageAxes, textHandles, verticleLineHandles, horizontalLineHandles};
end

f = ancestor(imageAxes,'figure');
set(f,'ResizeFcn',@(src,evt)setBestFontSize(imageAxes,textHandles));
setBestFontSize(imageAxes,textHandles);

function setBestFontSize(imAxes,textHandles)

if ~ishandle(imAxes)
    return
end
try
    fs = getBestFontSize(imAxes);
catch %#ok<CTCH>
    return
end

for iHandle = 1:numel(textHandles)
    if ishandle(textHandles(iHandle))
        if fs > 0
            set(textHandles(iHandle),'FontSize',fs);
            set(textHandles(iHandle),'visible','on');
        else
            set(textHandles(iHandle),'visible','off');
        end
    end
end
    

function fs = getBestFontSize(imAxes)
% I found this little gem in a MATLAB central file heatmaptext.m
% This should solve alot of our problems with this function
% It adjusts the font size relative to the number of col and rows.
%
% 31-Jan-2008 - I have modified this so it checks the extent of the axes
% instead of the figure. This allows the fontsize to change relative to a
% subplot. - KDM
%
% 17-May-2011 - I have modified this to check the minimumum of both ratios
% so that resized plots look good. Also added a listener above so that the
% resize will call this function again.
% 
% 
% Apparently this is copyright the MathWorks as is stated in the funciton.
%
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=15877&objectType=file#
%

% Try to keep font size reasonable for text
nrows = diff(get(imAxes,'YLim'));
ncols = diff(get(imAxes,'XLim'));

set(imAxes,'units','pixels');
extent = get(imAxes,'Position');
set(imAxes,'units','normalized');
ratioNum = extent(3:4);

magicNumber = 80;
if ncols < magicNumber && nrows < magicNumber
    ratio = min(ratioNum./[nrows,ncols]);
elseif ncols < magicNumber
    ratio = ratioNum(2)/ncols;
elseif nrows < magicNumber
    ratio = ratioNum(1)/nrows;
else
    ratio = 1;
end

%fs = min(maxFontSize,ceil(ratio/4));    % the gold formula
fs = ceil(ratio/4);
if fs < 4 % Font sizes less than 4 still look like crap
    fs = 0;
end
