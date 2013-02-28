function graph = prtGraphDataGenKarate
% graph = prtGraphDataGenKarate
%   Read karate.gml
%
% From the README:
%
% The file karate.gml contains the network of friendships between the 34
% members of a karate club at a US university, as described by Wayne
% Zachary in 1977.  If you use these data in your work, please cite W. W.
% Zachary, An information flow model for conflict and fission in small
% groups, Journal of Anthropological Research 33, 452-473 (1977).

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


baseDir = prtGraphDataDir;
gmlFile = 'karate.gml';
file = fullfile(baseDir,gmlFile);

[sparseGraph,names] = prtUtilReadGml(file);
graph = prtDataTypeGraph(sparseGraph,names);
