function DataSet = prtDataMary2
% prtDATAMARY  Generates some unimodal m-ary example data for the prt.
%  The data is distributed:
%       H1: N([-1 0],0.5*eye(2))
%       H2: N([0 1],0.1*eye(2))
%       H3: N([1 0],0.25*eye(2))
%
% Syntax: [X, Y] = prtDataMary2
%
% Inputs: 
%   none
%
% Outputs:
%   X - 300x2 Unimodal data
%   Y - 300x1 Class labels
%
% Example:
%   [X, Y] = prtDataMary;
%   prtDataPlot(X,Y)
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: prtDataUnimodal, prtDataBimodal

% Author: Kenneth D. Morton Jr.
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: 06-Apr-2007

rvH1 = prtRvMvn([-1 0],0.5*eye(2));
rvH2 = prtRvMvn([0 1],0.1*eye(2));
rvH3 = prtRvMvn([1 0],0.25*eye(2));
X = cat(1,draw(rvH1,100),draw(rvH2,100),draw(rvH3,100));
Y = prtUtilY(0,100,100,100);

DataSet = prtDataSet(X,Y,'dataSetName','prtDataMary2');