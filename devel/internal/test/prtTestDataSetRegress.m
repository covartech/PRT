function result = prtTestDataSetRegress

result = true;

% Test basic object instantiation
try
    dataSet = prtDataSetRegress;
    dataSet = dataSet.setObservationsAndTargets([ 1 2; 3 4], [0 1]');
catch
    disp('Instantiation of prtDataSetRegress fail')
    result = false;
end

% Check the results of above
if(dataSet.nFeatures ~= 2)
    disp('prtDataSetRegress nFeatures fail')
    result = false;
end

if(dataSet.isLabeled ~=1)
    disp('prtDataSetRegress isLabeled fail')
    result = false;
end

try
    out = dataSet.summarize;
catch
    disp('prtDataSetRegress summarize fail')
    result = false;
end

if ~isequal(out.upperBounds, [3 4]) || ~isequal(out.lowerBounds,[1 2])
    disp('prtDataSetRegress summarize fail')
    result = false;
end

% check that plotting works and errors properly
try
    % this should fail
    dataSet.plot()
     disp('prtDataSetRegress plot should error on higher dim data')
    result = false;
    close;
catch
    % no-op
end

dataSet = prtDataGenSpiral3Regress;
dataSet = dataSet.retainFeatures(1);
try
    dataSet.plot()
    close;
catch
    result = false; 
    close
    disp('prtDataSetRegress fail')
end
    