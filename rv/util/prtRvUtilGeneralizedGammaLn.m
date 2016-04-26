function lny = prtRvUtilGeneralizedGammaLn(x,d)
% prtRvUtilGeneralizedGammaLn  The natural log of the generalized gamma or 
%   multi-gamma function.
%
% Syntax: lny = generalizedGammaLn(x,d)
%
% Input:
%   x - The value at which to evaluate the function
%   d - Thhe degree of the function
%
% Outputs:
%   y - The answer you are looking for







lnprodTerm = 0;
for j = 1:d
    lnprodTerm = lnprodTerm + gammaln((2*x-j+1)/2);
end

lny = (d*(d-1)/4)*log(pi) + lnprodTerm;
