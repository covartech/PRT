function DataSet = prtDataGenCircles
%prtDataGenCircles   Generates some circle clustered example data for the prt.
%
% Syntax: [X, Y] = prtDataGenCircles
%
% Inputs: 
%   none
%
% Outputs:
%   X - 400x2 Cirlce data
%   Y - 400x1 Class labels
%
% Example:
%   [X, Y] = prtDataCirlces;
%   prtDataPlot(X,Y)
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: prtDataGenUnimodal, prtDataGenBimodal, prtDataGenSpiral

% Copyright 2010, New Folder Consulting, L.L.C.

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