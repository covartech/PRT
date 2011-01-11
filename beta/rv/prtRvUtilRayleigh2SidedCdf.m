function y = prtRvUtilRayleigh2SidedCdf(X,sigma)
%y = rayl2sidedcdf(X,LIMS);
%	Return the CDF of a 2-sided Rayleigh distribution with parameter sigma.

% Author: Peter Torrione
% Revised by: 
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: 14-March-2007
% Last revision:

y = zeros(size(X));
y(X < 0) = (1-raylcdf(abs(X(X<0)),sigma))./2;
y(X >= 0) = raylcdf(X(X>=0),sigma)./2 + 0.5;