function result = prtTestPreProcNstdOutlierRemove
result = true;

% test basic operation
try
    dataSet = prtDataGenUnimodal;               % Load a data set
    outlier = prtDataSetClass([-10 -10],1);     % Insert an outlier
    dataSet = catObservations(dataSet,outlier); % Concatenate
    
    nStdRemove = prtOutlierRemovalNStd;  % Create a prtPreProc Object
    nStdRemove.runMode = 'removeObservation';
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

% check the other modes
nStdRemove.runMode = 'replaceWithNan';
dataSetNew = nStdRemove.run(dataSet);      % Run
x = dataSetNew.getX;
if ~all(isnan(x(end,:)))
    disp('pre remove outlier nstd did not replace data with nan')
    result = false;
end


% check remove feature mode, so only make 1 feature an outlier
dataSet = prtDataGenUnimodal;               % Load a data set
outlier = prtDataSetClass([-10 1],1);     % Insert an outlier
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