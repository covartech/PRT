function DataSet = prtDataGenFeatureSelection(N)
%prtDataGenFeatureSelection   Generates some unimodal example data for the prt.
%  DataSet = prtDataGenFeatureSelection(N)
%  The data is distributed:
%       H0: N([0 0 0 0 0 0 0 0 0 0],eye(10))
%       H1: N([0 2 0 1 0 2 0 1 0 2],eye(10))
%
% Syntax: [X, Y] = prtDataGenFeatureSelection(N)
%
% Inputs: 
%       N ~ number of samples per class (200)
%
% Outputs:
%   X - 400x2 Unimodal data
%   Y - 400x1 Class labels
%
% Example:
%   DataSet = prtDataGenFeatureSelection;
%   explore(DataSet)
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: prtDataGenUnimodal

% Copyright 2010, New Folder Consulting, L.L.C.

if nargin == 0
    nSamples = 200;
else
    nSamples = N;
end
mu0 = [0 0 0 0 0 0 0 0 0 0];
mu1 = [0 1 0 .5 0 1 0 .5 0 1];

sigma0 = eye(length(mu0));
sigma1 = eye(length(mu1));
rv(1) = prtRvMvn('mu',mu0,'sigma',sigma0);
rv(2) = prtRvMvn('mu',mu1,'sigma',sigma1);

X = cat(1,draw(rv(1),nSamples),draw(rv(2),nSamples));
Y = prtUtilY(nSamples,nSamples);

DataSet = prtDataSetClass(X,Y,'name',mfilename);