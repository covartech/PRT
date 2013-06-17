function DataSet = prtDataGenSpiral3Class
%   prtDataGenSpiral3Class Read in example 3 classes of spiral data 
%
%   DataSet = prtDataGenSpiral3Class reads in the data that represents 3
%   spirals in 2 dimensions
%
%   Reference: Chang, H. and D.Y. Yeung, Robust path-based spectral clustering. 
%   Pattern Recognition, 2008. 41(1): p. 191-203. 
%
%   Example:
% 
%   ds = prtDataGenSpiral3Class;
%   ds.plot;
%    
%   See also: prtDataSetClass, prtDataGenBiModal, prtDataGenIris,
%   prtDataGenMary, prtDataGenNoisySinc, prtDataGenOldFaithful,
%   prtDataGenSpiral, prtDataGenUnimodal, prtDataGenUnimodal, prtDataGenXor

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


spiral3ClassFile = fullfile(prtRoot,'dataGen','dataStorage','spiral3Class','spiral3Class.txt');
if ~exist(spiral3ClassFile,'file')
    error('prtDataGenSpiral3Class:MissingSpiral3ClassFile','The file, spiral3Class.txt, was not found in %s',spiral3ClassFile);
end

%[f1,f2,f3,f4,class] = textread(irisFile,'%f %f %f %f %s','commentstyle','shell');
fid = fopen(spiral3ClassFile,'r');
C = textscan(fid,'%f %f %f','commentstyle','#');
fclose(fid);

DataSet = prtDataSetClass(cat(2,C{1},C{2}),C{3});
DataSet.name = 'prtDataGenSpiral3Class';
