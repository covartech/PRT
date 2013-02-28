function DataSet = prtDataGenSpiral(N)
%prtDataGenSpiral   Generates some spirally clustered example data 
%
%  DATASET = prtDataGenSpiral returns a prtDataSetClass with randomly
%  generated data in a spiral pattern in 2 dimensions.
%
%  Example:
%
%  ds = prtDataGenSpiral;
%  plot(ds)
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




if nargin < 1
    nSamples = 200;
else 
    nSamples = N;
end
t = linspace(0,4*pi,nSamples);
f = 1;
dx = .5;
dy = .5;
std = .1;

theta1 = 0;
mux1 = 0; muy1 = 0;
theta0 = pi/2;
mux0 = 0; muy0 = 0;

Xspiral_H1 = prtUtilGenerateSpiralCluster(t,f,theta1,mux1,muy1,dx,dy,std);
Xspiral_H0 = prtUtilGenerateSpiralCluster(t,f,theta0,mux0,muy0,dx,dy,std);

X = cat(1,Xspiral_H0,Xspiral_H1);
Y = cat(1,zeros(nSamples,1),ones(nSamples,1));

DataSet = prtDataSetClass(X,Y,'name','prtDataGenSpiral');
