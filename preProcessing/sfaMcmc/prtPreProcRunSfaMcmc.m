function [Results,Etc] = prtPreProcRunSfaMcmc(SFA,PrtDataSet)
%Results = prtPreProcRunSfaMcmc
%

Etc = [];

X = PrtDataSet.getObservations;
X = bsxfun(@minus,X,SFA.mu);

Results = PrtDataSet.setObservations((SFA.B'*X')');

