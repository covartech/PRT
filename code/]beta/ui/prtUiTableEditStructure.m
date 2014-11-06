classdef prtUiTableEditStructure < prtUiManagerPanel
    % prtUiTableEditStructure
    %   
    properties
        
        enableRowDeletion = 'on';
        enableColumnCreation = 'on';
        dataStructure
        dataCell = {};
        
        tableFieldNames = {};
        handleStruct
        
        sortingInds
        
        fontSizeTable = 8;
        fontSizeEdit = 12;
        
        editableArray = [];
    end
    
    methods 
        function self = prtUiTableEditStructure(varargin)
            
            self = prtUtilAssignStringValuePairs(self,varargin{:});
            
            if nargin == 0
                self.create();
            elseif nargin~=0 && ~self.hgIsValid
               self.create()
            end
            
            init(self);
        end
        
        function create(self)
            % Overload the default prtUiManagerPanel
            % This will "create" a bigger figure and turn off toolbars and
            % stuff.
            
            self.handleStruct.figure = gcf;
            
            set(self.handleStruct.figure,...
                'Toolbar','none',...
                'MenuBar','none',...
                'Name','prtDataSetSelector',...
                'NumberTitle','off',...
                'WindowStyle','Normal',...
                'DockControls','off');
            
            if isempty(self.parent)
                self.managedHandle = uipanel(self.handleStruct.figure,...
                    'BackgroundColor',get(0,'DefaultFigureColor'),...
                    'BorderType','none');
            else
                self.managedHandle = uipanel('Parent',self.parent,...
                    'BackgroundColor',get(0,'DefaultFigureColor'),...
                    'BorderType','none');
            end
        end
        function init(self)
            
            self.handleStruct.table = uitable('parent',self.managedHandle,...
                'units','normalized',...
                'position',[0.05 0.05 0.9 0.8],...
                'fontUnits','points',...
                'fontSize',self.fontSizeTable,...
                'visible','on');
            drawnow;
            self.handleStruct.jScrollPane = findjobj(self.handleStruct.table);
            if ~isempty(self.handleStruct.jScrollPane)
                self.handleStruct.jTable = self.handleStruct.jScrollPane(1).getViewport.getView;
            end
            set(self.handleStruct.table,'visible','on');
            
            self.handleStruct.tableContextMenu = uicontextmenu;
            self.handleStruct.tableContextMenuItemNewSelection = uimenu(self.handleStruct.tableContextMenu, 'Label', 'Sort By', 'Callback', @(myHandle,eventData)self.sortBy(myHandle,eventData));
            self.handleStruct.tableContextMenuItemAndSelection = uimenu(self.handleStruct.tableContextMenu, 'Label', 'Set Values', 'Callback', @(myHandle,eventData)self.setValues(myHandle,eventData));
            self.handleStruct.tableContextMenuItemOrSelection = uimenu(self.handleStruct.tableContextMenu, 'Label', 'String Search Sort', 'Callback', @(myHandle,eventData)self.sortByStringSearch(myHandle,eventData));
            self.handleStruct.tableContextMenuCreateColumn = uimenu(self.handleStruct.tableContextMenu, 'Label', 'Add Column', 'Callback', @(myHandle,eventData)self.createColumn(myHandle,eventData),'Enable',self.enableColumnCreation,'Separator','on');
            self.handleStruct.tableContextMenuDeleteSelection = uimenu(self.handleStruct.tableContextMenu, 'Label', 'Delete Current Rows', 'Callback', @(myHandle,eventData)self.deleteSelectedRows(myHandle,eventData),'Enable',self.enableRowDeletion);
            
            
            %             self.handleStruct.tableContextMenuItemNoSelection = uimenu(self.handleStruct.tableContextMenu, 'Label', 'Remove From Table', 'Callback', @(myHandle,eventData)self.uiMenuNoSelection(myHandle,eventData));
            self.updateDataStructure;
        end
        
        function updateDataStructureFromGui(self,h,e)
            
            cellData = get(self.handleStruct.table,'data');
            
            selected = get(self.handleStruct.table,'UserData');
            if isempty(selected)
                warndlg('No rows selected');
                return;
            end
            selectedRow = selected(1);
            selectedCol = selected(2);
            
            obsInfo = self.dataStructure;
            obsInfo(self.sortingInds(selectedRow)).(self.tableFieldNames{selectedCol}) = cellData{selectedRow,selectedCol};
            self.dataStructure = obsInfo;
            
            self.updateDataStructure(obsInfo);
            self.updateTableDisplay;
            
            jUIScrollPane = findjobj(self.handleStruct.table);
            jUITable = jUIScrollPane.getViewport.getView;
            jUITable.changeSelection(selectedRow,selectedCol-1, false, false);
        end
        
        function appendDataStructure(self,obsInfo)
            if ~isempty(self.dataStructure)
                self.updateDataStructure(cat(1,obsInfo(:),self.dataStructure(:)));
            else
                self.updateDataStructure(obsInfo(:));
            end
        end
        
        function updateDataStructure(self,obsInfo)
            if nargin > 1
                obsInfo = obsInfo(:);
                self.dataStructure = obsInfo;
            end
            if ~isempty(self.dataStructure)
                self.tableFieldNames = fieldnames(self.dataStructure(:));
                self.dataCell = struct2cell(self.dataStructure(:))';
                
                if isempty(self.editableArray)
                    self.editableArray = false(1,size(self.dataCell,2));
                end
                
                set(self.handleStruct.table,'data',self.dataCell,...
                    'ColumnName',self.tableFieldNames,...
                    'ColumnEditable',self.editableArray,...
                    'ColumnWidth','auto','RearrangeableColumns','off',...
                    'RowStriping','off','RowName',cellstr(num2str((1:size(self.dataCell,1))')),...
                    'uicontextmenu',self.handleStruct.tableContextMenu,...
                    'CellSelectionCallback',@(src,evnt)set(src,'UserData',evnt.Indices),...
                    'CellEditCallback',@(src,event)self.updateDataStructureFromGui(src,event));
                
                if length(self.sortingInds) ~= numel(self.dataStructure)
                    self.sortingInds = [];
                end
                % I do not think we have to do this
                if isempty(self.sortingInds)
                    self.sortingInds = (1:size(self.dataCell,1))';
                end
                
                set(self.managedHandle,'ResizeFcn',@self.resizeFunction);
                resizeFunction(self);
                set(self.handleStruct.table,'visible','on');
            else
                set(self.handleStruct.table,'data',[],...
                    'ColumnName',self.tableFieldNames,...
                    'ColumnEditable',self.editableArray,...
                    'ColumnWidth','auto','RearrangeableColumns','off',...
                    'RowStriping','off','RowName',cellstr(num2str((1:size(self.dataCell,1))')),...
                    'uicontextmenu',self.handleStruct.tableContextMenu,...
                    'CellSelectionCallback',@(src,evnt)set(src,'UserData',evnt.Indices),...
                    'CellEditCallback',@(src,event)error('Not implemented'));
                
                self.sortingInds = [];
                
                set(self.managedHandle,'ResizeFcn',@self.resizeFunction);
                resizeFunction(self);
                set(self.handleStruct.table,'visible','on');
            end
        end
        
        function setValues(self,e,s)
            
            selected = get(self.handleStruct.table,'UserData');
            if isempty(selected)
                warndlg('No rows selected');
                return;
            end
            selectedRows = selected(:,1);
            
            strs = fieldnames(self.dataStructure);
            strOut = prtUiListDlg(strs);
            selectedColInd = strOut.enteredSelection;
            if isempty(selectedColInd) || selectedColInd == 0;
                warndlg('No field selected');
                return;
            end
            selectedColData = self.dataCell(:,selectedColInd);
            answer = inputdlg(sprintf('Please input a new value for field "%s" in the selected cells',strs{selectedColInd}));
            answer = answer{1};
            if isempty(answer)
                warndlg('No value entered');
                return;
            end
            if isnumeric(selectedColData{1})
                answer = str2double(answer);
                if isempty(answer)
                    warndlg('Improper numeric value provided');
                    return;
                end
            elseif islogical(selectedColData{1})
                answer = logical(str2double(answer));
                if isempty(answer)
                    warndlg('Improper numeric value provided');
                    return;
                end
            elseif isa(selectedColData{1},'char')
                if ~isa(answer,'char');
                    answer = num2str(answer);
                end
            end
            relativeInds = self.sortingInds(selectedRows);
            if ~isempty(answer)
                self.dataCell(relativeInds,selectedColInd) = {answer};
                for i = 1:length(relativeInds)
                    self.dataStructure(relativeInds(i)).(strs{selectedColInd}) = answer;
                end
            end
            
            self.updateTableDisplay;
        end
        
        
        function sortByStringSearch(self,e,s)
            strs = fieldnames(self.dataStructure);
            strOut = prtUiListDlg(strs);
            selectedColInd = strOut.enteredSelection;
            if isempty(selectedColInd) || selectedColInd == 0;
                return;
            end
            sortVecData = self.dataCell(:,selectedColInd);
            if isnumeric(sortVecData{1}) || islogical(sortVecData{1});
                warndlg('Numeric or logical field specified');
                return;
            end
            str = inputdlg('Input a search string, use * for wildcards');
            regexpStr = strrep(lower(str),'*','.*');
            
            found = regexp(lower(sortVecData),regexpStr);
            sortVecBool = cellfun(@(x)~isempty(x),found);
            [~,inds] = sort(~sortVecBool);
            self.sort(inds);
        end
        
        function sortBy(self,e,s)
            strs = fieldnames(self.dataStructure);
            strOut = prtUiListDlg(strs);
            selectedColInd = strOut.enteredSelection;
            if isempty(selectedColInd) || selectedColInd == 0;
                return;
            end
            sortVec = self.dataCell(:,selectedColInd);
            if isnumeric(sortVec{1}) || islogical(sortVec{1});
                sortVec = cat(1,sortVec{:});
            end
            [~,inds] = sort(sortVec);
            self.sort(inds);
        end
        
        function createColumn(self,h,e)
            
            answer=inputdlg('Enter a name for the new column','New Column Name');
            if isempty(answer)
                return;
            end
            varName = genvarname(answer{1});
            obsInfo = self.dataStructure;
            if isfield(obsInfo,varName);
                h = errordlg('%s is already a field of the database');
                uiwait(h);
                return
            end
            
            ButtonName = questdlg('Add a numeric or character?', ...
                'Numeric or Character', ...
                'Numeric', 'Character','Numeric');
            
            switch ButtonName
                case 'Numeric'
                    vals = repmat({nan},size(obsInfo));
                otherwise
                    vals = repmat({''},size(obsInfo));
            end
            for i = 1:length(obsInfo)
                obsInfo(i).(varName) = vals{i};
            end
            
            self.editableArray = [self.editableArray,true];
            self.updateDataStructure(obsInfo);
            self.updateTableDisplay;
        end
        
        function deleteSelectedRows(self,h,e,force)
            
            if nargin < 4
                force = false;
            end
            if ~force
                ButtonName = questdlg('Remove selected rows from database?', ...
                    'Clear Current?', ...
                    'Yes, erase', 'No, go back','No, go back');
            else
                ButtonName = 'Yes, erase';
            end
            switch ButtonName
                case '';
                    return;
                case 'No, go back'
                    return;
                otherwise
                    
                    selected = get(self.handleStruct.table,'UserData');
                    if isempty(selected)
                        warndlg('No rows selected');
                        return;
                    end
                    selectedRowsUnsorted = selected(:,1);
                    selectedRows = self.sortingInds(selectedRowsUnsorted);
                    selectedBool = false(size(self.dataStructure));
                    selectedBool(selectedRows) = true;
                    selectedBoolUnsorted = false(size(self.dataStructure));
                    selectedBoolUnsorted(selectedRowsUnsorted) = true;
                    
                    obsInfo = self.dataStructure(~selectedBool);
                    [~,~,ic] = unique(self.sortingInds(~selectedBoolUnsorted));
                    self.sortingInds = ic;
                    
                    self.updateDataStructure(obsInfo);
                    self.updateTableDisplay;
            end
        end
        
        function sort(self,inds)
            self.sortingInds = inds;
            self.updateTableDisplay;
        end
        
        
        function resizeFunction(self,varargin)
            
            rowHeightInPixels = self.fontSizeEdit*2; % A decent rule of thumb for edit boxes?
            %border = max(rowHeightInPixels/8,1); % A decent rule of thumb ?
            border = 0;
            
            parentPosPixels = getpixelposition(self.managedHandle);
            parentHeight = parentPosPixels(4);
            parentWidth = parentPosPixels(3);
            
            editPos = [1 parentHeight-rowHeightInPixels, parentWidth, rowHeightInPixels];
            
            % Re-adjust height of the uitable
            tableTopPixels = editPos(2)-border;
            tablePos = [1 1 parentWidth tableTopPixels-1];
            
            % Set everything
            set(self.handleStruct.table,'units','pixels'); % Reset below
            set(self.handleStruct.table,'position',tablePos);
            set(self.handleStruct.table,'units','normalized');
        end
        
        function updateTableDisplay(self)
            set(self.handleStruct.table,'Data',self.dataCell(self.sortingInds,:));
        end
    end
end
