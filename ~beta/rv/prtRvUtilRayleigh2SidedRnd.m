function y = prtRvUtilRayleigh2SidedRnd(sigma,N)
%y = rayl2sidedrnd(LIMS,N);
%	Draw N RV's from a 2-sided Rayleigh distribution with parameter sigma.

% Copyright 2011, New Folder Consulting, L.L.C.

y = raylrnd(sigma,N);
PN = sign(rand(N)-.5);
y = y.*PN;