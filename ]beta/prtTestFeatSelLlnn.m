function result = prtTestFeatSelLlnn

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


%%
result = true;
%%



%%
% Check basic operation
try
dataSet = prtDataGenCircles;
featSel = prtFeatSelLlnn; 
featSel = featSel.train(dataSet);
outDataSet = featSel.run(dataSet);
catch
    disp('Error #1, basic feature selection fail')
    result = false;
end

% Should always give 2 features ere.
if outDataSet.nFeatures ~=2
    disp('Error #2, wrong # of features')
    result = false;
end

if featSel.isTrained ~= 1
    disp('Error #2a, should be trained')
    result = false;
end




% check param/value constructor
try
    featSel = prtFeatSelLlnn('nMaxIterations',24);
catch
    disp('Error #4, param/val constructor fail')
    result = false;
end

% check help example, should wind up with 2 features
dataSet = prtDataGenSpiral;   % Create a 2 dimensional data set
nNoiseFeatures = 100;      % Append 100 irrelevant features
dataSet = prtDataSetClass(cat(2,dataSet.getObservations,randn([dataSet.nObservations, nNoiseFeatures])), dataSet.getTargets);
featSel = prtFeatSelLlnn;  % Create the feature
% selection object.
featSel.nMaxIterations = 10;                   % Set the max # of
% iterations.
featSel = featSel.train(dataSet);              % Train

% if ~isequal(featSel.selectedFeatures, [1 2]')
%     %Note, this is undesireable, but happens
%     disp('Error #4a, wrong number of selected features; this is undesireable, but happens')
%     result = false; 
% end

%% Stuff that should error
error = true;
dataSet = prtDataGenSpiral3Regress;
featSel = prtFeatSelLlnn; 

try
    R = featSel.run(dataSet);
    disp('Error# x , run before train')
    error = false;
end

result = result & error;


