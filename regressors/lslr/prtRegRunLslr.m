function [Results,Etc] = prtRegRunLslr(LSLR,DS)
%Yout = prtRegRunLslr(LSLR,X)

% Izenman, Modern Multivariate Statistical Techniques, p. 107-111

X = DS.getObservations;
[N,p] = size(X);
X = cat(2,ones(N,1),X);
Results = DS.setObservations(X*LSLR.Beta);

Etc = [];