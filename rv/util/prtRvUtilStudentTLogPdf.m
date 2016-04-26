function y = prtRvUtilStudentTLogPdf(x,mu,Sigma,dof)
% y = prtRvUtilStudentTLogPdf(x,mu,Sigma,dof)







[n, d] = size(x);

c = gammaln((d+dof)*0.5) - (d*0.5)*log(dof*pi) - gammaln(dof*0.5) - 0.5*prtUtilLogDet(Sigma);

diff = bsxfun(@minus,x,mu);

logpdf = c - (dof+d)*0.5 * log(1 + (1/dof)*sum((diff/chol(Sigma)).^2,2));
%logpdf = c - (dof+d)*0.5 * log(1 + sum(diff.*(inv(dof*Sigma)*diff),1));

y = logpdf(:);
