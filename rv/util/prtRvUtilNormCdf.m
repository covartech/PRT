function y = prtRvUtilNormCdf(x, mu, var)
% y = prtRvUtilNormCdf(x, mu, var)







if nargin < 2 || isempty(mu)
    mu = 0;
end

if nargin < 3 || isempty(var)
    var = 1;
end

if numel(mu) > 1 || numel(var) > 1
    error('prt:prtRvUtilNormCdf','prtRvUtilNormCdf is only for 1D normally distributioned data');
end

y = erfc(-(x-mu) ./ sqrt(2*var))/2;
