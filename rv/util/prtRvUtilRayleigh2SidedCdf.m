function y = prtRvUtilRayleigh2SidedCdf(X,sigma)
%y = rayl2sidedcdf(X,LIMS);
%	Return the CDF of a 2-sided Rayleigh distribution with parameter sigma.








y = zeros(size(X));
y(X < 0) = (1-raylcdf(abs(X(X<0)),sigma))./2;
y(X >= 0) = raylcdf(X(X>=0),sigma)./2 + 0.5;
