function DataSet = prtDataGenMoon
%   prtDataGenMoon Read in example moon data 
%
%   DataSet = prtDataGenMoon reads in the data that represents interlocking
%   crescent moons.
%
%   Example:
% 
%   ds = prtDataGenMoon;
%   ds.plot;
%    
%   See also: prtDataSetClass, prtDataGenBiModal, prtDataGenIris,
%   prtDataGenMary, prtDataGenNoisySinc, prtDataGenOldFaithful,
%   prtDataGenSpiral, prtDataGenUnimodal, prtDataGenUnimodal, prtDataGenXor







moonFile = fullfile(prtRoot,'dataGen','dataStorage','moon','moonData.txt');
if ~exist(moonFile,'file')
    error('prtDataGenIris:MissingMoonFile','The file, moonData.txt, was not found in %s',moonFile);
end

%[f1,f2,f3,f4,class] = textread(irisFile,'%f %f %f %f %s','commentstyle','shell');
fid = fopen(moonFile,'r');
C = textscan(fid,'%f %f %f','commentstyle','#');
fclose(fid);

DataSet = prtDataSetClass(cat(2,C{1},C{2}),C{3});
DataSet.name = 'prtDataGenMoon';
