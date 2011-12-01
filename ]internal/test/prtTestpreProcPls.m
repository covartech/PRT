function result = prtTestpreProcPls

result = true;

% test from the help
try
    dataSet = prtDataGenProstate;     % Load a data set.
    Pls = prtPreProcPls;           % Create the  Component
    % Analysis object.
    Pls.nComponents = 4;           % Set the number of components to 4
    Pls = Pls.train(dataSet);      % Compute the  Components
    dataSetNew = Pls.run(dataSet); % Extract the  Components
    
catch ME
    disp(ME)
    result = false;
    disp('error #1, basic Pls test fail')
    
end

if dataSetNew.nFeatures ~=4
    result = false;
    disp('error #2, wrong number of features')
end

% check constuctor
try 
    Pls = prtPreProcPls('nComponents',4);
catch ME
    disp(ME)
    result = false;
    disp('error #3, param-val constructor fail')
end

% Baseline check would be nice if one exists.

%% Negative error checks

error = true;

try
    Pls = prtPreProcPls;
    Pls.nComponents = 0;
    error = false;
    disp('error #4, set to zero components')
catch % Don't catch ME
    %
end


try
    dataSet = prtDataGenProstate;     % Load a data set.
    Pls = prtPreProcPls;           % Create the  Component
    % Analysis object.
    Pls.nComponents = 20;           % Set the number of components to 4
    Pls = Pls.train(dataSet);      % Compute the Components
    dataSetNew = Pls.run(dataSet); % Extract the  Components
    
catch
    
end
[w, wid ] = lastwarn;
if ~isequal(wid,'prt:prtPreProcPls')
    error = false;
    disp('error#5, too many components')
end

result = result && error;

