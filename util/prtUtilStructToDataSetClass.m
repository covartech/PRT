function ds = prtUtilStructToDataSetClass(S)
% PRTUTILSTRUCTTODATASETCLASS Make a prtDataSetClass from a structure array
%   The contents of the structure are set as the observation info with
%   empty observations and targets;
%
% Syntax: ds = prtUtilStructToDataSetClass(S)
%
%   S must be a vector structure array.
%   Each field of S specified as a datafField must be a scalar numeric value.







assert(isstruct(S) && isvector(S),'S must be a structure vector array');

nFeatures = 1;
nObs = length(S);
ds = prtDataSetClass(nan(nObs,nFeatures));

ds.observationInfo = S;
