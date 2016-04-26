function Y = prtRvUtilLaplacePdf(X,mu,theta)
% Y = laplacepdf(X,mu,theta)







if numel(X) > length(X)
    error('X must have 1 singleton dimension')
end

Y = 1/(2*theta) * exp(-abs(X-mu)./theta);
