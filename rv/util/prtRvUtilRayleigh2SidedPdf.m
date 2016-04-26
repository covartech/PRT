function y = prtRvUtilRayleigh2SidedPdf(X,sigma)
%y = rayl2sidedpdf(X,LIMS);
%	Return the PDF of a 2-sided Rayleigh distribution with parameter sigma.








y = raylpdf(abs(X),sigma)./2;
