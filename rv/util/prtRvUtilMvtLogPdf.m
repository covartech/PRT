function y = prtRvUtilMvtLogPdf(x,mu,Sigma,dof)
% y = prtRvUtilMvtLogPdf(x,mu,Sigma,dof)
% xxx Need Help xxx







d = size(x,2);

[R,err] = cholcov(Sigma,0);
if err ~= 0
    error('mvtLogPdf:BadCovariance', ...
        'SIGMA must be symmetric and positive definite.');
end

% Create array of standardized data
xRinv = bsxfun(@minus,x,mu(:)') / R;

c = gammaln((d+dof)*0.5) - (d*0.5)*log(dof*pi) - gammaln(dof*0.5) - 0.5*log(det(Sigma));

y = c - (dof+d)*0.5*log(1 +1/dof*sum(xRinv.^2, 2));
