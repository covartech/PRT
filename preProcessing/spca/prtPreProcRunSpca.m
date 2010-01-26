function [Results,Etc] = prtPreProcRunSpca(SPCA,PrtDataSet)
%Results = prtPreProcRunSpca(SPCA,PrtDataSet)

Etc = [];
% Based on: 
% Hui Zou, Trevor Hastie, Robert Tibshirani, "Sparse Principal Component
% Analysis", Journal of Computational and Graphical Statistics, Vol 15,
% #2, pp. 256-286.
X = PrtDataSet.getObservations;
X = bsxfun(@minus,X,SPCA.mu);
Results = PrtDataSet.setObservations(X*SPCA.B);