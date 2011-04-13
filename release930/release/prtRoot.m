function prtDir = prtRoot
% PRTROOT  Tells the location of this file.
%   This file should remain in the PRT root directory to inform other PRT
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

% Copyright 2010, New Folder Consulting, L.L.C.

prtDir = fileparts(mfilename('fullpath'));