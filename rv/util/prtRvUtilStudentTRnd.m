function x = prtRvUtilStudentTRnd(mu,Sigma,dof,N)
% x = studenttrnd(mu,Sigma,dof,N)







warning('This is not really a student T')

x = mvnrnd(mu,Sigma,N);
