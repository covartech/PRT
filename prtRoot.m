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

% Copyright 2010, New Folder Consulting, L.L.C.

prtDir = fileparts(mfilename('fullpath'));