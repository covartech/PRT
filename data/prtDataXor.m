function DataSet = prtDataXor(N)
%prtDATAUNIMODAL   Generates some unimodal example data for the prt.
%  DataSet = prtDataXor(N)
%  The data is distributed:
%       H0: N([-1 -1],eye(2))
%       H1: N([2 2],[1 .5; .5 1])
%
% Syntax: [X, Y] = prtDataXor;
%
% Inputs: 
%       N ~ number of samples per class (200)
%
% Outputs:
%   X - 400x2 Unimodal data
%   Y - 400x1 Class labels
%
% Example:
%   [X, Y] = prtDataXor;
%   prtDataPlot(X,Y)
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: prtDataBimodal

% Author: Kenneth D. Morton Jr. & Peter Torrione
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: 27-Mar-2007

if nargin == 0
    nSamples = 200;
else
    nSamples = N;
end
if nargin < 5
    mu01 = [0 3];
    sigma01 = eye(2)/3;
    mu02 = [3 0];
    sigma02 = eye(2)/3;
    
    mu11 = [3 3];
    sigma11 = eye(2)/3;
    mu12 = [0 0];
    sigma12 = eye(2)/3;
end
rv(1) = prtRvMvn(mu01,sigma01);
rv(2) = prtRvMvn(mu02,sigma02);

rv(3) = prtRvMvn(mu11,sigma11);
rv(4) = prtRvMvn(mu12,sigma12);

X = cat(1,draw(rv(1),nSamples/2),draw(rv(2),nSamples/2),draw(rv(3),nSamples/2),draw(rv(4),nSamples/2));
Y = prtUtilY(nSamples,nSamples);

DataSet = prtDataSet(X,Y);