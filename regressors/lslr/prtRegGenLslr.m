function Regressor = prtRegGenLslr(PrtDataSet,PrtOptions)
%Rvm = prtRegGenLslr(PrtDataSet,PrtOptions)

X = PrtDataSet.getObservations;
Y = PrtDataSet.getTargets;

Xc = bsxfun(@minus,X,mean(X,1));
Yc = bsxfun(@minus,Y,mean(Y,1));

Beta = (Xc'*Xc)^(-1) * Xc'*Yc;
Beta = [mean(Y,1) - mean(X,1)*Beta;Beta];

Z = cat(2,ones(size(Xc,1),1),Xc);

yHat = cat(2,ones(size(X,1),1),X)*Beta;
e = yHat - Y;
RSS = sum(e(:).^2);
sigmaHat = sqrt(RSS./(size(X,1) - size(X,2) - 1));

if size(X,1) < 1000
    % this can be expensive to calculate
    H = Z*(Z'*Z)^(-1)*Z';
    standardizedResiduals = bsxfun(@rdivide,e,(sigmaHat*(1-diag(H)).^(1/2)));
else
    standardizedResiduals = nan;
end

t = bsxfun(@rdivide,Beta,sigmaHat*sqrt(diag((Z'*Z)^(-1))));

Regressor.t = t;
Regressor.RSS = RSS;
Regressor.standardizedResiduals = standardizedResiduals;
Regressor.Beta = Beta;
Regressor.PrtDataSet = PrtDataSet;
Regressor.PrtOptions = PrtOptions;
