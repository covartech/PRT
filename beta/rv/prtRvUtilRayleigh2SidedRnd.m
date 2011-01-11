function y = prtRvUtilRayleigh2SidedRnd(sigma,N)
%y = rayl2sidedrnd(LIMS,N);
%	Draw N RV's from a 2-sided Rayleigh distribution with parameter sigma.

% Author: Peter Torrione
% Revised by: 
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: 14-March-2007
% Last revision:

y = raylrnd(sigma,N);
PN = sign(rand(N)-.5);
y = y.*PN;