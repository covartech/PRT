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
