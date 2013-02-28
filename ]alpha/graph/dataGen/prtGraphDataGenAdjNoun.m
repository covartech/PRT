function graph = prtGraphDataGenAdjNoun
% graph = prtGraphDataGenAdjNoun
%   Read from adjnoun.gml.
%
% From the README:
%
%The file adjnoun.gml contains the network of common adjective and noun
% adjacencies for the novel "David Copperfield" by Charles Dickens, as
% described by M. Newman.  Nodes represent the most commonly occurring
% adjectives and nouns in the book.  Node values are 0 for adjectives and 1
% for nouns.  Edges connect any pair of words that occur in adjacent
% position in the text of the book.  Please cite M. E. J. Newman, Finding
% community structure in networks using the eigenvectors of matrices,
% Preprint physics/0605087 (2006).

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


[baseDir] = prtGraphDataDir;
gmlFile = fullfile(baseDir,'adjnoun.gml');
graph = prtDataTypeGraph(gmlFile);
