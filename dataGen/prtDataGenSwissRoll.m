function DataSet = prtDataGenSwissRoll
% prtDataGenSwissRoll  Generates data from the Swiss Roll data set.
%
%   DataSet = prtDataGenSwissRoll generates a prtDataSetRegress from the
%   swiss roll data set. This data is drawn from a 2-D manifold embedded in
%   3-dimensions. For more information on ths data set see the following:
% 
%   http://isomap.stanford.edu/code/Readme
%
%   Example:
%
%   ds = prtDataGenSwissRoll;
%
%   See also: prtDataSetClass, prtDataGenBiModal, prtDataGenIris,
%   prtDataGenManual, prtDataGenMary, prtDataGenNoisySinc,
%   prtDataGenOldFaithful,prtDataGenProtate, prtDataGenSprial,
%   prtDataGenSpiral3Regress, prtDataGenUnimodal, prtDataGenSwissRoll,
%   prtDataGenUnimodal, prtDataGenXor








% The 2-D manifold locations are in ds.getTargets, and the 3-dimensional 
% embedding is in ds.getObservations.

swissRollFile = fullfile(prtRoot,']beta','dataGen','swissRoll','swiss_roll_data.mat');
swiss = load(swissRollFile);
X = swiss.X_data';
Y = swiss.Y_data';

DataSet = prtDataSetRegress(X,Y,'name','Standard Swiss Roll Data');
