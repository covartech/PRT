function varargout = prtPlotUtilSetLineProperties(lineHandles, labels, varargin)
% prtPlotUtilSetLineProperties(lineHandles, labels, varargin)
%   Change the properties of an array of lineHandles according to the
%   specified labels.
%
% lineHandles: 
%   An Nx1 array of lineHandles
%
% labels:
%   An NxM array of labels
%   These labels are used to determine which properties are used for the
%   lines. The columns are linked to the line properties determined by
%   "styleOrder" (see below).
%
% Additional inputs can be specified as string value pairs (or as an
% options structure).
%
% styleOrder:
%   An array of chars that specifies the order to change the line
%   properties. The following chars can be specified:
%       c - color
%       m - marker
%       f - marker face color
%       e - marker edge color 
%       l - line style
%       w - line width
%       s - marker size
%   The default value is 'cml' specifying to change color then marker then
%       line style.
%
% colors:
%   - an Nx3 color matrix or
%   - a function handle that accepts a scalar integer (N) and returns an
%       Nx3 color matrix
%   The default is @prtPlotUtilClassColors.
%
% markerFaceColors:
%   - an Nx3 color matrix or
%   - a function handle that accepts a scalar integer (N) and returns an
%       Nx3 color matrix
%   - Empty, in which case markerFaceColors are the same as colors
%   The default is [].
%
% markerEdgeColors:
%   - an Nx3 color matrix or
%   - a function handle that accepts a scalar integer (N) and returns an
%       Nx3 color matrix
%   - Empty, in which case markerEdgeColors are the same as colors mapped
%     through the function specified in markerEdgeColorModificationFunction
%   The default is [].
%
% markers:
%   - an 1xN char array of valid marker specifications or 
%   - an 1xN cell array of chars of valid marker specifications or
%   - a function handle that accepts a scalar integer (N) and returns an 
%       1xN char array of valid marker specifications or an 1xN cell array
%       of chars of valid marker specifications
%   The default is @prtPlotUtilClassSymbols.
%
% lineStyles:
%   - an 1xN cell array of chars of valid lineStyle specifications
%   The default is {'-','--',':','-.'}.
%
% markerSizes:
%   - an 1xN integer array of marker sizes
%   The default is [4 8 10 12].
%
% lineWidths:
%   - an 1xN integer array of line widths
%   The default is [1 2 3].
%
%
% Example: (See m-file)
%{

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
X = randn(8,25);

Y = [0 0 0;
     0 0 1;
     0 1 0;
     0 1 1;
     1 0 0;
     1 0 1;
     1 1 0;
     1 1 1;];

lineHandles = plot(X'); 

prtPlotUtilSetLineProperties(lineHandles, Y,'markerSizes',[4 12],'markers',{'p','hexagram'},'lineStyles',{'none'},'colors',[0 0 0],'markerEdgeColors',[1 0 0;0 0 1],'styleOrder','sclmf');
%}

% Set default properties and parse with input parser.
options.styleOrder = 'cm';
options.colors = @prtPlotUtilClassColors;
options.markerFaceColors = []; % If empty, tied to colors
options.markerEdgeColors = []; % If empty, tied to markerFaceColor using markerEdgeColorModifer
options.markers = @prtPlotUtilClassSymbols;
options.lineStyles = {'-','--',':','-.'};
options.markerSizes = [4 8 10 12];
options.lineWidths = [1 2 3];
options.markerEdgeColorModificationFunction = @prtPlotUtilLightenColors;
options.legendStrings = {};

parser = inputParser;
parser.CaseSensitive = false;
parser.FunctionName = 'prtPlotUtilSetLineProperties';
parser.StructExpand = true;

addParamValue(parser,'styleOrder',options.styleOrder, @(s)ischar(s) && all(ismember(s,'cmfelws')))
addParamValue(parser,'colors',options.colors, @(s)((isnumeric(s) && size(s,2)==3) || isa(s,'function_handle')));
addParamValue(parser,'markerFaceColors',options.markerFaceColors, @(s)(isempty(s) || (isnumeric(s) && size(s,2)==3) || isa(s,'function_handle')));
addParamValue(parser,'markerEdgeColors',options.markerEdgeColors, @(s)(isempty(s) || (isnumeric(s) && size(s,2)==3) || isa(s,'function_handle')));
addParamValue(parser,'markers',options.markers, @(s)((iscell(s) && all(cellfun(@(s2)ismember(s2,{'none','+','o','*','.','x','s','square','d','diamond','^','v','<','>','p','pentagram','h','hexagram'}),s)) || (ischar(s) && (all(ismember(s,'+o*.xsd^v><ph')))) || isa(s,'function_handle'))));
addParamValue(parser,'lineStyles',options.lineStyles, @(s)(iscell(s) && all(cellfun(@(s2)ismember(s2,{'-','--',':','-.','none'}),s)) || isa(s,'function_handle')));
addParamValue(parser,'markerSizes',options.markers, @(s)isnumeric(s));
addParamValue(parser,'lineWidths',options.lineWidths, @(s)isnumeric(s));
addParamValue(parser,'markerEdgeColorModificationFunction',options.markerEdgeColorModificationFunction, @(s)isempty(s) || isa(s,'function_handle'));
addParamValue(parser,'legendStrings',options.legendStrings, @(s)iscell(s));
parse(parser,varargin{:});

options = parser.Results;

% Determine if things are linked
linkMarkerFaceColorAndColor = isempty(options.markerFaceColors);
linkMarkerEdgeColorAndMarkerFaceColor = isempty(options.markerEdgeColors);

% Make labels unique indexes
labelInds = labels;
for iY = 1:size(labels,2)
    cY = labels(:,iY);
    [~, ~, labelInds(:,iY)] = unique(cY);
end

% Interperet Inputs (function handles vs color matrices etc.)

% Colors specified as a function handle
% Must account for links to markerFace color and marker edge color
nColors = [];
if isa(options.colors,'function_handle')
    if any(options.styleOrder == 'c')
        cY = labelInds(:,find(options.styleOrder == 'c',1));
    else
        if linkMarkerFaceColorAndColor || any(options.styleOrder == 'f')
            cY = labelInds(:,find(options.styleOrder == 'f',1));
        else
            if (linkMarkerFaceColorAndColor && linkMarkerEdgeColorAndMarkerFaceColor) || any(options.styleOrder == 'e')
                cY = labelInds(:,find(options.styleOrder == 'e',1));
            else
                nColors = 0;
            end
        end
    end
    if isempty(nColors)
        uY = unique(cY);
        nColors = length(uY);
        
        options.colors = feval(options.colors, nColors);
    end
    
else
    nColors = size(options.colors,1);
end

if linkMarkerFaceColorAndColor
    options.markerFaceColors = options.colors;
end

if linkMarkerEdgeColorAndMarkerFaceColor
    if ~isempty(options.markerEdgeColorModificationFunction)
        options.markerEdgeColors = feval(options.markerEdgeColorModificationFunction,options.markerFaceColors);
    else
        options.markerEdgeColors = options.markerFaceColors;
    end
end
    

% Markers specified as Function Handle
if any(find(options.styleOrder == 'm'))
    if isa(options.markers,'function_handle')
        mInd = find(options.styleOrder == 'm',1);
        if mInd > size(labels,2)
            nMarkers = 0;
        else
            
            cY = labelInds(:,mInd);
            uY = unique(cY);
            nMarkers = length(uY);
            options.markers = feval(options.markers, nMarkers);
        end
    else
        nMarkers = length(options.markers);
    end
else
    nMarkers = 0;
end

% MarkerFaceColor specified as function handle
if any(find(options.styleOrder == 'f'))
    if isa(options.markerFaceColors,'function_handle')
        cY = labelInds(:,find(options.styleOrder == 'f',1));
        uY = unique(cY);
        nMarkerFaceColors = length(uY);
        options.markerFaceColors = feval(options.markerFaceColors, nMarkerFaceColors); % Call function
    else
        nMarkerFaceColors = size(options.markerFaceColors,1);
    end
else
    nMarkerFaceColors = 0;
end

% MarkerEdgeColor specified as function handle
if any(find(options.styleOrder == 'e'))
    if isa(options.markerEdgeColors,'function_handle')
        cY = labelInds(:,find(options.styleOrder == 'e',1));
        uY = unique(cY);
        nMarkerEdgeColors = length(uY);
        options.markerFaceColors = feval(options.markerEdgeColors, nMarkerEdgeColors); % Call function
    else
        nMarkerEdgeColors = size(options.markerEdgeColors,1);
    end
else
    nMarkerEdgeColors = 0;
end

nLines = length(options.lineStyles);
nWidths = length(options.lineWidths);
nSizes = length(options.markerSizes);

% Here we go
legendOutput = cell(size(lineHandles));
for iL = 1:numel(lineHandles)
    cH = lineHandles(iL);
    if ~ishandle(cH)
        continue
    end
    
    for iStyle = 1:min(length(options.styleOrder),size(labels,2))
        cStyleType = options.styleOrder(iStyle);
        
        cInd = labelInds(iL,iStyle);
        
        if ~isempty(options.legendStrings)
            if iStyle > 1
                legendOutput{iL} = cat(2,legendOutput{iL},' - ',options.legendStrings{iStyle}{cInd});
            else
                legendOutput{iL} = options.legendStrings{iStyle}{cInd};
            end
        end
        
        switch lower(cStyleType)
            case 'c'
                nStyles = nColors;
                cStyleInd = mod(cInd-1,nStyles)+1;
                cColor = options.colors(cStyleInd,:);
                set(cH,'color',cColor);
                
                if linkMarkerFaceColorAndColor
                    set(cH,'markerFaceColor',cColor);
                    if linkMarkerEdgeColorAndMarkerFaceColor
                        if ~isempty(options.markerEdgeColorModificationFunction)
                            cEdgeColor = feval(options.markerEdgeColorModificationFunction,cColor);
                        else
                            cEdgeColor = cColor;
                        end
                        set(cH,'markerEdgeColor',cEdgeColor);
                    end
                end
                
            case 'm'
                nStyles = nMarkers;
                cStyleInd = mod(cInd-1,nStyles)+1;
                cMarker = options.markers(cStyleInd);
                if iscell(cMarker)
                    cMarker = cMarker{1};
                end
                
                set(cH,'marker',cMarker);
                
            case 'f'
                nStyles = nMarkerFaceColors;
                cStyleInd = mod(cInd-1,nStyles)+1;
                cColor = options.markerFaceColors(cStyleInd,:);                
                set(cH,'markerFaceColor',cColor);
                
            case 'e'
                nStyles = nMarkerEdgeColors;
                cStyleInd = mod(cInd-1,nStyles)+1;
                cColor = options.markerEdgeColors(cStyleInd,:);                
                set(cH,'markerEdgeColor',cColor);
                
            case 'l'
                nStyles = nLines;
                cStyleInd = mod(cInd-1,nStyles)+1;
                cLine = options.lineStyles{cStyleInd};
                set(cH,'lineStyle',cLine);
                
            case 'w'
                nStyles = nWidths;
                cStyleInd = mod(cInd-1,nStyles)+1;
                cWidth = options.lineWidths(cStyleInd);
                set(cH,'lineWidth',cWidth);
                
            case 's'
                nStyles = nSizes;
                cStyleInd = mod(cInd-1,nStyles)+1;
                cSize = options.markerSizes(cStyleInd);
                set(cH,'markerSize',cSize);
                
            otherwise
                error('Unknown styleType identifier %s. Only c, m, f, e, l, w and s are valid.',cStyleType);
        end
    end
end

if nargout
    varargout = {legendOutput};
end
