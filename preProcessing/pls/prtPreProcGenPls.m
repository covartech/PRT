function Pls = prtPreProcGenPls(PrtDataSet,PrtOptions)
%Pls = prtPreProcGenPls(PrtDataSet,PrtOptions)

Pls.PrtDataSet = PrtDataSet;
Pls.PrtOptions = PrtOptions;

X = DataSet.getObservations;
if DataSet.nClasses > 2
    Y = DataSet.getTargetsAsBinaryMatrix;
else
    Y = DataSet.getTargetsAsBinaryMatrix;
    Y = Y(:,2); %0's and 1's for H1
end

Pls.xMeans = mean(X,1);
Pls.yMeans = mean(yMat,1);
X = bsxfun(@minus, X, Pls.xMeans);
Y = bsxfun(@minus, Y, Pls.yMeans);

[Bpls, R, P] = prtUtilSimpls(X,Y,PrtOptions.nComponents);
    
Options.TraingedParams.xProjectionWeights = pinv(P');

Pls.projectionMatrix = pinv(P');
Pls.projectionMatrix = bsxfun(@rdivide,Pls.projectionMatrix,sqrt(sum(Pls.projectionMatrix.^2,1)));