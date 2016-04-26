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
