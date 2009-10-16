function DataSet = prtDataIris(irisFile)
%   prtReadIris Read in data from a UCI formatted IRIS-like data file
%
% [X,Y,classNames] = prtReadIris; Read in the data from the iris.UCI file
% available with the prt and on the web.
%
% [X,Y,classNames] = prtReadIris(irisFile);  Read in the UCI-formatted,
% shell-style-commented file a file matching the specifications of iris.UCI
% (see: iris.UCI in <<prtRoot>>\data\)
%

if nargin == 0
    irisFile = fullfile(prtRoot,'data','iris','iris.UCI');
end

[f1,f2,f3,f4,class] = textread(irisFile,'%f %f %f %f %s','commentstyle','shell');

X = cat(2,f1,f2,f3,f4);
classNames = unique(class);
Y = prtUtilStringsToClassNumbers(class);
DataSet = prtDataSetLabeled(X,Y,'classNames',classNames,'dataSetName','UCI Iris Data');