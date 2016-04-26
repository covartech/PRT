function v = prtUtilCalcDiagXcInvXT(x,C)
%v = prtUtilCalcDiagXcInvXT(x,C)
%   Calculate diag(x*C^-1*x') without calculating the entire matrix.
%
%   If you want to run a bunch of:
%       x(i,:) * C^-1 * x(i,:)'
%
%   By default x*C^-1*x' makes a size(x,1) x size(x,1) matrix, but you
%   really just want each of the diagonal elements.  Also, this avoids
%   calculating inverses.
%







v = sum((x/cholcov(C)).^2,2);
