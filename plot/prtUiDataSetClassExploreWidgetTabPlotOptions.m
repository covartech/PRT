classdef prtUiDataSetClassExploreWidgetTabPlotOptions < prtUiDataSetClassExploreWidgetTab

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

        titleStr = 'Plot Options';
        
        possibleMarkers = {'o','s','^','d','v','x','.','<','>','p','h'};
        
        dataCell
        handles
    end
    
    methods
        function self = prtUiDataSetClassExploreWidgetTabPlotOptions(varargin)
            
            self = prtUtilAssignStringValuePairs(self,varargin{:});
            
            if nargin~=0 && ~self.hgIsValid
                self.create()
            end
            
            init(self);
        end
        
        function init(self)
            
            self.handles.table = uitable('parent',self.managedHandle,...
                'units','normalized','position',[0 0 1 1]); % Dummy position
            
            %self.handles.jScrollPane = findjobj(self.handles.table);
            %self.handles.jTable = self.handles.jScrollPane.getViewport.getView;
            
            % uY, visible, legend string, shape, color, edgeColor, markerSize, edgeSize
            
            initData(self);
            
            columnFormat = {'char', 'logical', self.possibleMarkers,'char','char','numeric','numeric'};
            columnHeadings = {'String','Visible','Shape','Color','Edge Color',' Size','Edge Size'};
            
            self.handles.uicontextmenu = uicontextmenu;
            self.handles.uicontextmenuReset = uimenu(self.handles.uicontextmenu, 'Label', 'reset', 'Callback', @(h,e)self.reset);
            
            % Set the actual data in the cell
            set(self.handles.table,...
                'columnName',columnHeadings,...
                'columnFormat',columnFormat,...
                'RearrangeableColumns','on',...
                'RowName',{},...cat(1,num2cell(self.widget.plotManager.dataSet.uniqueClasses(:)),{nan}),...
                'TooltipString','Plotting Options',...
                'ColumnEditable',true(1,size(self.dataCell,2)),...
                'CellEditCallback',@(h,e)self.tableCellEditCallback(h,e),...
                'UIContextMenu',self.handles.uicontextmenu);
            
            
            %javaaddpath(fullfile(prtRoot,'+prtExternal','+ColorCell'));
            
            %self.handles.jTable.setModel(javax.swing.table.DefaultTableModel(self.dataCell,columnHeadings))
            %self.handles.jTable.getColumnModel.getColumn(3).setCellRenderer(ColorCellRenderer);
            %self.handles.jTable.getColumnModel.getColumn(3).setCellEditor(ColorCellEditor);
            
            %self.handles.jTable.getColumnModel.getColumn(4).setCellRenderer(ColorCellRenderer);
            %self.handles.jTable.getColumnModel.getColumn(4).setCellEditor(ColorCellEditor);
                
            % Set the column widths to take up the whole area
            %self.handles.jTable.setAutoResizeMode(self.handles.jTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);
        end
        
        function reset(self)
            self.widget.plotManager.setDataSetDependentProperties();
            initData(self);
        end
        
        function initData(self)
            
            uYs = self.widget.plotManager.dataSet.uniqueClasses;
            
            data = cell(length(uYs)+1, 7);
            data(:,1) = cat(1,self.widget.plotManager.legendStrings,{self.widget.plotManager.legendStringUnlabeled});
            data(:,2) = num2cell(logical(cat(1, self.widget.plotManager.isVisible(:), self.widget.plotManager.isVisibleUnlabeled)));
            data(:,3) = cat(1,num2cell(self.widget.plotManager.markers(:)),{self.widget.plotManager.markerUnlabeled});
            
            for iClass = 1:length(uYs)
                
                cColor = max(min(round(self.widget.plotManager.colors(iClass,:)*255),255),0);
                cEdgeColor = max(min(round(self.widget.plotManager.edgeColors(iClass,:)*255),255),0);
                
                data{iClass,4} = sprintf('%d,%d,%d',cColor(1), cColor(2), cColor(3));
                data{iClass,5} = sprintf('%d,%d,%d',cEdgeColor(1), cEdgeColor(2), cEdgeColor(3));
            end
            cColor = max(min(round(self.widget.plotManager.colorUnlabeled*255),255),0);
            cEdgeColor = max(min(round(self.widget.plotManager.edgeColorUnlabeled*255),255),0);
            
            data{end,4} = sprintf('%d,%d,%d',cColor(1), cColor(2), cColor(3));
            data{end,5} = sprintf('%d,%d,%d',cEdgeColor(1), cEdgeColor(2), cEdgeColor(3));
            
            data(:,6) = num2cell(cat(1,self.widget.plotManager.markerSizes(:), self.widget.plotManager.markerSizeUnlabeled));
            data(:,7) = num2cell(cat(1,self.widget.plotManager.markerLineWidths(:), self.widget.plotManager.markerLineWidthUnlabeled));
            
            self.dataCell = data;
            
            set(self.handles.table,'data',self.dataCell);
        end
        function tableCellEditCallback(self, h, e)
            
            inds = e.Indices;
            
            switch inds(2)
                case 1
                    changeLegend(self, h, e);
                case 2
                    changeVisible(self, h, e);
                case 3
                    changeMarkers(self, h, e);
                case 4
                    changeColors(self, h, e);
                case 5
                    changeEdgeColors(self, h, e);
                case 6
                    changeMarkerSize(self, h, e);
                case 7
                    changeMarkerEdgeSize(self, h, e)
            end
        end
        
        function changeVisible(self, h, e)
            newValue = logical(e.NewData);
            
            cData = self.dataCell;
            if e.Indices(1) < size(cData,1)
                self.widget.plotManager.isVisible(e.Indices(1)) = newValue;
            else
                self.widget.plotManager.isVisibleUnlabeled = newValue;
            end
            
            self.widget.plotManager.legendRefresh()
            
            self.dataCell{e.Indices(1), e.Indices(2)} = newValue;
        end
        function changeLegend(self, h, e)
            if e.Indices(1) < size(self.dataCell,1)
                self.widget.plotManager.legendStrings{e.Indices(1)} = e.NewData;
            else
                self.widget.plotManager.legendStringUnlabeled = e.NewData;
            end
            
            self.dataCell{e.Indices(1), e.Indices(2)} = e.NewData;
        end
        function changeMarkers(self, h, e)
            if e.Indices(1) < size(self.dataCell,1)
                self.widget.plotManager.markers(e.Indices(1)) = e.NewData;
            else
                self.widget.plotManager.markerUnlabeled = e.NewData;
            end
            
            self.dataCell{e.Indices(1), e.Indices(2)} = e.NewData;
        end
        function changeColors(self, h, e)
            [err, color] = testColorValueString(self, e.NewData);
            if err
                set(self.handles.table,'data',self.dataCell); % Keep what we had
                return
            end
            
            if e.Indices(1) < size(self.dataCell,1)
                self.widget.plotManager.colors(e.Indices(1),:) = color;
            else
                self.widget.plotManager.colorUnlabeled = color;
            end
            
            self.dataCell{e.Indices(1), e.Indices(2)} = e.NewData;
        end
        function changeEdgeColors(self, h, e)
            [err, color] = testColorValueString(self, e.NewData);
            if err
                set(self.handles.table,'data',self.dataCell); % Keep what we had
                return
            end
            
            if e.Indices(1) < size(self.dataCell,1)
                self.widget.plotManager.edgeColors(e.Indices(1),:) = color;
            else
                self.widget.plotManager.edgeColorUnlabeled = color;
            end
            
            self.dataCell{e.Indices(1), e.Indices(2)} = e.NewData;
        end
        function [err, color] = testColorValueString(self, val)
            
            err = true;
            color = [];
            try
                commaLocs = find(val==',');
                if length(commaLocs) ~= 2
                    return
                end
                
                color = zeros(1,3);
                color(1) = str2double(val(1:commaLocs(1)-1));
                color(2) = str2double(val((commaLocs(1)+1):(commaLocs(2)-1)));
                color(3) = str2double(val((commaLocs(2)+1):end));
                
                color = color/255;
                
                if any(color < 0) || any(color > 1) || any(isnan(color))
                    color = [];
                    return
                end
                err = false;
            catch
                err = true;
                color = [];
            end
        end
        
        function changeMarkerSize(self, h, e)
            try
                assert(e.NewData > 0);
                if e.Indices(1) < size(self.dataCell,1)
                    self.widget.plotManager.markerSizes(e.Indices(1)) = e.NewData;
                else
                    self.widget.plotManager.markerSizeUnlabeled = e.NewData;
                end
                
                self.dataCell{e.Indices(1), e.Indices(2)} = e.NewData;
                
            catch %#ok<CTCH>
                set(self.handles.table,'data',self.dataCell);
            end
        end
        function changeMarkerEdgeSize(self, h, e)
            try
                assert(e.NewData > 0);
                if e.Indices(1) < size(self.dataCell,1)
                    self.widget.plotManager.markerLineWidths(e.Indices(1)) = e.NewData;
                else
                    self.widget.plotManager.markerLineWidthUnlabeled = e.NewData;
                end
                
                self.dataCell{e.Indices(1), e.Indices(2)} = e.NewData;
                
            catch %#ok<CTCH>
                set(self.handles.table,'data',self.dataCell);
            end
        end
    end
end
