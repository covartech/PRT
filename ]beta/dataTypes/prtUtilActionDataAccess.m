classdef prtUtilActionDataAccess
    %
    % v = vpSourceVideoFile('videoFile','C:\Users\pete\Documents\data\video\intersections\bloggie\MAH00013.MP4','bufferSize',30);
    % f = v.read;
    % f = f.setActionData('keypointDescriptor','brief',randn(100,4));
    % f = f.setActionData('keypointDescriptor','patch',randn(100,10));
    % [vals,names,types] = f.findActionData('keypointDescriptor','all')
    %

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
    properties (Abstract)

        actionData
    end
    methods
        function self = setActionData(self,type,name,val)
            if strcmpi(name,'all')
                warning('prt:prtUtilActionDataAccess:all','You specified a reserved word (all) as a field in prtUtilActionDataAccess; you might have trouble getting that field back without some trickery');
            end
            self.actionData.(type).(name) = val;
        end
        
        function [output,name,type] = findActionData(self,type,name)
            switch nargin 
                case 1
                    output = fieldnames(self.actionData);
                    name = {};
                case 2
                    output = self.actionData.(type);
                    if isstruct(output)
                        name = fieldnames(output);
                    else
                        name = {};
                    end
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
