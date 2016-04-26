function X = prtRvUtilLaplaceRnd(mu,theta,N)
% X = laplacernd(mu,theta,N)







U = rand(N,1)-1/2;
X = mu - theta .* sign(U) .* log(1-2*abs(U));
