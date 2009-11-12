function PrtClassPlsda = prtClassGenPlsda(DataSet,PrtClassOpt)
% PrtClassPlsda = prtClassGenPlsda(DataSet,PrtClassOpt)

PrtClassPlsda.PrtDataSet = DataSet;
PrtClassPlsda.PrtOptions = PrtClassOpt;

X = DataSet.getObservations;
if DataSet.nClasses > 2
    Y = DataSet.getTargetsAsBinaryMatrix;
else
    Y = DataSet.getTargetsAsBinaryMatrix;
    Y = Y(:,2); %0's and 1's for H1
end

maxComps = min(size(X));
if PrtClassPlsda.PrtOptions.nComponents > maxComps;
    PrtClassPlsda.PrtOptions.nComponents = maxComps;
end

PrtClassPlsda.xMeans = mean(X,1);
PrtClassPlsda.yMeans = mean(Y,1);
X = bsxfun(@minus, X, PrtClassPlsda.xMeans);
Y = bsxfun(@minus, Y, PrtClassPlsda.yMeans);

Bpls = prtUtilSimpls(X,Y,PrtClassPlsda.PrtOptions.nComponents);

PrtClassPlsda.Bpls = Bpls;