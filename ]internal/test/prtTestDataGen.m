function result = prtTestDataGen
% This test makes sure that all prtDataGen* functions load a data set
% without error. it does not check that the data is correct

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
   

