function y = prtRvUtilStudentTPdf(x,mu,Sigma,dof)
% y = studenttpdf(x,mu,Sigma,dof)

[n, d] = size(x);

c = gammaln((d+dof)*0.5) - (d*0.5)*log(dof*pi) - gammaln(dof*0.5) - 0.5*log(det(Sigma));

diff = (x - repmat(mu,n,1)).'; % d by n

logpdf = c - (dof+d)*0.5 * log(1 + sum(diff.*(inv(dof*Sigma)*diff),1));

y = exp(logpdf(:));