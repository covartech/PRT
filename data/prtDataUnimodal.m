function DataSet = prtDataUnimodal(N,mu0,mu1,sigma0,sigma1)
%prtDATAUNIMODAL   Generates some unimodal example data for the prt.
%  DataSet = prtDataUnimodal(N)
%  The data is distributed:
%       H0: N([-1 -1],eye(2))
%       H1: N([2 2],[1 .5; .5 1])
%
% Syntax: [X, Y] = prtDataUnimodal
%         [X, Y] = prtDataUnimodal(N,mu0,mu1,sigma0,sigma1)
%
% Inputs: 
%       N ~ number of samples per class (200)
%       mu0 ~ mean under class 0 ([-1 -1])
%       sigma0 ~ covariance under class 0 ([eye(2)])
%       mu1 ~ mean under class 0 ([2 2])
%       sigma1 ~ covariance under class 0 ([1 .5; .5 1])
%
% Outputs:
%   X - 400x2 Unimodal data
%   Y - 400x1 Class labels
%
% Example:
%   [X, Y] = prtDataUnimodal;
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
    mu0 = [-1 -1];
    sigma0 = eye(2);
    mu1 = [2 2];
    sigma1 = [1 .5; .5 1];
end
rv(1) = prtRvMvn(mu0,sigma0);
rv(2) = prtRvMvn(mu1,sigma1);

X = cat(1,draw(rv(1),nSamples),draw(rv(2),nSamples));
Y = prtUtilY(nSamples,nSamples);

DataSet = prtDataSetClass(X,Y);