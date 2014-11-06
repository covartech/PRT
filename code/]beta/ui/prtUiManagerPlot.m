classdef prtUiManagerPlot < prtUiManagerAxes

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
    properties (Dependent)

        nLines
    end
    properties
        lineHandles = [];
        plotColorsFunction = @(n)prtPlotUtilClassColors(n);
    end
    methods
        function self = prtUiManagerPlot(varargin)
           if nargin
               self = prtUtilAssignStringValuePairs(self, varargin{:});
           end
           
           self.setStandardLineProperties();
           self.setAxesConstraints();
        end
        
        function setStandardLineProperties(self,indsToSet)
            if nargin < 2 || isempty(indsToSet)
                indsToSet = [];
            end
            updateLineColors(self,indsToSet);
        end
        
        function updateLineColors(self,indsToSet)
            if nargin < 2 || isempty(indsToSet)
                indsToSet = 1:self.nLines;
            end
            assert(all(ismember(indsToSet,1:self.nLines)),'specified lineHandles indexs to update must be in the range of 1:nLines');
            colors = self.plotColorsFunction(self.nLines);
            for iLine = indsToSet
                set(self.lineHandles(iLine),'color',colors(iLine,:));
            end
        end
        
        function plot(self,varargin)
            self.lineHandles = plot(self.managedHandle,varargin{:});
        end
        
        function replot(self, xData, yData, zData)
            if nargin < 3
                yData = [];
            end
            if nargin < 4
                zData = [];
            end
            
            if isempty(self.lineHandles)
                if ~isempty(yData)
                    if ~isempty(zData)
                        self.lineHandles = plot3(self.managedHandle, xData, yData, zData);
                    else
                        self.lineHandles = plot(self.managedHandle, xData, yData);
                    end
                else
                    self.lineHandles = plot(self.managedHandle, xData);
                end
            else
                 if ~isempty(yData)
                    if ~isempty(zData)
                        self.updateData(xData, yData, zData);
                    else
                        self.updateData(xData, yData);
                    end
                 else
                     self.updateData([],xData)
                 end
            end
        end
        
        function addPlot(self,varargin)
            self.hold = 'on';
            newLineHandles = plot(varargin{:});
            oldNLines = self.nLines;
            self.lineHandles = cat(1,self.lineHandles,newLineHandles);
            self.hold = 'off';
            self.updateLineColors((oldNLines+1):self.nLines);
            
            self.setAxesConstraints();
        end
        
        function updateData(self, xData, yData, zData, inds)
            % updateData(self, xData)
            % updateData(self, xData, yData)
            % updateData(self, xData, yData, zData)
            % updateData(self, xData, yData, zData, inds)
            updateYData = true;
            updateXData = true;
            updateZData = true;
            if nargin < 5 || isempty(inds)
                inds = 1:self.nLines;
            end
            if nargin < 4 || isempty(zData)
                updateZData = false;
            end
            if nargin < 3 || isempty(yData)
                updateYData = false;
            end
            if nargin < 2 || isempty(xData)
                updateXData = false;
            end
            
            for iLine = 1:length(inds)
                cHandle = self.lineHandles(inds(iLine));
                
                if updateXData
                    cXData = get(cHandle,'XData');
                    
                    if iscell(xData)
                        cNewXData = xData{iLine};
                    else
                        assert(isnumeric(xData),'prt:prtGuiManagerPlot:updateData','supplied XData must be numeric');
                        
                        if isvector(xData)
                            cNewXData = xData;
                        else
                            assert(size(xData,2)==length(inds),'prt:prtGuiManagerPlot:updateData','size of the supplied XData does not match the number of lines specified for setting.')
                            cNewXData = xData(:,iLine);
                        end
                    end
                    
                    if isvector(cXData) && isvector(cNewXData)
                        cXData = cXData(:);
                        cNewXData = cNewXData(:);
                    end
                    assert(isequal(size(cXData),size(cNewXData)),'prt:prtGuiManagerPlot:updateData','size of the supplied XData does not match that of the existing XData')
                    
                    set(cHandle,'XData',cNewXData);
                end
                if updateYData
                    cYData = get(cHandle,'YData');
                    
                    if iscell(yData)
                        cNewYData = yData{iLine};
                    else
                        assert(isnumeric(yData),'prt:prtGuiManagerPlot:updateData','supplied YData must be numeric');
                        
                        if isvector(yData)
                            cNewYData = yData;
                        else
                            assert(size(yData,2)==length(inds),'prt:prtGuiManagerPlot:updateData','size of the supplied YData does not match the number of lines specified for setting.')
                            cNewYData = yData(:,iLine);
                        end
                    end
                    
                    if isvector(cYData) && isvector(cNewYData)
                        cYData = cYData(:);
                        cNewYData = cNewYData(:);
                    end
                    assert(isequal(size(cYData),size(cNewYData)),'prt:prtGuiManagerPlot:updateData','size of the supplied YData does not match that of the existing YData')
                    
                    set(cHandle,'YData',cNewYData);
                end
                if updateZData
                    cZData = get(cHandle,'ZData');
                    
                    if iscell(yData)
                        cNewZData = zData{iLine};
                    else
                        assert(isnumeric(zData),'prt:prtGuiManagerPlot:updateData','supplied ZData must be numeric');
                        
                        if isvector(zData)
                            cNewZData = zData;
                        else
                            assert(size(zData,2)==length(inds),'prt:prtGuiManagerPlot:updateData','size of the supplied ZData does not match the number of lines specified for setting.')
                            cNewZData = zData(:,iLine);
                        end
                    end
                    
                    if isvector(cZData) && isvector(cNewZData)
                        cZData = cZData(:);
                        cNewZData = cNewZData(:);
                    end
                    assert(isequal(size(cZData),size(cNewZData)),'prt:prtGuiManagerPlot:updateData','size of the supplied ZData does not match that of the existing ZData')
                    
                    set(cHandle,'ZData',cNewZData);
                end
            end
            
            self.setAxesConstraints();
        end
            
        function val = get.nLines(self)
            val = length(self.lineHandles);
        end
        
        function set.nLines(self,val) %#ok<INUSD,MANU>
            error('prt:prtGuiManagerPlot:nLines','Setting nLines is not allowed');
        end
        
        function lh = get.lineHandles(self)
            lh = self.lineHandles;
            assert(all(ishandle(lh)),'prt:prtGuiManagerPlot:badHandles','Some or all of the requested handles are no longer valid. The axes may have been deleted.');
        end
    end
end
