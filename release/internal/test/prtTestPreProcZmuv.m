function result = prtTestPreProcZmuv
result = true;

try
    dataSet = prtDataGenProstate;       % Load a data set.
    zmuv = prtPreProcZmuv;           %  Create a zero-mean unit variance
    %  object
    zmuv = zmuv.train(dataSet);      % Compute the mean and variance
    dataSetNew = zmuv.run(dataSet);  % Normalize the data
catch
    disp('basic zmuv failure')
    result = false;
end
if  abs(mean(dataSetNew.getObservations())) > 1e-13
    result = false;
    disp('zmuv mean not zero')
end

if  abs(1-var(dataSetNew.getObservations())) > 1e-13      %Check the variance
    result = false;
    disp('zmuv variance not 1');
end