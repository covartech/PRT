function eq = prtUtilApproxEqual(x,y,eqThreshold)
%eq = prtUtilApproxEqual(x,y)
%   For same size matrix x and y (or scalar y), return true where abs(x-y) < eps
%
%eq = prtUtilApproxEqual(x,y,eqThreshold)
%   Use eqThreshold in place of eps
%
%







if nargin < 3
    eqThreshold = eps;
end

eq = (abs(x-y) < eqThreshold);
