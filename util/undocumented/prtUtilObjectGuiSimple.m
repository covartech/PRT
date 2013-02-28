function [output, creationString] = prtUtilObjectGuiSimple(obj)
% PRTUTILOBJECTGUISIMPLE Provides a graphical method to change an object
%
% Syntax: prtUtilStructureGui(BaseStructure,DefaultStructure,DefinitionStructure)
%
% Internal
% xxx Need Help xxx

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



% Numberic types bounds etc do not work
newFunctionOutput = [];

% Create default creationString
if isstruct(obj)
    guiPropNames = fieldnames(obj);
    name = inputname(1);
else
    thisClass = class(obj);
    m = meta.class.fromName(thisClass);
    name = thisClass;

    isInThisClass = cellfun(@(c)strcmp(c.DefiningClass.Name,thisClass),m.Properties);
    isSetable = cellfun(@(c)strcmp(c.SetAccess,'public'),m.Properties);
    isHidden = cellfun(@(c)c.Hidden,m.Properties);
    provideInGui = isInThisClass & ~isHidden & isSetable;
    
    GuiProperties = m.Properties(provideInGui);
    
    nGuiProperties = length(GuiProperties);
    % Create default structure
    
    if nGuiProperties == 0
        msgbox(sprintf('%s has no properties that can be set using this GUI.',name),'No Properties','modal');
        output = obj;
        creationString = sprintf('%s()',class(obj));
        
        return
    end
    
    guiPropNames = cellfun(@(c)c.Name,GuiProperties,'uniformoutput',false);
end

guiPropValues = cell(nGuiProperties,1);
for iProp = 1:nGuiProperties
    guiPropValues{iProp} = obj.(guiPropNames{iProp});
end

% Determine types of each field in DefaultStructure
%   This is rather difficult to do robustly
%   The if else try below is just hueristic
types = cell(length(guiPropValues),1);
for iProp = 1:length(guiPropValues)
    cVal = guiPropValues{iProp};
    
    if isnumeric(cVal) || islogical(cVal)
        types{iProp} = 'numeric';
                
    elseif ischar(cVal)
        types{iProp} = 'char';
        
    elseif isstruct(cVal);
        types{iProp} = 'structure';
        
    elseif isa(cVal,'function_handle')
        types{iProp} = 'function';
        
    else
        % Not a default MATLAB data type
        % Use the structure version to iteratively call this function
        types{iProp} = 'structure';
        
    end
end

% At this point we can't handle sub-objects or sub-structures
% So we remove them from the GUI
removeFields = strcmpi(types,'structure');
guiPropNames = guiPropNames(~removeFields);
guiPropValues = guiPropValues(~removeFields);
types = types(~removeFields);

nGuiProperties = length(guiPropValues);

structInputs = cell(nGuiProperties*2,1);
structInputs(1:2:end) = guiPropNames;
structInputs(2:2:end) = guiPropValues;
DefaultStructure = struct(structInputs{:});

OutputStructure = DefaultStructure;
BaseStructure = DefaultStructure;

%backgroundColor = get(0,'defaultFigureColor');
backgroundColor = [0.95 0.95 0.95];

DefaultMainPanelOptions.style = 'panel';
DefaultMainPanelOptions.units = 'normalized';
DefaultMainPanelOptions.position = [0.01 0.1 0.98 0.89];
DefaultMainPanelOptions.title = '';
DefaultMainPanelOptions.borderType = 'none';
DefaultMainPanelOptions.backgroundColor = backgroundColor;


MainPanelOptions = DefaultMainPanelOptions;

% Default MainFigureOptions
ss = get(0,'screensize');

windowSize = [754 600];

% Center the window
sizePads = round((ss(3:4)-windowSize));
sizePads(1) = sizePads(1)/2; % We should use 2 right?
sizePads(2) = sizePads(2)/2;
pos = cat(2,sizePads,windowSize);

DefaultMainFigureOptions.style = 'figure';
DefaultMainFigureOptions.units = 'pixels';        
DefaultMainFigureOptions.position = pos;
DefaultMainFigureOptions.menuBar = 'none';
DefaultMainFigureOptions.toolbar = 'none';
DefaultMainFigureOptions.numberTitle = 'off';
DefaultMainFigureOptions.name = cat(2,'PRT Action Editor - ',name);
DefaultMainFigureOptions.color = backgroundColor;
DefaultMainFigureOptions.windowStyle = 'modal';
DefaultMainFigureOptions.CloseRequestFcn = @cancelCallback;
DefaultMainFigureOptions.backingstore = 'off';
DefaultMainFigureOptions.DoubleBuffer = 'off';

MainFigureOptions = DefaultMainFigureOptions;

% Finish making the primary elements of the gui
MainFigureOptions.Children.MainPanel = MainPanelOptions;

buttonHeight = 0.06;
MainFigureOptions.Children.Apply.style = 'pushbutton';
MainFigureOptions.Children.Apply.units = 'normalized';
MainFigureOptions.Children.Apply.position = [0.2550 0.02 0.23 buttonHeight];%[0.1 0.02 0.23 0.06];
MainFigureOptions.Children.Apply.string = 'Accept';
MainFigureOptions.Children.Apply.callback = @applyCallback;

MainFigureOptions.Children.Defaults.style = 'pushbutton';
MainFigureOptions.Children.Defaults.units = 'normalized';
MainFigureOptions.Children.Defaults.position = [0.5350 0.02 0.23 buttonHeight];%[0.38 0.02 0.23 0.06];
MainFigureOptions.Children.Defaults.string = 'Restore Defaults';
MainFigureOptions.Children.Defaults.callback = @defaultCallback;

% MainFigureOptions.Children.Cancel.style = 'pushbutton';
% MainFigureOptions.Children.Cancel.units = 'normalized';
% MainFigureOptions.Children.Cancel.position = [0.66 0.02 0.23 0.06];
% MainFigureOptions.Children.Cancel.string = 'Cancel';
% MainFigureOptions.Children.Cancel.callback = @cancelCallback;

%%

GuiInfo.usableVerticalRange = [0.1 0.85];
GuiInfo.label.horizontal = [0.01 0.32];
GuiInfo.value.horizontal = [0.34 0.65];
GuiInfo.edit.horizontal = [0.67 0.99];

GuiInfo.maxHeight = 0.05;

%% Create the field boxes

fields = fieldnames(BaseStructure);
nFields = length(fields);

itemHeight = min((GuiInfo.usableVerticalRange(2)-GuiInfo.usableVerticalRange(1))./(nFields+(nFields-1)/2), GuiInfo.maxHeight);

if itemHeight==GuiInfo.maxHeight
    % Things are maxed out in size. 
    % So we resize the window to make it look nice.
    newWindowHeight = (itemHeight*nFields + GuiInfo.usableVerticalRange(1) + (1-GuiInfo.usableVerticalRange(2)))*windowSize(2);
    
    itemHeight = itemHeight*windowSize(2)/newWindowHeight;
    
    buttonHeight = buttonHeight*windowSize(2)/newWindowHeight;
    
    MainFigureOptions.Children.Apply.position(4) = buttonHeight;
    MainFigureOptions.Children.Defaults.position(4) = buttonHeight;
    
    windowSize(2) = newWindowHeight;
    
    sizePads = round((ss(3:4)-windowSize));
    sizePads(1) = sizePads(1)/2; % We should use 2 right?
    sizePads(2) = sizePads(2)/2;
    pos = cat(2,sizePads,windowSize);
    
    MainFigureOptions.position = pos;
end

bottom = max(GuiInfo.usableVerticalRange(1),mean(GuiInfo.usableVerticalRange) - itemHeight*nFields/2 - (nFields-1)/2*itemHeight/2);

verticalStarts = fliplr(bottom + cumsum([0 0.5*ones(1,nFields-1)])*itemHeight + (0:(nFields-1))*itemHeight);

if length(verticalStarts) > 1
    editOffSet = [0 (verticalStarts(1)-verticalStarts(2)-itemHeight)/2 -0.01 0];
else
    editOffSet = [0 itemHeight/4 -0.01 0];
end

fontSize = 9;



for iField = 1:nFields
    
    %if mod(iField,2)
        %cBackgroundColor = max(MainPanelOptions.backgroundColor-0.05,[0 0 0]);
    %else
        cBackgroundColor = MainPanelOptions.backgroundColor;
    %end
    
    % Label string area
    MainFigureOptions.Children.MainPanel.Children.(['label' fields{iField}]).style = 'text';
    MainFigureOptions.Children.MainPanel.Children.(['label' fields{iField}]).units = 'normalized';
    MainFigureOptions.Children.MainPanel.Children.(['label' fields{iField}]).position = [GuiInfo.label.horizontal(1) verticalStarts(iField) GuiInfo.label.horizontal(2)-GuiInfo.label.horizontal(1) itemHeight];
    MainFigureOptions.Children.MainPanel.Children.(['label' fields{iField}]).fontweight = 'bold';
    MainFigureOptions.Children.MainPanel.Children.(['label' fields{iField}]).horizontalAlignment = 'right';
    MainFigureOptions.Children.MainPanel.Children.(['label' fields{iField}]).backgroundcolor = cBackgroundColor;
    MainFigureOptions.Children.MainPanel.Children.(['label' fields{iField}]).string = [guiPropNames{iField}  ':'];

    % Value string area
    MainFigureOptions.Children.MainPanel.Children.(['value' fields{iField}]).style = 'text';
    MainFigureOptions.Children.MainPanel.Children.(['value' fields{iField}]).units = 'normalized';
    MainFigureOptions.Children.MainPanel.Children.(['value' fields{iField}]).position = [GuiInfo.value.horizontal(1) verticalStarts(iField) GuiInfo.value.horizontal(2)-GuiInfo.value.horizontal(1) itemHeight];
    MainFigureOptions.Children.MainPanel.Children.(['value' fields{iField}]).horizontalAlignment = 'left';
    MainFigureOptions.Children.MainPanel.Children.(['value' fields{iField}]).backgroundcolor = cBackgroundColor;
    
        
    % Crerate the uicontrol object
    switch types{iField}
        case 'numeric'
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).style = 'edit';
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).units = 'normalized';
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).position = [GuiInfo.edit.horizontal(1) verticalStarts(iField) GuiInfo.edit.horizontal(2)-GuiInfo.edit.horizontal(1) itemHeight]+editOffSet;
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).callback = {@numericCallback fields{iField}};
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).fontSize = fontSize;
            
        case 'char'
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).style = 'edit';
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).units = 'normalized';
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).position = [GuiInfo.edit.horizontal(1) verticalStarts(iField) GuiInfo.edit.horizontal(2)-GuiInfo.edit.horizontal(1) itemHeight]+editOffSet;
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).callback = {@charCallback fields{iField}};
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).fontSize = fontSize;
            
        case 'function'
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).style = 'edit';
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).units = 'normalized';
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).position = [GuiInfo.edit.horizontal(1) verticalStarts(iField) GuiInfo.edit.horizontal(2)-GuiInfo.edit.horizontal(1) itemHeight]+editOffSet;
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).callback = {@functionCallback fields{iField}};
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).fontSize = fontSize;

        case 'boolean'
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).style = 'checkbox';
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).units = 'normalized';
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).position = [GuiInfo.edit.horizontal(1)+(GuiInfo.edit.horizontal(2)-GuiInfo.edit.horizontal(1))/2.25 verticalStarts(iField)+itemHeight/2 (GuiInfo.edit.horizontal(2)-GuiInfo.edit.horizontal(1))/4 itemHeight-itemHeight/3]; %[GuiInfo.edit.horizontal(1) verticalStarts(iField) GuiInfo.edit.horizontal(2)-GuiInfo.edit.horizontal(1) itemHeight];
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).callback = {@booleanCallback fields{iField}};
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).string = '';
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).backgroundColor = backgroundColor;
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).fontSize = fontSize;
            
        case 'structure'
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).style = 'pushbutton';
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).units = 'normalized';
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).position = [GuiInfo.edit.horizontal(1) verticalStarts(iField) GuiInfo.edit.horizontal(2)-GuiInfo.edit.horizontal(1) itemHeight]+editOffSet;
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).callback = {@structureCallback fields{iField}};
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).string = 'More Options';
            MainFigureOptions.Children.MainPanel.Children.(['edit' fields{iField}]).fontSize = fontSize;
    end
    
    MainFigureOptions.Children.MainPanel.Children.(['hline' num2str(iField)]).style = 'frame';
    MainFigureOptions.Children.MainPanel.Children.(['hline' num2str(iField)]).units = 'normalized';
    MainFigureOptions.Children.MainPanel.Children.(['hline' num2str(iField)]).position = [GuiInfo.label.horizontal(1) verticalStarts(iField) GuiInfo.edit.horizontal(2)-GuiInfo.label.horizontal(1) 1];
end

MainFigureOptions.Children.MainPanel.Children.('vline1').style = 'frame';
MainFigureOptions.Children.MainPanel.Children.('vline1').units = 'normalized';
MainFigureOptions.Children.MainPanel.Children.('vline1').position = [GuiInfo.label.horizontal(1) min(verticalStarts) 1 max(verticalStarts)-min(verticalStarts)+itemHeight*3/2];

MainFigureOptions.Children.MainPanel.Children.('vline2').style = 'frame';
MainFigureOptions.Children.MainPanel.Children.('vline2').units = 'normalized';
MainFigureOptions.Children.MainPanel.Children.('vline2').position = [mean([GuiInfo.label.horizontal(2) GuiInfo.value.horizontal(1)]) min(verticalStarts) 1 max(verticalStarts)-min(verticalStarts)+itemHeight*3/2];

MainFigureOptions.Children.MainPanel.Children.('vline3').style = 'frame';
MainFigureOptions.Children.MainPanel.Children.('vline3').units = 'normalized';
MainFigureOptions.Children.MainPanel.Children.('vline3').position = [mean([GuiInfo.value.horizontal(2) GuiInfo.edit.horizontal(1)]) min(verticalStarts) 1 max(verticalStarts)-min(verticalStarts)+itemHeight*3/2];

MainFigureOptions.Children.MainPanel.Children.('vline4').style = 'frame';
MainFigureOptions.Children.MainPanel.Children.('vline4').units = 'normalized';
MainFigureOptions.Children.MainPanel.Children.('vline4').position = [GuiInfo.edit.horizontal(2) min(verticalStarts) 1 max(verticalStarts)-min(verticalStarts)+itemHeight*3/2];

MainFigureOptions.Children.MainPanel.Children.(['hline' num2str(nFields+1)]).style = 'frame';
MainFigureOptions.Children.MainPanel.Children.(['hline' num2str(nFields+1)]).units = 'normalized';
MainFigureOptions.Children.MainPanel.Children.(['hline' num2str(nFields+1)]).position = [GuiInfo.label.horizontal(1) max(verticalStarts)+itemHeight*3/2 GuiInfo.edit.horizontal(2)-GuiInfo.label.horizontal(1) 1];

Handles = prtUtilSuicontrol(MainFigureOptions);

set(Handles.handle,'windowStyle','normal');

% Set the lines which are actually frames to have a width of 1 pixel
for iV = 1:4
    v = getpixelposition(Handles.MainPanel.(['vline' num2str(iV)]));
    setpixelposition(Handles.MainPanel.(['vline' num2str(iV)]),[v(1) v(2) 1 v(4)]);
end

for iField = 1:nFields+1
   v = getpixelposition(Handles.MainPanel.(['hline' num2str(iField)])); 
   setpixelposition(Handles.MainPanel.(['hline' num2str(iField)]),[v(1) v(2) v(3) 1]); 
end


modifiedProperties = false(nFields,1);
modifiedValues = cell(nFields,1);

updateValueFields;
updateEditFields;

uiwait(Handles.handle)

% Now that OutputStructure is set we need to set the values
modifiedValues = modifiedValues(modifiedProperties);
modifiedNames = guiPropNames(modifiedProperties);

output = obj;
for iProp = 1:length(modifiedNames)
    output.(modifiedNames{iProp}) = OutputStructure.(modifiedNames{iProp});
end

if isstruct(obj)
    creationString = '';
else
    creationString = sprintf('%s(',class(obj));
    for iProp = 1:length(modifiedNames)
        creationString = cat(2,creationString,'''',modifiedNames{iProp},''',',modifiedValues{iProp},',');
    end
    if strcmpi(creationString(end),',');
        creationString = creationString(1:(end-1));
    end
    creationString = cat(2,creationString,')');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function numericCallback(myHandles,eventData,fieldName) %#ok

        shouldRevert = false;
        newNumber = [];
        try
            eval(sprintf('newNumber = %s;',get(myHandles,'string')))
        catch ME %#ok<NASGU>
            errordlg('This is not valid MATLAB syntax for a numeric value.','Invalid numeric value.','modal')
            shouldRevert = true;
        end

        try
            objTest = obj;
            objTest.(fieldName) = newNumber;
        catch ME
            errordlg(ME.message,'modal')
            shouldRevert = true;
        end
        
        if shouldRevert
            updateEditFields;
        else
            
            propInd = find(strcmp(guiPropNames,fieldName),1,'first');
            modifiedProperties(propInd) = true;
            modifiedValues{propInd} = get(myHandles,'string');
            
            OutputStructure.(fieldName) = newNumber;
            updateValueFields;
            updateEditFields;
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function charCallback(myHandles,eventData,fieldName) %#ok

        shouldRevert = false;
        newString = [];
        try
            eval(sprintf('newString = ''%s'';',get(myHandles,'string')))
        catch ME %#ok<NASGU>
            errordlg('This is not valid MATLAB syntax for a string value.','Invalid string','modal')
            shouldRevert = true;
        end

        try
            objTest = obj;
            objTest.(fieldName) = newString;
        catch ME
            errordlg(ME.message,'modal')
            shouldRevert = true;
        end
        
        if shouldRevert
           updateEditFields;
        else
            propInd = find(strcmp(guiPropNames,fieldName),1,'first');
            modifiedProperties(propInd) = true;
            modifiedValues{propInd} = get(myHandles,'string');
            
            OutputStructure.(fieldName) = newString;
            updateValueFields;
            updateEditFields;
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function functionCallback(myHandles,eventData,fieldName) %#ok

        shouldRevert = false;
        
        cString = get(myHandles,'string');
        if length(cString) < 1
            errordlg('This is not valid MATLAB syntax for a function.','Invalid function','modal');
            shouldRevert = true;
        end
        
        if ~shouldRevert 
            try
                eval(sprintf('newFunctionOutput = %s;',cString));
                
                try
                    objTest = obj;
                    objTest.(fieldName) = newFunctionOutput;
                catch ME
                    errordlg(ME.message,'modal')
                    shouldRevert = true;
                end
                
            catch ME %#ok<NASGU>
                errordlg('This is not valid MATLAB syntax for a function.','Invalid function','modal')
                shouldRevert = true;
            end
        end
        
        if shouldRevert
            updateEditFields;
        else
            propInd = find(strcmp(guiPropNames,fieldName),1,'first');
            modifiedProperties(propInd) = true;
            modifiedValues{propInd} = cString;
            
            OutputStructure.(fieldName) = eval(cString);
            updateValueFields;
            updateEditFields;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     function structureCallback(myHandles,eventData,fieldName) %#ok
% 
%         %newMainFigureOptions = rmfield(newMainFigureOptions,'CloseRequestFcn'); % This is really important. We will need the handle to the newly create cancelCallback not this one.
%         %newMainPanelOptions = MainPanelOptions;
%         
%         [OutputStructure.(fieldName), subCreationString] = prtUtilObjectGuiSimple(OutputStructure.(fieldName));
%         
%         updateValueFields;
%         updateEditFields;
% 
%     end
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function booleanCallback(myHandles,eventData,fieldName) %#ok

        OutputStructure.(fieldName) = get(myHandles,'value');

        propInd = find(strcmp(guiPropNames,fieldName),1,'first');
        modifiedProperties(propInd) = true;
        if OutputStructure.(fieldName)
            modifiedValues{propInd} = 'true';
        else
            modifiedValues{propInd} = 'false';
        end
        
        updateValueFields;
        updateEditFields;
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function defaultCallback(myHandles,eventdata) %#ok

        OutputStructure = DefaultStructure;

        updateValueFields;
        updateEditFields;

    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function cancelCallback(myHandles,eventdata) %#ok
        
        set(Handles.handle,'visible','off');
        
        OutputStructure = BaseStructure;

        delete(Handles.handle);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function applyCallback(myHandles,eventdata) %#ok
        delete(Handles.handle);
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function updateValueFields
        for jField = 1:nFields
            switch types{jField}
                case 'numeric'
                    set(Handles.MainPanel.(['value' fields{jField}]),'string',mat2str(OutputStructure.(fields{jField})));
                case 'char'
                    set(Handles.MainPanel.(['value' fields{jField}]),'string',OutputStructure.(fields{jField}));
                case 'function'
                    set(Handles.MainPanel.(['value' fields{jField}]),'string',func2str(OutputStructure.(fields{jField})));
                case 'boolean'
                    trueFalse = {'False','True'};
                    set(Handles.MainPanel.(['value' fields{jField}]),'string',trueFalse{OutputStructure.(fields{jField})+1});
                case 'structure'
                    set(Handles.MainPanel.(['value' fields{jField}]),'string','To view and edit additional parameters use the button to the right.');

            end
        end
    end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function updateEditFields
        for jField = 1:nFields
            switch types{jField}
                case 'numeric'
                    set(Handles.MainPanel.(['edit' fields{jField}]),'string',mat2str(OutputStructure.(fields{jField})));
                case 'char'
                    set(Handles.MainPanel.(['edit' fields{jField}]),'string',OutputStructure.(fields{jField}));
                case 'function'
                   set(Handles.MainPanel.(['edit' fields{jField}]),'string',func2str(OutputStructure.(fields{jField})));
                case 'boolean'
                    set(Handles.MainPanel.(['edit' fields{jField}]),'value',OutputStructure.(fields{jField}));
                case 'structure'
                    % We shouldn't have to do anything.
            end
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
end
