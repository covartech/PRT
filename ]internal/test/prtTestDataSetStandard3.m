function result = prtTestDataSetStandard3

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


% Check that we can instantiate a data set
try
    ds = prtDataGenUnimodal;
    result = true;
catch
    ME = MException('prtTestDataSetStandard2:basicFail', ...
        'basic prtDataGen* failure');
    result = false;
    disp(ME)
end

ObsInfo = genFeatureInfo(ds);
ds.featureInfo = ObsInfo;

try
    newDs = ds.retainFeatures(2);
    
    if ~isequal(newDs.featureInfo(1).featName,'Feature #2')
        error('retainFeatures failed ro retain featureInfo correctly');
    end
catch ME
    result = false;
    disp(ME);
end

try 
    n = ds.nFeatures;
    newDs = ds.catFeatures(ds);
    
    if ~isequal(ds.featureInfo(1),newDs.featureInfo(n+1))
        error('catFeatures failed ro retain featureInfo correctly');
    end
catch ME
    result = false;
    disp(ME);
end


% catObservaitons with different observationInfo structures
try
    ds2 = ds.catFeatures(prtDataGenUnimodal);
    
    if ~isequal(fieldnames(ds.featureInfo),fieldnames(ds2.featureInfo))
        error('catFeatures failed to update featureInfo correctly');
    end
    
    if ~isequal(ds2.featureInfo(2).featName,'Feature #2')
        error('catFeatures failed ro retain featureInfo correctly');
    end    
    
catch ME
    result = false;
    disp(ME);
end


function FeatureInfo = genFeatureInfo(ds)

for i = 1:ds.nFeatures;
    featName{i} = sprintf('Feature #%d',i);
    mod2{i} = mod(i,2);
    randInt{i} = round(rand*4);
end
FeatureInfo = struct('featName',featName,'mod2',mod2,'randInt',randInt);
