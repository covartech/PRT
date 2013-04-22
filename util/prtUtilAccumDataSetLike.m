function [dsOut,uKeys] = prtUtilAccumDataSetLike(keys,ds,xFun,yFun)
% prtUtilAccumDataSetLike Accumulate across observations in a data set
%
% [xOut,uKeys] = prtUtilAccumArrayLike(keys,dataSet,xFun) aggregates
%  information across the observations specified by the unique values of
%  keys.  Keys should be a nObs x 1 vector or a cell array of strings.  The
%  resulting accumulated data set has length(unique(keys)) observations.
%  For each unique key, i, corresponding to indices "inds":
%
%    Each column (col) of the dataSet.X matrix is accumulated using
%       xOut(i,col) = xFun(X(inds,col))
%
%    The dataSet.Y vector is accumulated with the unique values of
%       yOut(i) = unique(dataSet.Y(inds)).  Note: by default
%       prtUtilAccumDataSetLike will error if you try to accumulate
%       information across observations with different targets (Y).
%
%    The resulting observationInfo is picked at random from one of the
%       dataSet.observationInfo(inds);
%
% [xOut,uKeys] = prtUtilAccumArrayLike(keys,dataSet,xFun,yFun) Enables
%   specification of the accumulation function for targets in addition to
%   data.
%   
%

sz = [];
if nargin < 3
    xFun = @(x)sum(x,1);
end
if nargin < 4
    yFun = @(x)unique(x);
end

[uKeys,specInds,uInds] = unique(keys);
xOut = nan(max(uInds),ds.nFeatures);
for i = 1:size(xOut,2)
    xOut(:,i) = accumarray(uInds,ds.X(:,i),sz,xFun);
end

if ds.isLabeled
    yOut = accumarray(uInds,ds.Y,sz,yFun);
else
    yOut = [];
end
dsOut = prtDataSetClass(xOut,yOut);

if ~isempty(ds.observationInfo);
    obsInfo = ds.observationInfo(specInds);
    dsOut.observationInfo = obsInfo;
end
