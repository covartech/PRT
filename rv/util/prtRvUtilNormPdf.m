function y = prtRvUtilNormPdf(X,mu,sigma)
%Y = prtRvUtilNormPdf(X,mu,sigma)
%Y = prtRvUtilNormPdf(X)
%Y = prtRvUtilNormPdf(X,mu)







% Test Drop in replacement of normpdf from stats toolbox
% X = randn([2 3 3]); mu = 1; sigma = 2; prtUtilApproxEqual(prtRvUtilNormPdf(X,mu,sigma),normpdf(X,mu,sigma))

if nargin < 2 %|| isempty(mu) % normpdf returns [] if mu is []
    mu = 0;
end

if nargin < 3 %|| isempty(sigma) % normpdf returns [] if sigma is []
    sigma = 1;
end

xSize = size(X);

y = reshape(exp(prtRvUtilMvnLogPdf(X(:), mu, sigma.^2)),xSize);

