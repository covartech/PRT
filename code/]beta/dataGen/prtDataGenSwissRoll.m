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



% The 2-D manifold locations are in ds.getTargets, and the 3-dimensional 
% embedding is in ds.getObservations.

swissRollFile = fullfile(prtRoot,']beta','dataGen','swissRoll','swiss_roll_data.mat');
swiss = load(swissRollFile);
X = swiss.X_data';
Y = swiss.Y_data';

DataSet = prtDataSetRegress(X,Y,'name','Standard Swiss Roll Data');
