function cslCell = prtUtilStruct2cslCell(S)
% xxx Need Help xxx
% prtUtilStruct2cslCell converts a structure to a comma separated list cell
%
% Inputs:
%   S - a structure
%
% Outputs:
%   cslCell - A comma separated list cell
%
% Examples:
%   S.firstField = 'firstCellContents';
%   S.secondField = rand(5);
%   prtUtilStruct2cslCell(S)
%
% Author: Kenneth D. Morton Jr.
% Date Created: 05-Aug-2008








fnames = fieldnames(S);
cslCell = cell(1,2*length(fnames));
cslCell(1:2:(2*length(fnames)-1)) = fnames;
cslCell(2:2:2*length(fnames)) = struct2cell(S);

end
