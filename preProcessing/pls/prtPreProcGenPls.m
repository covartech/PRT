function Pls = prtPreProcGenPls(PrtDataSet,PrtOptions)
%Pls = prtPreProcGenPls(PrtDataSet,PrtOptions)

Pls.PrtDataSet = PrtDataSet;
Pls.PrtOptions = PrtOptions;

[Pls.weights, Pls.W, Pls.componentEnergy, Pls.projectionMatrix] = prtUtilPls(PrtDataSet,PrtOptions.nComponents);
keyboard
