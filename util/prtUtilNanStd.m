function y = prtUtilNanStd(x,dim)
% prtUtilNanStd - Calculated the std. dev. of data, X, ignoring nans
% 
% y = prtUtilNanStd(x)
% y = prtUtilNanStd(x,dim)







if nargin < 2 || isempty(dim)
    dim = 1; % Default of sum
end

y = sqrt(prtUtilNanVar(x,dim));
