classdef prtUiManagerPlotScatter < prtUiManagerPlot

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
    properties

        plotSymbolsFunction = @(n)prtPlotUtilClassSymbols(n);
        plotSymbolEdgeModificationFunction = @(color)prtPlotUtilLightenColors(color);
        plotSymbolLineWidth = 1;
        plotSymbolSize = 8;
    end
    properties (Dependent)
        nDataDims
    end
    methods
        function self = prtUiManagerPlotScatter(varargin)
            if nargin
                self = prtUtilAssignStringValuePairs(self, varargin{:});
            end
        end
        function addPlot(self, X)
            
            allColors = self.plotColorsFunction(self.nLines+1);
            allSymbols = self.plotSymbolsFunction(self.nLines+1);
            
            self.hold = 'on';
            newLineHandles = prtPlotUtilScatter(X, {}, allSymbols(end), allColors(end,:), self.plotSymbolEdgeModificationFunction(allColors(end,:)), self.plotSymbolLineWidth, self.plotSymbolSize);
            self.lineHandles = cat(1,self.lineHandles,newLineHandles);
            self.hold = 'off';
            
            self.setAxesConstraints();
        end
    end
end
