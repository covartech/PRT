function h = prtUtilSuicontrol(S)
% SUICONTROL defines uicontrol objects through a structure
%   S must have the field "style" which specifieds the type of uicontrol
%   'figure' and 'panel' are special cases of style which allow for
%   Children to be specified. This allows for the creation of an entire GUI
%   From one call of this function. See the example bellow.
%
% Inputs:
%   S - A structure in which the field names correspond to the parameter
%       names of the uicontrols
%
% Outputs:
%   h - The handle to the create uicontrol or uipanel
%
% Examples:
%   MainFigure.style = 'figure';
%   MainFigure.units = 'normalized';
%   MainFigure.position = [0.25 0.25 0.5 0.5];
%   MainFigure.Children.MainPanel.style = 'panel';
%   MainFigure.Children.MainPanel.units = 'normalized';
%   MainFigure.Children.MainPanel.position = [0.1 0.1 0.8 0.8];
%   MainFigure.Children.MainPanel.Children.closeButton.style = 'pushbutton';
%   MainFigure.Children.MainPanel.Children.closeButton.callback = @(hObject,eventData)close(gcf);
%   MainFigure.Children.MainPanel.Children.closeButton.string = 'Close';
%   MainFigure.Children.MainPanel.Children.closeButton.units = 'normalized';
%   MainFigure.Children.MainPanel.Children.closeButton.position = [0.25 0.25 0.5 0.5];
%
%   H = prtUtilSuicontrol(MainFigure);
%
% Author: Kenneth D. Morton Jr.
% Date Created: 05-Aug-2008







assert(isfield(S,'style'),'The structure must specifiy the style of uicontrol.');

inS = S;
shouldDrawNow = false;
if isfield(S,'drawnow')
    shouldDrawNow = S.drawnow;
    S = rmfield(S,'drawnow');
end


% A special case for figure
switch lower(S.style)
    case 'figure'
        S = rmfield(S,'style');
        if isfield(S,'Children')
            S = rmfield(S,'Children');
        end
        cslCell = prtUtilStruct2cslCell(S);
        h = figure(cslCell{:});

    case 'panel'
        S = rmfield(S,'style');
        if isfield(S,'Children')
            S = rmfield(S,'Children');
        end
        if isfield(S,'parent')
            parent = S.parent;
            cslCell = prtUtilStruct2cslCell(rmfield(S,'parent'));
            h = uipanel(parent,cslCell{:});
        else
            cslCell = prtUtilStruct2cslCell(S);
            h = uipanel(cslCell{:});
        end
    case 'axes'
        S = rmfield(S,'style');
        if isfield(S,'Children')
            S = rmfield(S,'Children');
        end
%         if isfield(S,'parent')
%             S = rmfield(S,'parent');
%         end
 
        cslCell = prtUtilStruct2cslCell(S);
        h = axes(cslCell{:});
    case 'table'
        S = rmfield(S,'style');
        if isfield(S,'Children')
            S = rmfield(S,'Children');
        end
        cslCell = prtUtilStruct2cslCell(S);
        h = uitable(cslCell{:});

    otherwise % A uicontrol, if not then let uicontrol spit the error
        if isfield(S,'parent')
            parent = S.parent;
            cslCell = prtUtilStruct2cslCell(rmfield(S,'parent'));
            h = uicontrol(parent,cslCell{:});
        else
            cslCell = prtUtilStruct2cslCell(S);
            h = uicontrol(cslCell{:});
        end
end

% Children were specified
if isfield(inS,'Children')
    childrenNames = fieldnames(inS.Children);
    oldh = h;
    h = struct;
    h.handle = oldh; % Save the just created handle in the handle structure
    for iChild = 1:length(childrenNames)
        cS = inS.Children.(childrenNames{iChild});
        cS.parent = h.handle;
        h.(childrenNames{iChild}) = prtUtilSuicontrol(cS);
    end
end

if shouldDrawNow
    drawnow;
end
