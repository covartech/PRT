function y = prtRvUtilRayleigh2SidedPdf(X,sigma)
%y = rayl2sidedpdf(X,LIMS);
%	Return the PDF of a 2-sided Rayleigh distribution with parameter sigma.

% Author: Peter Torrione
% Revised by: 
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: 14-March-2007
% Last revision:

y = raylpdf(abs(X),sigma)./2;