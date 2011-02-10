function ds = prtUtilStructToDataSetClass(S)
% PRTUTILSTRUCTTODATASETCLASS Make a prtDataSetClass from a structure array
% 
% Syntax: ds = prtUtilStructToDataSetClass(S)
%
%   S must be a vector structure array.
%   Each field of S must be a scalar numeric value.

assert(isstruct(S) && isvector(S),'S must be a structure vector array');

fnames = fieldnames(S);

nFeatures = length(fnames);
nObs = length(S);
ds = prtDataSetClass(nan(nObs,nFeatures));

for iFeature = 1:length(fnames)
    ds = ds.setObservations(cat(1,S.(fnames{iFeature})),:,iFeature);
end
    
ds = ds.setFeatureNames(fnames);