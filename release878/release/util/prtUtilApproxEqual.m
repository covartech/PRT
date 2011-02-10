function eq = prtUtilApproxEqual(x,y,eqThreshold)
% xxx Need Help xxx
%eq = prtUtilApproxEqual(x,y)
%   Returns true when all elements of x and y are within eps of one
%   another.
%
%

if nargin < 3
    eqThreshold = eps;
end

eq = all(abs(x-y) < eqThreshold);