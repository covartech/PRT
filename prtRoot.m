function prtDir = prtRoot
% PRTROOT  Tells the location of this file.
%   This file should remain in the PRT root directory to inform other DPRT
%   functions of their location
%
% Syntax: prtDir = prtRoot
%
% Inputs: 
%   none
%
% Outputs:
%   prtDir - A string containing the path to this file.
%
% Examples:
%   prtRoot
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: PRT

% Author: Kenneth D. Morton Jr.
% Duke University, Department of Electrical and Computer Engineering
% Email Address: collinslab@gmail.com
% Created: 07-Mar-2007

prtDir = fileparts(mfilename('fullpath'));