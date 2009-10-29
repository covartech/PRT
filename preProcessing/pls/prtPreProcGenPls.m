function Pls = prtPreProcGenPls(PrtDataSet,PrtOptions)
%Pls = prtPreProcGenPls(PrtDataSet,PrtOptions)

Pls.PrtDataSet = PrtDataSet;
Pls.PrtOptions = PrtOptions;

[Bpls, W, P, Q, T] = prtUtilPls(PrtDataSet,PrtOptions.nComponents);
Pls.projectionMatrix = W;
