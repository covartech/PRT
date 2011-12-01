function result = prtTestPreProcHistEq
result = true;
try
    dataSet = prtDataGenIris;              % Load a data set
    dataSet = dataSet.retainFeatures(1:2); % Use only the first 2
    % Features
    histEq = prtPreProcHistEq;             % Create the
    % prtPreProcHistEq Object
    
    histEq = histEq.train(dataSet);        % Train the object
    dataSetNew = histEq.run(dataSet);      % Equalize the histogram
    
catch
    disp('basic hist eq failure')
    result = false;
end
if  any(max(dataSetNew.getX) > 1.1)
    result = false;
    disp('pre proc hist eq much greater than 1')
end

if  any(min(dataSetNew.getX) <-.1)
    result = false;
    disp('pre proc hist eq much less than 0')
end

% Check that we can change the # of samples
try
    histEq.nSamples = 100;
    histEq = prtPreProcHistEq;             % Create the
    % prtPreProcHistEq Object
    
    histEq = histEq.train(dataSet);        % Train the object
    dataSetNew = histEq.run(dataSet);      % Equalize the histogram
catch
    result = false;
    disp('pre proc hist eq n samples')
end