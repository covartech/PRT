function result = prtTestPreProcLogDisc
result = true;

try
    dataSet = prtDataGenUnimodal;     % Load a data set
    logDisc = prtPreProcLogDisc;      % Create a pre processing object
    
    logDisc = logDisc.train(dataSet);  % Train
    dataSetNew = logDisc.run(dataSet); % Run
catch
    result = false;
    disp('prtTestLogDisc basic fail')
end

% Check that the mins are 0 and the max are 1's

if  any(abs(min(dataSetNew.getX())) > 1e-3*[ 1 1])
    result = false;
    disp('log dis min not zero')
end

if  any(abs(1-max(dataSetNew.getX())) >1e-3*[ 1 1])     %Check the max
    result = false;
    disp('log disc max not 1');
end