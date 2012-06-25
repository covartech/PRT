function result = prtTestDataSetStandard3
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