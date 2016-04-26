function Y = prtRvUtilLaplaceCdf(X,mu,theta)
% Y = laplacecdf(X,mu,theta)







if numel(X) > length(X)
    error('X must have 1 singleton dimension')
end
Y = zeros(size(X));

Y(X>=mu) = 1-1/2*exp(-(X(X>=mu)-mu)./theta);
Y(X<mu) = 1/2*exp((X(X<mu)-mu)./theta);
