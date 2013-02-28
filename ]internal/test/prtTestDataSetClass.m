function result = prtTestDataSetClass

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


% Test instantiation 
try
    dataSet = prtDataSetClass;
    dataSet = dataSet.setObservationsAndTargets([ 1 2; 3 4], [0 1]');
catch
    disp('Instantiation of prtDataSetClass fail')
    result = false;
end

% Check the results of above
if(dataSet.nClasses ~= 2)
    disp('prtDataSet nClasses fail')
    result = false;
end

if(dataSet.isZeroOne == 0)
    disp('isZeroOne fail')
    result = false;
end

if(dataSet.nFeatures ~=2 || dataSet.nTargetDimensions ~=1 || dataSet.isLabeled ~=1)
    disp('prtDataSet setup fail')
    result = false;
end
    
% Check functions
if ~isequal(dataSet.getObservationsByClass(0),  [1 2]);
    disp('Get obs by class fail')
    result = false;
end


if ~isequal(dataSet.getObservationsByClassInd(2,2),  4);
    disp('Get obs by class and ind fail')
    result = false;
end

if ~isequal(dataSet.getTargetsAsBinaryMatrix, eye(2))
    disp('getTargets Binary Matrix fail')
    result = false;
end

% make sure the explorer, plots, etc open without error
try
    dataSet.explore;
    close
catch
    disp('dataSetClass explore fail')
    close;
    result = false;
end

try
    dataSet.plot;
    close
catch
    disp('dataSetClass plot fail')
    close;
    result = false;
end

try
    dataSet.plotbw;
    close
catch
    disp('dataSetClass plotbw fail')
    close;
    result = false;
end

try
    dataSet.plotAsTimeSeries;
    close
catch
    disp('dataSetClass plot as time series fail')
    close;
    result = false;
end

try
    warning('off','prt:plotStar:TooFewDimensions');
    dataSet.plotStar();
    warning('on','prt:plotStar:TooFewDimensions');
    close
catch
    disp('dataSetClass star plot fail')
    close;
    result = false;
end

try
    warning('off','prt:plotStar:TooFewDimensions'); 
    dataSet.plotStarIndividual();
    warning('on','prt:plotStar:TooFewDimensions');
    close
catch
    disp('dataSetClass star plot individual fail')
    close;
    result = false;
end


% Test bootstrap
dataSet = prtDataGenMary;
out = dataSet.bootstrap(2);
if out.nObservations ~=2
    disp('dataSet bootstrap fail')
    result = false;
end

dataSet = dataSet.setObservationsAndTargets([ 1 2; 3 4], [0 1]');
 out = dataSet.bootstrapByClass([1 1 ]);
if out.nObservations ~=2  
    disp('dataSet bootstrap fail')
    result = false;
end

if ~isequal(dataSet.nObservationsByClass, [1 1]')
    disp('dataSetClass n Obs by class fail')
    result = false;
end


out = dataSet.getTargetsClassInd(1);
if out ~=1
    disp('dataSetClass getTargetsClassInd fail')
    result = false;
end

