function y = prtRvUtilGeneralizedGamma(x,d)
% GENERALIZEDGAMMA  The generalized gamma or multi-gamma function.
%
% Syntax: y = generalizedGamma(a,d)
%
% Input:
%   x - The value at which to evaluate the function
%   d - Thhe degree of the function
%
% Outputs:
%   y - The answer you are looking for







y = exp(prtRvUtilGeneralizedGammaLn(x,d));
