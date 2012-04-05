classdef prtUtilActionDataAccess
    %
    % v = vpSourceVideoFile('videoFile','C:\Users\pete\Documents\data\video\intersections\bloggie\MAH00013.MP4','bufferSize',30);
    % f = v.read;
    % f = f.setActionData('keypointDescriptor','brief',randn(100,4));
    % f = f.setActionData('keypointDescriptor','patch',randn(100,10));
    % [vals,names,types] = f.findActionData('keypointDescriptor','all')
    %
    properties (Abstract)
        actionData
    end
    methods
        function self = setActionData(self,type,name,val)
            if strcmpi(name,'all')
                warning('You specified a reserved word (all) as a field in prtUtilActionDataAccess; you might have trouble getting that field back without some trickery');
            end
            self.actionData.(type).(name) = val;
        end
        
        function [output,name,type] = findActionData(self,type,name)
            switch nargin 
                case 1
                    output = fieldnames(self.actionData);
                    name = {};
                case 2
                    output = fieldnames(self.actionData.(type));
                    name = output;
                case 3
                    if strcmpi(name,'all')
                        name = fieldnames(self.actionData.(type));
                    else
                        name = {name};
                    end
                    output = cell(length(name),1);
                    for i = 1:length(name)
                        output{i} = self.actionData.(type).(name{i});
                    end
                otherwise
                    error('too many or few inputs');
            end
        end
    end
end