function y = prtUtilNanMean(x,dim)
% prtUtilNanMean - Calculated the mean of data, X, ignoring nans
% 
% y = prtUtilNanMean(x)
% y = prtUtilNanMean(x,dim)

if nargin < 2 || isempty(dim)
    dim = 1; % Default of sum
end

nanBool = isnan(x);
x(nanBool) = 0;
nNonNans = sum(~nanBool,dim);
nNonNans(nNonNans==0) = NaN;

y = sum(x,dim)./ nNonNans;
