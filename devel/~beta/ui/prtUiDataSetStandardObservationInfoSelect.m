classdef prtUiDataSetStandardObservationInfoSelect < prtUiManagerPanel
    properties
        prtDs
        handleStruct
        dataCell = {};
    end
    
    methods 
        function self = prtUiDataSetStandardObservationInfoSelect(varargin)
            if nargin == 1
                obsInfoStruct = varargin{1};
                self.prtDs = prtDataSetStandard(nan(length(obsInfoStruct),1));
                self.prtDs.observationInfo = obsInfoStruct;
            else
                self = prtUtilAssignStringValuePairs(self,varargin{:});
            end
            
            self = init(self);
        end
        
        function self = init(self)
            self.handleStruct.table = uitable('parent',self.managedHandle,...
                'units','normalized','position',[0.05 0.05 0.9 0.8]);
            
            self.handleStruct.jScrollPane = findjobj(self.handleStruct.table);
            self.handleStruct.jTable = self.handleStruct.jScrollPane.getViewport.getView;
            
            %self.handleStruct.tableContextMenuItems{1} = uimenu(hcmenu, 'Label', 'Create', 'Callback', @(myHandle,eventData)selkf);
            %self.handleStruct.tableContextMenu = uicontextmenu(
            
            self.handleStruct.edit = uicontrol(self.managedHandle,...
                'style','edit','units','normalized',...
                'position',[0.05 0.87 0.9 0.08],...
                'fontUnits','normalized',...
                'fontSize',0.7,...
                'string','@(S)true(size(S))',...
                'callback',@(myHandle,eventData)self.editCallback(myHandle,eventData));
            
            if ~isempty(self.prtDs.observationInfo)
                fnames = fieldnames(self.prtDs.observationInfo);
            
                self.dataCell = cell(length(self.prtDs.observationInfo),length(fnames));
                for iObs = 1:size(self.dataCell,1)
                    for iField = 1:size(self.dataCell,2)
                        cVal = self.prtDs.observationInfo(iObs).(fnames{iField});
                        if ischar(cVal) || islogical(cVal) || (isnumeric(cVal) && isscalar(cVal))
                            self.dataCell{iObs,iField} = cVal;
                        else
                            error('prt:prtUiDataSetStandardObservationInfoSelect','invalid structure value for uitable');
                        end
                    end
                end
                 
                set(self.handleStruct.table,'data',self.dataCell,...
                    'ColumnName',fnames,...
                    'ColumnEditable',false(1,length(fnames)),...
                    'ColumnWidth','auto','RearrangeableColumns','on',...
                    'RowStriping','off','RowName','');
                
                self.handleStruct.jTable.setSortable(true);		% or: set(jtable,'Sortable','on');
                self.handleStruct.jTable.setAutoResort(true);
                self.handleStruct.jTable.setMultiColumnSortable(true);
                self.handleStruct.jTable.setPreserveSelectionsAfterSorting(true);
                
                %set(self.handleStruct.jTable,'SelectionBackground',get(self.handleStruct.jTable,'MarginBackground'))
                %set(self.handleStruct.jTable,'SelectionForeground',[0.8 0.8 0.8])
                self.handleStruct.jTable.setColumnAutoResizable(true);
                self.handleStruct.jTable.setAutoResizeMode(self.handleStruct.jTable.AUTO_RESIZE_NEXT_COLUMN)
                
                
            end
            
        end
        %function 
        
        function editCallback(self, myHandle, eventData)
            cStr = get(myHandle,'string');
            
            try
                selectFunctionHandle = eval(cStr);
            catch
                msgbox('Invalid function handle','Invalid Function Handle','error','modal');
                return
            end
            
            try
                [dontNeed, keep] = self.prtDs.select(selectFunctionHandle);
            catch ME
                msgbox(cat(2,'Evaluation of function handle failed. ', ME.message),'Invalid Function Handle','error','modal');
                return
            end
            self.updateTableDisplay(keep);
            
        end
        function updateTableDisplay(self, showRows)
            
            %set(self.handleStruct.table,'Data',self.dataCell(showRows,:));
            
            topInds = find(showRows);
            bottomInds = find(~showRows);
            sortingInds = cat(1,topInds,bottomInds);
            set(self.handleStruct.table,'Data',self.dataCell(sortingInds,:))
            
            
            self.handleStruct.jTable.setRowSelectionInterval(length(topInds),length(showRows)-1);
            
        end
        function tableResizeCallback(self, myHandle,eventData)
            keyboard
        end
    end
end