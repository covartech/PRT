function result = prtTestPreProcNstdOutlierRemove
result = true;

% test basic operation
try 
        dataSet = prtDataGenUnimodal;               % Load a data set
    outlier = prtDataSetClass([-10 -10],1);     % Insert an outlier
    dataSet = catObservations(dataSet,outlier); % Concatenate
 
    nStdRemove = prtPreProcNstdOutlierRemove;  % Create a prtPreProc Object
 
    nStdRemove = nStdRemove.train(dataSet);    % Train 
    dataSetNew = nStdRemove.run(dataSet);      % Run
catch
    result = false;
    disp('prtPreProcNstdOutlierRemove basic fail')
end

% check that the outlier was actually removed
if dataSetNew.nObservations ~= dataSet.nObservations-1
    disp('prtPreProcNstdOutlierRemove did not remove outlier')
    result = false;
end
