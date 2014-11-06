function DataSet = prtDataGenSpiral3Regress
%prtDataGenSpiral3Regress   Generates some spirally clustered example data 
%
%  DATASET = prtDataGenSpiral3Regress returns a prtDataSetClass with randomly
%  generated data in a spiral pattern in 3 dimensions.
%
%  Example:
%
%  ds = prtDataGenSpiral3Regress;
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


% Generates the spiral data set used in Ueda et al. 2000.  It consists of a
% 1 dimensional manifold in 3 dimensions with additive noise.

nSamples = 800;
t = rand(nSamples,1)*4*pi;
t = sort(t);

X = [(13-0.5*t).*cos(t) -(13-0.5*t).*sin(t) t] + mvnrnd(zeros(3,1),0.5*eye(3),nSamples);
Y = t;

DataSet = prtDataSetRegress(X,Y,'name','prtDataGenSpiral3');
