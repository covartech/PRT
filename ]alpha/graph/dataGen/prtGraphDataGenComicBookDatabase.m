function graph = prtGraphDataGenComicBookDatabase
% graph = prtGraphDataGenComicBookDatabase
%  
%  Database created in October 2012 by Peter Torrione by scraping cbdb.com.  
%  Please cite the PRT if you use this in your work:
% 
% @Manual{prt2011,
%   author =	 {Peter Torrione and Sam Keene and Kenneth Morton },
%   title =	 {{PRT}: The Pattern Recognition Toolbox for {MATLAB}},
%   year =	 {2011},
%   note =	 {Software available at \url{http://newfolderconsulting.com/prt}}
% }

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


[~,bigDataDir] = prtGraphDataDir;
gmlFile = fullfile(bigDataDir,'cbdbDatabase.mat');

if ~exist(gmlFile,'file')
    error('Could not find the bigData graph file %s; you can download it from here: %s',gmlFile,prtGraphDataUrl);
end
load(gmlFile,'cbdbGraph','cbdbCharacterNames');

graph = prtDataTypeGraph(cbdbGraph,cbdbCharacterNames);
