function result = prtTestPreProcZeroMeanRows
result = true;

try
    dataSet = prtDataGenIris;              % Load a data set
    dataSet = dataSet.retainFeatures(1:3); % Use only the first 3 features
    zmr = prtPreProcZeroMeanRows;          % Create a
    %  prtPreProcZeroMeanRows object
    zmr = zmr.train(dataSet);              % Train
    dataSetNew = zmr.run(dataSet);         % Run
catch
    disp('pre proc zero mean rows fail');
    result = false;
end

% check that the rows are zero mean

% check that the columns are zero mean
if  any(abs(mean(dataSetNew.getObservations,2)) > 1e-13*ones(150,1))
    disp('pre proc zero means rows mean not 0')
    result = false;
end


