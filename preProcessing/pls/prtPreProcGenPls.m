function Pls = prtPreProcGenPls(PrtDataSet,PrtOptions)
%Pls = prtPreProcGenPls(PrtDataSet,PrtOptions)

Pls.PrtDataSet = PrtDataSet;
Pls.PrtOptions = PrtOptions;

PrtDataSet = PrtDataSet.maryTargetsToZeroOneTargets;
[Bpls, W, P, Q, T] = prtUtilPls(PrtDataSet,PrtOptions.nComponents);
keyboard
Pls.projectionMatrix = P;
