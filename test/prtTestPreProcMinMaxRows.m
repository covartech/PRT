function result = prtTestPreProcMinMaxRows
result = true;

try
    dataSet = prtDataGenIris;              % Load a data set
    dataSet = dataSet.retainFeatures(1:3); % Use only the first 3 features
    zmr = prtPreProcMinMaxRows;          % Create a
    %  prtPreProcMinMaxRows object
    zmr = zmr.train(dataSet);              % Train
    dataSetNew = zmr.run(dataSet);         % Run
catch
    disp('pre proc mix max rows fail');
    result = false;
end

% check that the rows are zero mean

% check that the columns are zero mean
if  any(min(dataSetNew.getX) ~= [1 0 0 ])
    disp('pre proc mix max rows mean not 0')
    result = false;
end