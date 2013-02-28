function graph = prtGraphDataGenLesMis
% graph = prtGraphDataGenSlashdot
%   Read lesmis.gml
%
% From the README:
% 
% The file lesmis.gml contains the weighted network of coappearances of
% characters in Victor Hugo's novel "Les Miserables".  Nodes represent
% characters as indicated by the labels and edges connect any pair of
% characters that appear in the same chapter of the book.  The values on
% the edges are the number of such coappearances.  The data on
% coappearances were taken from D. E. Knuth, The Stanford GraphBase: A
% Platform for Combinatorial Computing, Addison-Wesley, Reading, MA (1993).

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
gmlFile = 'lesmis.gml';
file = fullfile(baseDir,gmlFile);

[sparseGraph,names] = prtUtilReadGml(file);
graph = prtDataTypeGraph(sparseGraph,names);
