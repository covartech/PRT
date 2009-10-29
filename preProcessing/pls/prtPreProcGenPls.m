function Pls = prtPreProcGenPls(PrtDataSet,PrtOptions)
%Pls = prtPreProcGenPls(PrtDataSet,PrtOptions)

Pls.PrtDataSet = PrtDataSet;
Pls.PrtOptions = PrtOptions;

[Bpls, W, P, Q, T, meanX, meanY] = prtUtilPls(PrtDataSet,PrtOptions.nComponents);

Pls.meanX = meanX;
Pls.projectionMatrix = pinv(P');
Pls.projectionMatrix = bsxfun(@rdivide,Pls.projectionMatrix,sqrt(sum(Pls.projectionMatrix.^2,1)));

