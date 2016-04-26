function pathCell = prtUtilPathParts(pathIn)
%pathCell = prtUtilPathParts(pathIn)
%   Return the path parts of the file or path in pathIn as a cell array.
%
%   pathParts('C:\Users\pt\Documents\MATLAB\programs_projects\LibsGui\libsGui.m')







pathCell = regexp(pathIn,filesep,'split');
