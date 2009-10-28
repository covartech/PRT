function [Results, TestInd, ClassStructs, uKeys, Etc] = prtCrossValidate(PrtDataSet,AlgorithmOptions,validationKeys)
%[Results, TestInd, ClassStructs, uKeys, Etc] = prtCrossValidate(PrtDataSet,AlgorithmOptions,validationKeys)


% Author: Peter Torrione
% Revised by: 
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: 31-March-2007
% Last revision: 
   
if length(validationKeys) ~= PrtDataSet.nObservations;
    error('Number of validation keys (%d) must match number of data points (%d)',length(validationKeys),PrtDataSet.nObservations);
end
uKeys = unique(validationKeys);

TestInd = cell(length(uKeys),1);

Results = prtDataSetUnLabeled;
for uInd = 1:length(uKeys);
    
    %get the testing indices:
    cTestInd = find(crossValidateEq(uKeys(uInd),validationKeys));
    
    trainDataSet = PrtDataSet.removeObservations(cTestInd);
    testDataSet = PrtDataSet.retainObservations(cTestInd);
    classOut = prtGenerate(trainDataSet,AlgorithmOptions);
    [currResults, Etc] = prtRun(classOut,testDataSet);
    if isa(currResults,'cell')
        currResults = currResults{end};
    end
    if uInd == 1
        Results = prtDataSetUnlabeled(nan(PrtDataSet.nObservations,currResults.nFeatures));
    end
    Results = Results.setObservations(currResults.getObservations,cTestInd);
    
    %only do this if the output is requested; otherwise this cell of
    %classifiers can get very large, and slow things down.
    if nargout >= 2
        TestInd{uInd} = cTestInd;
    end
    
    if nargout >= 3
        ClassStructs(uInd) = classOut;    
    end
end


function I = crossValidateEq(key,list)
%I = crossValidateEq(key,list)
%   Perform equality comparison regardless of whether key and list are
%   cells of strings or doubles.

if isa(key,'cell')
    I = strcmp(key,list);
else
    I = key == list;
end