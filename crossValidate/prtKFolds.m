function varargout = prtKFolds(DataSet,PrtOptions,K)
%[DS, TestInd, ClassStructs, uKeys, nativeDS] = prtKFolds(DataSet,PrtOptions,K)

if nargin == 3 || isempty(K)
    K = DataSet.nObservations;
end

nObs = DataSet.nObservations;

if K > nObs;
    warning('prt:kfolds:nFolds',['Number of folds (%d) is greater than number of ' ...
        'data points (%d); assuming Leave One Out training and testing'],...
        K,nObs);
    K = nObs;
elseif K < 1
    warning('prt:kfolds:nFolds',['Number of folds (%d) is less than 1 assuming ' ...
        'FULL training and testing'],K);
    K = 1;
elseif K == 1
    warning('prt:kfolds:nFolds',['Number of folds is 1; assuming FULL training ' ...
        'and testing']);
    K = 1;
end

keys = prtUtilEquallySubDivideData(DataSet.getTargets,K);

outputs = cell(1,max(nargout,1));
[outputs{:}] = prtCrossValidate(DataSet,PrtOptions,keys);
varargout = outputs(1:nargout);
