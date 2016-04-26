classdef prtUiDataSetClassExploreWidgetTabSelectAxes < prtUiDataSetClassExploreWidgetTab





    properties

        titleStr = 'Axes';
        
        selectionNames 
        tableFieldNames = {'Axes','Feature' 'Use'}
        
        featureIndices = [];
        
        handles
    end
    
    methods
        function self = prtUiDataSetClassExploreWidgetTabSelectAxes(varargin)
            self = self@prtUiDataSetClassExploreWidgetTab(varargin{:});
            
            init(self);
        end
        
        function init(self)
            
            self.handles.table = uitable('parent',self.managedHandle,...
                'units','normalized','position',[0 0 1 1]); % Dummy position
            
            %self.handles.jScrollPane = findjobj(self.handles.table);
            %self.handles.jTable = self.handles.jScrollPane.getViewport.getView;
            
            self.selectionNames = cat(2,{'Targets'},self.widget.plotManager.dataSet.getFeatureNames());
            
            columnFormat = {'char',self.selectionNames,'logical'};
            
            tableData =  {'X', 'Targets', true;...
                          'Y', 'Targets', true;...
                          'Z', 'Targets', false;};
            
            switch length(self.widget.plotManager.featureIndices)
                case 1
                    tableData{1,2} = self.selectionNames{self.widget.plotManager.featureIndices(1)+1};
                    self.featureIndices = [self.widget.plotManager.featureIndices(1) 0];
                case 2
                    tableData{1,2} = self.selectionNames{self.widget.plotManager.featureIndices(1)+1};
                    tableData{2,2} = self.selectionNames{self.widget.plotManager.featureIndices(2)+1};
                    self.featureIndices = [self.widget.plotManager.featureIndices(1) self.widget.plotManager.featureIndices(2)];
                otherwise
                    tableData{1,2} = self.selectionNames{self.widget.plotManager.featureIndices(1)+1};
                    tableData{2,2} = self.selectionNames{self.widget.plotManager.featureIndices(2)+1};
                    tableData{3,2} = self.selectionNames{self.widget.plotManager.featureIndices(3)+1};
                    tableData{3,3} = true;
                    self.featureIndices = [self.widget.plotManager.featureIndices(1) self.widget.plotManager.featureIndices(2) self.widget.plotManager.featureIndices(3)];
            end
            
            % Set the actual data in the cell
            set(self.handles.table,...
                'ColumnName',self.tableFieldNames,...
                'RearrangeableColumns','off',...
                'RowName',{},...
                'Data',tableData,...
                'CellEditCallback',@(h,e)self.tableCellEditCallback(h,e),...
                'TooltipString','Select Features',...
                'ColumnEditable',[false true true],... 'KeyPressFcn',@self.tableKeyPressFcn,...'CellSelectionCallback',@(h,e)self.cellCelectionFcn(),...
                'ColumnFormat',columnFormat);
           
            
            % Force selection of a single row only
            %self.handles.jTable.setSelectionMode(javax.swing.ListSelectionModel.SINGLE_SELECTION);
            
            % Set the column widths to take up the whole area
            %self.handles.jTable.setAutoResizeMode(self.handles.jTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);
            
            
        end
        
        function tableCellEditCallback(self,h,e) %#ok<INUSL>
            
            cSelected = e.Indices;
            switch cSelected(2)
                case 2
                    % Editing the features
                    self.updateFeatureIndices(cSelected(1), e.NewData);
                case 3
                    % Editing visibility
                    if cSelected(1) == 3
                        if e.NewData
                            % Just turned it on
                            data = get(self.handles.table,'data');
                            [~, newInd] = ismember(data{3,2},self.selectionNames);
                            self.featureIndices = cat(2,self.featureIndices,newInd-1);
                        else
                            % Just turned it fof
                            if length(self.featureIndices) > 2
                                self.featureIndices = self.featureIndices(1:2);
                            end
                        end
                    else
                        data = get(self.handles.table,'data');
                        data{cSelected(1), cSelected(2)} = true;
                        set(self.handles.table, 'data',data);
                    end
                otherwise
                    % Not possibile
                    return
            end
        end
        
        function updateFeatureIndices(self, axesInd, newString)
            [~, newInd] = ismember(newString, self.selectionNames);
            data = get(self.handles.table,'data');
            if axesInd < 3 || data{3,3}
                self.featureIndices(axesInd) =  newInd-1;
            end
            
        end
        function set.featureIndices(self, val)
            self.featureIndices = val;
            self.widget.plotManager.featureIndices = val;
        end
    end
end
