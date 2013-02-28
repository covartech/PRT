function DataSet = prtDataGenCircles
%prtDataGenCircles   Generates circularly clustered data 
%
%  DATASET = prtDataGenCircles returns a prtDataSetClass with randomly
%  generated data in a circular pattern.
%  
%  Example:
%
%   dataSet = prtDataGenCircles;
%   plot(dataSet);
%
%   See also: prtDataSetClass, prtDataGenBiModal, prtDataGenIris,
%   prtDataGenMary, prtDataGenNoisySinc, prtDataGenOldFaithful,
%   prtDataGenSpiral, prtDataGenUnimodal, prtDataGenUnimodal, prtDataGenXor

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
%  "Software"), to deal in the Software without restriction, including
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


nSamplesEachHypothesis = 200;
noiseStd = 0.05;
centers = [1 1; 1 1;];

radius0 = 0.5;
radius1 = 1;
X0thetas = rand(nSamplesEachHypothesis,1)*2*pi;
X1thetas = rand(nSamplesEachHypothesis,1)*2*pi;
X0(:,1) = centers(1,1) + radius0*cos(X0thetas) + noiseStd*randn(nSamplesEachHypothesis,1);
X0(:,2) = centers(1,2) + radius0*sin(X0thetas) + noiseStd*randn(nSamplesEachHypothesis,1);
X1(:,1) = centers(2,1) + radius1*cos(X1thetas) + noiseStd*randn(nSamplesEachHypothesis,1);
X1(:,2) = centers(2,2) + radius1*sin(X1thetas) + noiseStd*randn(nSamplesEachHypothesis,1);

X = cat(1,X0,X1);
Y = cat(1,zeros(nSamplesEachHypothesis,1),ones(nSamplesEachHypothesis,1));

DataSet = prtDataSetClass(X,Y,'name','prtDataGenCircles');
