function DataSet = prtDataGenMary2
% prtDataGenMary2  Generates some unimodal m-ary example data for the prt.
%  The data is distributed:
%       H1: N([-1 0],0.5*eye(2))
%       H2: N([0 1],0.1*eye(2))
%       H3: N([1 0],0.25*eye(2))
%
% Syntax: [X, Y] = prtDataGenMary2
%
% Inputs: 
%   none
%
% Outputs:
%   X - 300x2 Unimodal data
%   Y - 300x1 Class labels
%
% Example:
%   [X, Y] = prtDataGenMary2;
%   prtDataPlot(X,Y)
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: prtDataGenUnimodal, prtDataGenBimodal

% Copyright 2010, New Folder Consulting, L.L.C.

rvH1 = prtRvMvn('Mean',[-1 0],'Covariance',0.5*eye(2));
rvH2 = prtRvMvn('Mean',[0 1],'Covariance',0.1*eye(2));
rvH3 = prtRvMvn('Mean',[1 0],'Covariance',0.25*eye(2));
X = cat(1,draw(rvH1,100),draw(rvH2,100),draw(rvH3,100));
Y = prtUtilY(0,100,100,100);

DataSet = prtDataSetClass(X,Y,'name','prtDataGenMary2');