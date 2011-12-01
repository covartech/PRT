function result = prtTestOutlierRemoveMissingData
result = true;

% test basic operation
try
    dataSet = prtDataGenUnimodal;               % Load a data set
    outlier = prtDataSetClass([NaN NaN],1);     % Insert an outlier
    dataSet = catObservations(dataSet,outlier); % Concatenate
    
    nStdRemove = prtOutlierRemovalMissingData;  % Create a prtPreProc Object
    nStdRemove.runMode = 'removeObservation';
    nStdRemove = nStdRemove.train(dataSet);    % Train
    dataSetNew = nStdRemove.run(dataSet);      % Run
catch
    result = false;
    disp('prtdOutlierRemove Missing data basic fail')
end

% check that the outlier was actually removed
if dataSetNew.nObservations ~= dataSet.nObservations-1
    disp('prtdOutlierRemoveMissing data did not remove outlier')
    result = false;
end



% check remove feature mode, so only make 1 feature an outlier
dataSet = prtDataGenUnimodal;               % Load a data set
outlier = prtDataSetClass([NaN 1],1);     % Insert an outlier
dataSet = catObservations(dataSet,outlier); % Concatenate
nStdRemove.runMode = 'removeFeature';
dataSetNew = nStdRemove.run(dataSet);      % Run
% Result should have only 1 feature
if dataSetNew.nFeatures ~= 1
    disp('remove outlier remove feature fail')
    result = false;
end

% finally, check no-op
dataSet = prtDataGenUnimodal;               % Load a data set
outlier = prtDataSetClass([-10 1],1);     % Insert an outlier
dataSet = catObservations(dataSet,outlier); % Concatenate

nStdRemove.runMode = 'noAction';
dataSetNew = nStdRemove.run(dataSet);
if ~isequal(dataSetNew, dataSet)
    disp('remove outlier no-action fail')
    result = false;
end