function DataSet = prtDataGenIris
%   prtDataGenIris Read in data from the UCI IRIS data file
%
%   DataSet = prtDataGenIris reads in the data from the classic iris.UCI
%   file used in many pattern recognition texts and papers. For more
%   information about this data, see the following URL:
%
%   http://archive.ics.uci.edu/ml/datasets/Iris
%
%   Example:
% 
%   ds = prtDataGenIris;
%   ds.plot;
%    
%   See also: prtDataSetClass, prtDataGenBiModal, prtDataGenIris,
%   prtDataGenMary, prtDataGenNoisySinc, prtDataGenOldFaithful,
%   prtDataGenSpiral, prtDataGenUnimodal, prtDataGenUnimodal, prtDataGenXor

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


%
% DataSet = prtDataGenIris(irisFile);  Read in the UCI-formatted,
% shell-style-commented file a file matching the specifications of iris.UCI
% (see: iris.UCI in <<prtRoot>>\data\)
%

irisFile = fullfile(prtRoot,'dataGen','dataStorage','iris','iris.UCI');
if ~exist(irisFile,'file')
    error('prtDataGenIris:MissingIrisFile','The UCI Iris file, iris.UCI, was not found in %s',irisFile);
end

%[f1,f2,f3,f4,class] = textread(irisFile,'%f %f %f %f %s','commentstyle','shell');
fid = fopen(irisFile,'r');
C = textscan(fid,'%f %f %f %f %s','commentstyle','#');
fclose(fid);

featureNames = {'sepal length (cm)','sepal width (cm)','petal length (cm)','petal width (cm)'};

X = cat(2,C{1},C{2},C{3},C{4});

class = C{5};
classNames = unique(class);

Y = prtUtilStringsToClassNumbers(class);
DataSet = prtDataSetClass(X,Y,'name','UCI Iris Data');
DataSet = DataSet.setClassNames(classNames);
DataSet = DataSet.setFeatureNames(featureNames);
