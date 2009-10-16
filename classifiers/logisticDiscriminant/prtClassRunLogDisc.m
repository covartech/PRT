function [ClassifierResults,Etc] = prtClassRunLogDisc(LogDisc,DS)
%[ClassifierResults,Etc] = runLogDisc(LogDisc,X)

Etc = [];

sigmaFn = @(x) 1./(1 + exp(-x));
x = cat(2,ones(size(DS.data,1),1),DS.data);
y = sigmaFn((x*LogDisc.w)')';

ClassifierResults = prtDataSet(y);