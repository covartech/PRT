function [xOut,uKeys] = prtUtilAccumArrayLike(keys,varargin)
% prtUtilAccumArrayLike similar to accumarray, but use keys
%
% [xOut,uKeys] = prtUtilAccumArrayLike(keys,...)
%   Behaves just like accumarray (see the MATLAB documentation), but
%   operates based on the unique values in 'keys', instead of treating
%   'keys' as direct indices.
%
%   For example:
%     out = prtUtilAccumArrayLike({'a','a','b','c','b','c'},...);
%   Is the equivalent of:
%     out = accumarray([1 1 2 3 2 3],...);
%   

[uKeys,~,uInds] = unique(keys);
xOut = accumarray(uInds,varargin{:});