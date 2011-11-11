classdef prtUiDataSetStandardObservationInfoSelect < prtUiManagerPanel
    properties
        prtDs
        
        tableFieldNames = {};
        handleStruct
        dataCell = {};
        
        sortingInds
    end
    properties (Hidden, SetAccess='protected', GetAccess='protected')
        selectrStrDepHelper = 'true(size(S))';
        retainedObsDepHelper = [];
        retainedObsUpdateCallbackDepHelper = [];
    end
    properties (Dependent)
        retainedObs
        selectStr 
        retainedObsUpdateCallback
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
            
            if nargin~=0 && ~self.hgIsValid
               self.create()
            end
            
            init(self);
        end
        
        function init(self)
            
            self.handleStruct.table = uitable('parent',self.managedHandle,...
                'units','normalized','position',[0.05 0.05 0.9 0.8]);
            
            self.handleStruct.jScrollPane = findjobj(self.handleStruct.table);
            self.handleStruct.jTable = self.handleStruct.jScrollPane.getViewport.getView;
            
            
            self.handleStruct.tableContextMenu = uicontextmenu;
            self.handleStruct.tableContextMenuItemNewSelection = uimenu(self.handleStruct.tableContextMenu, 'Label', 'New Selection', 'Callback', @(myHandle,eventData)self.uiMenuNewSelection(myHandle,eventData));
            self.handleStruct.tableContextMenuItemAndSelection = uimenu(self.handleStruct.tableContextMenu, 'Label', 'And with Current Selection', 'Callback', @(myHandle,eventData)self.uiMenuAndSelection(myHandle,eventData));
            self.handleStruct.tableContextMenuItemOrSelection = uimenu(self.handleStruct.tableContextMenu, 'Label', 'Or with Current Selection', 'Callback', @(myHandle,eventData)self.uiMenuOrSelection(myHandle,eventData));
            self.handleStruct.tableContextMenuItemNoSelection = uimenu(self.handleStruct.tableContextMenu, 'Label', 'Clear Selections', 'Callback', @(myHandle,eventData)self.uiMenuNoSelection(myHandle,eventData));
            
            self.handleStruct.edit = uicontrol(self.managedHandle,...
                'style','edit','units','normalized',...
                'position',[0.05 0.87 0.9 0.08],...
                'fontUnits','normalized',...
                'fontSize',0.4,...
                'string',self.selectStr,...
                'callback',@(myHandle,eventData)self.editCallback(myHandle,eventData));
            
            if ~isempty(self.prtDs.observationInfo)
                self.tableFieldNames = fieldnames(self.prtDs.observationInfo);
            
                self.dataCell = cell(length(self.prtDs.observationInfo),length(self.tableFieldNames));
                badColumns = false(length(self.tableFieldNames),1);
                
                obsInfo = self.prtDs.getObservationInfo;
                
                nObs = self.prtDs.nObservations;
                for iField = 1:length(self.tableFieldNames);
                    %cVals = self.prtDs.getObservationInfo(self.tableFieldNames{iField});
                
                    fieldName = self.tableFieldNames{iField};
                    try
                        cVals = cat(1,obsInfo.(fieldName));
                    catch %#ok<CTCH>
                        % This failed because of invalid matrix dimensions
                        cVals = [];
                    end
                    if size(cVals,1) == nObs
                        % Everything worked out, value in observationInfo
                        % is a row vector of contstant size
                    else
                        % Failure, or invalid size, so we return a cell
                        try
                            cVals = {obsInfo.(fieldName)}';
                        catch %#ok<CTCH>
                            error('prt:prtDataSetStandard:getObservationInfo','getObservationInfo failed to retrieve the necessary field for an unknown reason');
                        end
                    end
                    
                    
                    if iscell(cVals) && ~iscellstr(cVals)
                        % If getObservationInfo() outputs a cell that isn't
                        % a cellstr then we can't use it.
                        badColumns(iField) = true;
                        continue
                    end
                    if ischar(cVals)
                        cVals = cellstr(cVals);
                    end
                    
                    if isnumeric(cVals) || islogical(cVals)
                        cVals = cellstr(num2str(cVals));
                    end
                    
                    self.dataCell(:,iField) = cellfun(@(c)sprintf('<HTML><font color=#000000>%s',c),cVals,'uniformoutput',false);
                end
                
                self.dataCell = self.dataCell(:,~badColumns);
                self.tableFieldNames = self.tableFieldNames(~badColumns);
                
                if any(badColumns)
                    warning('prt:prtUiDataSetStandardObservationInfoSelect:badFields','Some fields cannot be displayed.');
                end
                
                set(self.handleStruct.table,'data',self.dataCell,...
                    'ColumnName',self.tableFieldNames,...
                    'ColumnEditable',false(1,length(self.tableFieldNames)),...
                    'ColumnWidth','auto','RearrangeableColumns','off',...
                    'RowStriping','off','RowName',cellstr(num2str((1:size(self.dataCell,1))')),...
                    'uicontextmenu',self.handleStruct.tableContextMenu);
                
%                 self.handleStruct.jTable.setSortable(true);		% or: set(jtable,'Sortable','on');
%                 self.handleStruct.jTable.setAutoResort(true);
%                 self.handleStruct.jTable.setMultiColumnSortable(true);
%                 self.handleStruct.jTable.setPreserveSelectionsAfterSorting(true);
                
%                 set(self.handleStruct.jTable,'SelectionBackground',get(self.handleStruct.jTable,'MarginBackground'))
%                 set(self.handleStruct.jTable,'SelectionBackground',[0.4 0.4 0.4])
%                 set(self.handleStruct.jTable,'SelectionForeground',[1 1 1])
                self.handleStruct.jTable.setAutoResizeMode(self.handleStruct.jTable.AUTO_RESIZE_SUBSEQUENT_COLUMNS);
                
                self.sortingInds = (1:size(self.dataCell,1))';
            end
        end
        
        function uiMenuNewSelection(self,myHandle,eventData) %#ok<INUSD>
            commandStr = selectionToSelectStr(self);
            self.selectStr = commandStr;
        end
        function uiMenuOrSelection(self,myHandle,eventData) %#ok<INUSD>
            commandStr = selectionToSelectStr(self);
            self.selectStr = cat(2,'(', self.selectStr,') | ', commandStr);
        end
        function uiMenuAndSelection(self,myHandle,eventData) %#ok<INUSD>
            commandStr = selectionToSelectStr(self);
            self.selectStr = cat(2,'(', self.selectStr,') & ', commandStr);
        end
        function uiMenuNoSelection(self,myHandle,eventData) %#ok<INUSD>
            self.selectStr = 'true(size(S))';
        end
        function val = get.selectStr(self)
            val = self.selectrStrDepHelper;
        end
        function set.selectStr(self,val)
            if isempty(val)
                val = 'true(size(S))';
            end
            
            self.selectrStrDepHelper = val;
            set(self.handleStruct.edit,'string',val);
            self.applySelection();
        end
        function val = get.retainedObsUpdateCallback(self)
            val = self.retainedObsUpdateCallbackDepHelper;
        end
        function set.retainedObsUpdateCallback(self,val)
            assert(isempty(val) || (isa(val, 'function_handle') && nargin(val)==1),'retainedObsUpdateCallback must be a function handle that accepts one input')
            
            self.retainedObsUpdateCallbackDepHelper = val;
        end
        function val = get.retainedObs(self)
            val = self.retainedObsDepHelper;
        end
        function set.retainedObs(self, val)
            if ~isempty(self.retainedObsUpdateCallback)
                self.retainedObsUpdateCallback(val)
            end
            self.retainedObsDepHelper = val;
        end
        function commandStr = selectionToSelectStr(self)
            tableSelectionModel = self.handleStruct.jTable.getTableSelectionModel;
            
            cs = tableSelectionModel.getSelectedColumns+1;
            rs = tableSelectionModel.getSelectedRows+1;
            
            
            commandStr = '';
            for iCol = 1:length(cs)
                selectedRowsInThisColumn = rs(arrayfun(@(r)tableSelectionModel.isSelected(r, cs(iCol)-1), rs-1));
            
                cField = self.tableFieldNames{cs(iCol)};
                cVals = getObservationInfo(self.prtDs.retainObservations(self.sortingInds(selectedRowsInThisColumn)),cField);
                
                if ischar(cVals) || iscellstr(cVals)
                    
                    cVals = cellstr(cVals);
                    
                    uVal = unique(cVals);
                    
                    for iCell = 1:length(uVal)
                        uVal{iCell} = strrep(uVal{iCell},'''','''''');
                    end
                    
                    valStr = sprintf('''%s'',',uVal{:});
                    valStr = valStr(1:(end-1));
                    cCommandStr = sprintf('ismember(S.%s,{%s})',cField,valStr);
                    
                elseif islogical(cVals)
                    % Logical
                    % If scalar use the value itself, ~the value, or ignore
                    % If vector use ismember
                    
                    uVal = unique(cVals,'rows');
                    if isscalar(uVal)
                        if uVal
                            cCommandStr = sprintf('S.%s',cField);
                        else
                            cCommandStr = sprintf('~S.%s',cField);
                        end
                    else
                        cCommandStr = '';
                    end
                    
                else
                    % Numeric
                    % Use == or ismember
                    uVal = unique(cVals,'rows');
                    if isscalar(uVal)
                        cCommandStr = sprintf('S.%s==%s',cField,mat2str(uVal));
                    else
                        cCommandStr = sprintf('ismember(S.%s,%s)',cField,mat2str(uVal));
                    end
                end
                
                if ~isempty(cCommandStr)
                    if isempty(commandStr)
                        commandStr = cCommandStr;
                    else
                        commandStr = cat(2,commandStr,' & ', cCommandStr);
                    end
                end
            end
        end
        
        function editCallback(self, myHandle, eventData) %#ok<INUSD>
            self.selectStr = get(myHandle,'string');
        end
        function applySelection(self)
            try
                funHandle = self.selectFunctionHandle;
            catch %#ok<CTCH>
                msgbox('Invalid function handle','Invalid Function Handle','error','modal');
                return
            end
            
            try
                [dontNeed, keep] = self.prtDs.select(funHandle); %#ok<ASGLU>
            catch ME
                msgbox(cat(2,'Evaluation of function handle failed. ', ME.message),'Invalid Function Handle','error','modal');
                return
            end
            self.retainedObs = keep;
            
            self.updateTableDisplay();
        end
        function val = selectFunctionHandle(self)
            val = eval(sprintf('@(S)(%s)',self.selectStr));
        end
        function updateTableDisplay(self)
            showRows = self.retainedObs;
            
            %set(self.handleStruct.table,'Data',self.dataCell(showRows,:));
            
            topInds = find(showRows);
            bottomInds = find(~showRows);
            self.sortingInds = cat(1,topInds,bottomInds);
            
            for iRow = 1:length(topInds)
                cRow = topInds(iRow);
                for iCol = 1:size(self.dataCell,2)
                    cStr = self.dataCell{cRow,iCol};
                    cStr(find(cStr=='#')+(1:6)) = '000000';
                    self.dataCell{cRow,iCol} = cStr;
                end
            end
            for iRow = 1:length(bottomInds)
                cRow = bottomInds(iRow);
                for iCol = 1:size(self.dataCell,2)
                    cStr = self.dataCell{cRow,iCol};
                    cStr(find(cStr=='#')+(1:6)) = 'C7C7C7';
                    self.dataCell{cRow,iCol} = cStr;
                end
            end            
            set(self.handleStruct.table,'Data',self.dataCell(self.sortingInds,:),...    
                    'RowName',cellstr(num2str(self.sortingInds)));
            
        end
    end
end