function Lda = prtPreProcGenLda(PrtDataSet,PrtPreProcOptLda)
%Lda = prtPreProcGenLda(PrtDataSet,PrtPreProcLda)

Lda.PrtDataSet = PrtDataSet;
Lda.PrtOptions = PrtPreProcOptLda;
[Lda.projectionMatrix,Lda.globalMean] = prtUtilLinearDiscriminantAnalysis(PrtDataSet,PrtPreProcOptLda.nComponents);
