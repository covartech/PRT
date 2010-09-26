function DataSet = prtDataGenIris(irisFile)
%   prtDataGenIris Read in data from a UCI formatted IRIS-like data file
%
% DataSet = prtDataGenIris; Read in the data from the iris.UCI file
% available with the prt and on the web.
%
% DataSet = prtDataGenIris(irisFile);  Read in the UCI-formatted,
% shell-style-commented file a file matching the specifications of iris.UCI
% (see: iris.UCI in <<prtRoot>>\data\)
%

if nargin == 0
    irisFile = fullfile(prtRoot,'data','iris','iris.UCI');
end

[f1,f2,f3,f4,class] = textread(irisFile,'%f %f %f %f %s','commentstyle','shell');
featureNames = {'sepal length (cm)','sepal width (cm)','petal length (cm)','petal width (cm)'};

X = cat(2,f1,f2,f3,f4);
classNames = unique(class);
Y = prtUtilStringsToClassNumbers(class);
DataSet = prtDataSetClass(X,Y,'name','UCI Iris Data');
DataSet = DataSet.setClassNames(classNames);
DataSet = DataSet.setFeatureNames(featureNames);