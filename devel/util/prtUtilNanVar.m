function y = prtUtilNanVar(x,dim)
% prtUtilNanVar - Calculated the variance of data, X, ignoring nans
% 
% y = prtUtilNanVar(x)
% y = prtUtilNanVar(x,dim)

if nargin < 2 || isempty(dim)
    dim = 1; % Default of sum
end

meanX = prtUtilNanMean(x,dim);
y = prtUtilNanMean(bsxfun(@minus,x,meanX).^2,dim)*size(x,dim)./(size(x,dim)-1); % Variance is normalized by n-1 not n;