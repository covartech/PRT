function ds = prtUtilStructToDataSetClass(S)
% PRTUTILSTRUCTTODATASETCLASS Make a prtDataSetClass from a structure array
%   The contents of the structure are set as the observation info with
%   empty observations and targets;
%
% Syntax: ds = prtUtilStructToDataSetClass(S)
%
%   S must be a vector structure array.
%   Each field of S specified as a datafField must be a scalar numeric value.

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


assert(isstruct(S) && isvector(S),'S must be a structure vector array');

nFeatures = 1;
nObs = length(S);
ds = prtDataSetClass(nan(nObs,nFeatures));

ds.observationInfo = S;
