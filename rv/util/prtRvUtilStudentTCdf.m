function y = prtRvUtilStudentTCdf(x,mu,Sigma,dof)
% y = studenttcdf(x,mu,Sigma,dof)







% This is what we might want to do. It's an approximation...
warning('This is not really a student T')
y = mvncdf(x ,mu,Sigma);

% mvtpdf scales Sigma to be 1s on the diagonal...
% we need to undo this...


