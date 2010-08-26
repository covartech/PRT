function DataSet = prtDataGenBimodal(N)
%prtDataGenBimodal   Generates some bimodal example data for the DPRT.
%  The data is distributed:
%       H0: 1/2N([0 0],eye(2)) + 1/2*N([-4 -4],eye(2))
%       H1: 1/2N([2 2],[1 .5; .5 1]) + 1/2*N([-2 -2],[1 .5; .5 1]
%
% Syntax: [X, Y] = dprtDataGenBimodal
%
% Inputs: 
%   none
%
% Outputs:
%   X - 400x2 Bimodal data
%   Y - 400x1 Class labels
%
% Example:
%   [X, Y] = dprtDataGenBimodal;
%   dprtDataPlot(X,Y)
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: dprtDataUnimodal

% Author: Kenneth D. Morton Jr. & Peter Torrione
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: 27-Mar-2007

if nargin == 0
	N = 100;
end
nSamples = N;

R(1,1) = prtRvMvn([0 0],eye(2));
R(1,2) = prtRvMvn([-4 -4],eye(2));
R(2,1) = prtRvMvn([2 2],[1 .5; .5 1]);
R(2,2) = prtRvMvn([-2 -2],[1 .5; .5 1]);

X = cat(1,draw(R(1,1),nSamples),draw(R(1,2),nSamples),draw(R(2,1),nSamples),draw(R(2,2),nSamples));
Y = prtUtilY(nSamples*2, nSamples*2);

DataSet = prtDataSetClass(X,Y,'name','prtDataGenBimodal');