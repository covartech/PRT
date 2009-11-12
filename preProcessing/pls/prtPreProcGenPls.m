function PrtClassPls = prtPreProcGenPls(DataSet,PrtOptions)
%PrtClassPls = prtPreProcGenPls(DataSet,PrtOptions)

PrtClassPls.PrtDataSet = DataSet;
PrtClassPls.PrtOptions = PrtOptions;

X = DataSet.getObservations;
if DataSet.nClasses > 2
    Y = DataSet.getTargetsAsBinaryMatrix;
else
    Y = DataSet.getTargetsAsBinaryMatrix;
    Y = Y(:,2); %0's and 1's for H1
end

maxComps = min(size(X));
if PrtClassPls.PrtOptions.nComponents > maxComps;
    PrtClassPls.PrtOptions.nComponents = maxComps;
end

PrtClassPls.xMeans = mean(X,1);
PrtClassPls.yMeans = mean(Y,1);
X = bsxfun(@minus, X, PrtClassPls.xMeans);
Y = bsxfun(@minus, Y, PrtClassPls.yMeans);

[Bpls, R, P] = prtUtilSimpls(X,Y,PrtOptions.nComponents);
   
PrtClassPls.projectionMatrix = pinv(P');
PrtClassPls.projectionMatrix = bsxfun(@rdivide,PrtClassPls.projectionMatrix,sqrt(sum(PrtClassPls.projectionMatrix.^2,1)));