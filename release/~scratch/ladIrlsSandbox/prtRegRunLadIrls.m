function [Results,Etc] = prtRegRunLadIrls(LSLR,DS)
%Yout = prtRegRunLadIrls(LSLR,X)

X = DS.getObservations;
[N,p] = size(X);
X = cat(2,ones(N,1),X);
Results = DS.setObservations(X*LSLR.Beta);

Etc = [];