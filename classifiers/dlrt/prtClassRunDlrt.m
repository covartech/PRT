function [ClassifierResults,Etc] = prtClassRunDlrt(PrtDlrt,DataSet)
%[ClassifierResults,Etc] = prtClassRunDlrt(PrtDlrt,DataSet)

Etc = [];

k = PrtDlrt.PrtOptions.k;
PrtOptions = PrtDlrt.PrtOptions;

h0 = getObservations(PrtDlrt.PrtDataSet,find(getTargets(PrtDlrt.PrtDataSet)==0));
h1 = getObservations(PrtDlrt.PrtDataSet,find(getTargets(PrtDlrt.PrtDataSet)==1));

n0 = size(h0,1);
n1 = size(h1,1);

if n0 < k
    error('number of training elements in class 0 (%d) is less than number of neighbors (%d) in DLRT',n0,obj.k);
end
if n1 < k
    error('number of training elements in class 1 (%d) is less than number of neighbors (%d) in DLRT',n1,obj.k);
end
            
memSize = 500;
y = zeros(DataSet.nObservations,1);
for i = 1:memSize:DataSet.nObservations
    if ~PrtOptions.ignoreH0
        indices = i:min([i+memSize-1,DataSet.nObservations]);
        dH1 = sort(PrtOptions.distanceFn(getObservations(DataSet,indices),h1),2,'ascend');
        dH0 = sort(PrtOptions.distanceFn(getObservations(DataSet,indices),h0),2,'ascend');
        
        dH1 = dH1(:,k);
        dH0 = dH0(:,k);
        
        y(indices) = log(n0./n1) + DataSet.nFeatures*log(dH0./dH1);
    else
        indices = i:min([i+memSize-1,DataSet.nObservations]);
        dH1 = sort(obj.distanceFn(getObservations(DataSet,indices),h1),2,'ascend');
        dH1 = dH1(:,obj.k);
        
        y(indices) = -log(n1) - DataSet.nFeatures*log(dH1);
    end
end

ClassifierResults = prtDataSet(y);
end