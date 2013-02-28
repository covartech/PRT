function result = prtTestOutlierRemoveMissingData

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.
result = true;


% test basic operation
try
    dataSet = prtDataGenUnimodal;               % Load a data set
    outlier = prtDataSetClass([NaN NaN],1);     % Insert an outlier
    dataSet = catObservations(dataSet,outlier); % Concatenate
    
    nStdRemove = prtOutlierRemovalMissingData;  % Create a prtPreProc Object
    nStdRemove.runMode = 'removeObservation';
    nStdRemove = nStdRemove.train(dataSet);    % Train
    dataSetNew = nStdRemove.run(dataSet);      % Run
catch
    result = false;
    disp('prtdOutlierRemove Missing data basic fail')
end

% check that the outlier was actually removed
if dataSetNew.nObservations ~= dataSet.nObservations-1
    disp('prtdOutlierRemoveMissing data did not remove outlier')
    result = false;
end



% check remove feature mode, so only make 1 feature an outlier
dataSet = prtDataGenUnimodal;               % Load a data set
outlier = prtDataSetClass([NaN 1],1);     % Insert an outlier
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
