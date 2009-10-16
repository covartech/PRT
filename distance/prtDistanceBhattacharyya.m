function [d,m0,m1,C0,C1] = battacharyya(X,Y,varargin);
%[d,m0,m1,C0,C1] = battacharyya(X,Y,varargin);

H0 = X(Y == 0,:);
H1 = X(Y == 1,:);

m0 = mean(H0);
m1 = mean(H1);
C0 = cov(H0);
C1 = cov(H1);

warning off
logTerm = log( det((C1+C0)/2)./sqrt(det(C1)*det(C0)) );
warning on;
if isnan(logTerm) || logTerm < eps;
    logTerm = eps;
end

d = 1/8*(m1-m0)*((C1+C0)/2)^-1*(m1-m0)' + 1/2 * logTerm;