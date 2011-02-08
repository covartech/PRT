function result = prtTestPreProcZeroMeanColumns
result = true;

try
    dataSet = prtDataGenIris;              % Load a data set
    dataSet = dataSet.retainFeatures(1:2); % Use only the first 3 features
    zmr = prtPreProcZeroMeanColumns;          % Create a
    %  prtPreProcZeroMeanRows object
    zmr = zmr.train(dataSet);              % Train
    dataSetNew = zmr.run(dataSet);         % Run
catch
    disp('pre proc zero mean col fail');
    result = false;
end

% check that the columns are zero mean
if  any(abs(mean(dataSetNew.getFeatures)) > [.00001 .00001 ])
    disp('pre proc zero means col mean not 0')
    result = false;
end