function result = prtTestpreProcLda

result = true;

% test from the help
try
    dataSet = prtDataGenProstate;     % Load a data set.
    Lda = prtPreProcLda;           % Create the  Component
    % Analysis object.
    Lda.nComponents = 4;           % Set the number of components to 4
    Lda = Lda.train(dataSet);      % Compute the  Components
    dataSetNew = Lda.run(dataSet); % Extract the  Components
    
catch
    result = false;
    disp('error #1, basic Lda test fail')
    
end

if dataSetNew.nFeatures ~=4
    result = false;
    disp('error #2, wrong number of features')
end

% check constuctor
try
    Lda = prtPreProcLda('nComponents',4);
catch
    result = false;
    disp('error #3, param-val constructor fail')
end

% Baseline check would be nice if one exists.

%% Negative error checks

error = true;

try
    Lda = prtPreProcLda;
    Lda.nComponents = 0;
    error = false;
    disp('error #4, set to zero components')
catch
    %
end


try
    dataSet = prtDataGenProstate;     % Load a data set.
    Lda = prtPreProcLda;           % Create the  Component
    % Analysis object.
    Lda.nComponents = 20;           % Set the number of components to 4
    Lda = Lda.train(dataSet);      % Compute the  Components
    dataSetNew = Lda.run(dataSet); % Extract the  Components
    error = false;
    disp('pre proc LDA, nComponents larger than # of unique classes')
catch
    
end

result = result && error;

