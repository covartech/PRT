function Y = prtRvUtilDirichletPdf(X,alpha)
% Y = dirichletpdf(X,alpha)







K = length(alpha);
if size(X,2) ~= K
    error('The number of columns of X and the length alpha must match.')
end

nSamples = size(X,1);

% This may be a little off
alpha(alpha==0) = eps;


logB = gammaln(sum(alpha))-sum(gammaln(alpha));
X(X == 0) = eps;
Y = exp(logB + sum((repmat(alpha,nSamples,1)-1).*log(X),2));
