function [origPath,bigDataPath] = prtGraphDataDir
% [origPath,bigDataPath] = prtGraphDataDir
%   Return the path where the PRT stores graph data files.







totalPath = which(mfilename);
pathTo = fileparts(totalPath);

pathCell = prtUtilPathParts(pathTo);

origPath = fullfile(pathCell{1:end-1},'graphData');
bigDataPath = fullfile(origPath,'bigData');
