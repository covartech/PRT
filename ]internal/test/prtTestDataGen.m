function result = prtTestDataGen
% This test makes sure that all prtDataGen* functions load a data set
% without error. it does not check that the data is correct

result = true;

try
    ds = prtDataGenBimodal;
catch
    disp('prtDataGenBimodal error');
    result = false;
end

if ~isa(ds,'prtDataSetClass')
    disp('prtDataGenBimodal wrong class')
    result = false;
end
   

try
    ds = prtDataGenCircles;
catch
    disp('prtDataGenCircles error');
    result = false;
end

if ~isa(ds,'prtDataSetClass')
    disp('prtDataGenCircles wrong class')
    result = false;
end

try
    ds = prtDataGenIris;
catch
    disp('prtDataGenIris error');
    result = false;
end

if ~isa(ds,'prtDataSetClass')
    disp('prtDataGenIris wrong class')
    result = false;
end

try
    ds = prtDataGenMary;
catch
    disp('prtDataGenMary error');
    result = false;
end

if ~isa(ds,'prtDataSetClass')
    disp('prtDataGenMary wrong class')
    result = false;
end
   
try
    ds = prtDataGenNoisySinc;
catch
    disp('prtDataGenNoisySinc error');
    result = false;
end

if ~isa(ds,'prtDataSetRegress')
    disp('prtDataGenNoisySinc wrong class')
    result = false;
end
   

try
    ds = prtDataGenOldFaithful;
catch
    disp('prtDataGenOldFaithful error');
    result = false;
end

if ~isa(ds,'prtDataSetStandard')
    disp('prtDataGenOldFaithful wrong class')
    result = false;
end
   
try
    ds = prtDataGenProstate;
catch
    disp('prtDataGenProstate error');
    result = false;
end

if ~isa(ds,'prtDataSetClass')
    disp('prtDataGenProstate wrong class')
    result = false;
end
   
try
    ds = prtDataGenSpiral;
catch
    disp('prtDataGenSpiral error');
    result = false;
end

if ~isa(ds,'prtDataSetClass')
    disp('prtDataGenSpiral wrong class')
    result = false;
end
   
% try
%     ds = prtDataGenSpiral3Regress;
% catch
%     disp('prtDataGenSpiral3Regress error');
%     result = false;
% end
% 
% if ~isa(ds,'prtDataSetRegress')
%     disp('prtDataGenSpiral3Regress wrong class')
%     result = false;
% end
   

% try
%     ds = prtDataGenSwissRoll;
% catch
%     disp('prtDataGenSwissRoll error');
%     result = false;
% end
% 
% if ~isa(ds,'prtDataSetRegress')
%     disp('prtDataGenSwissRoll wrong class')
%     result = false;
% end
   
try
    ds = prtDataGenUnimodal;
catch
    disp('prtDataGenUnimodal error');
    result = false;
end

if ~isa(ds,'prtDataSetClass')
    disp('prtDataGenUnimodal wrong class')
    result = false;
end
   
try
    ds = prtDataGenXor;
catch
    disp('prtDataGenXor error');
    result = false;
end

if ~isa(ds,'prtDataSetClass')
    disp('prtDataGenXor wrong class')
    result = false;
end
   

