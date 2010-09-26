function DataSet = prtDataGenSwissRoll
% prtDataGenSwissRoll - Data from Swiss Roll data set.
%
% DataSet = prtDataGenSwissRoll; generates data from the swiss roll data
% set.  This data is drawn from a 2-D manifold embedded in 3-dimensions. 
% The 2-D manifold locations are in ds.getTargets, and the 3-dimensional 
% embedding is in ds.getObservations.
% 
% See: http://isomap.stanford.edu/code/Readme

swissRollFile = fullfile(prtRoot,'data','swissRoll','swiss_roll_data.mat');
swiss = load(swissRollFile);
X = swiss.X_data';
Y = swiss.Y_data';

DataSet = prtDataSetRegress(X,Y,'name','Standard Swiss Roll Data');