classdef prtUiDataSetClassExploreWidgetTabPlotOptions < prtUiDataSetClassExploreWidgetTab
    properties
        titleStr = 'Plot Options';
        
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
            
            self.handles.jScrollPane = findjobj(self.handles.table);
            self.handles.jTable = self.handles.jScrollPane.getViewport.getView;
            
            %self.tableFieldNames
            
            
            % Set the actual data in the cell
%             set(self.handles.table,'data',self.dataCell,...
%                 'columnName',self.tableFieldNames,...
%                 'RearrangeableColumns','off',...
%                 'RowName',{},...
%                 'TooltipString','Plotting Options',...
%                 'ColumnEditable',true(1,length(self.tableFieldNames)),...
%                 'KeyPressFcn',@self.tableKeyPressFcn,...
%                 'CellSelectionCallback',@self.cellCelectionFcn);
           
            % Force selection of full rows only
            %self.handleStruct.jTable.setNonContiguousCellSelection(false)
            
            % Force selection of a single row only
            %if ~self.enableMultiSelect
            %    self.handleStruct.jTable.setSelectionMode(javax.swing.ListSelectionModel.SINGLE_SELECTION);
            %end
            
            % Set the column widths to take up the whole area
            self.handles.jTable.setAutoResizeMode(self.handles.jTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);
        end
    end
end