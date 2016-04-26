function ds = prtDataGenGlass







file = fullfile(prtRoot,']beta','dataGen','dataStorage','glass','glass.data');
if ~exist(file,'file')
    error('prtDataGenGlass:MissingFile','The UCI Glass file, glass.data, was not found in %s',fileparts(file));
end

fid = fopen(file,'r');
C = textscan(fid,'%f %f %f %f %f %f %f %f %f %f %f','commentstyle','#','Delimiter',',');
fclose(fid);

ds = prtDataSetClass(cat(2,C{2:(end-1)}),C{end},'name','UCI Glass Data');

featureNames = {'RI';
                'Na';
                'Mg';
                'Al';
                'Si';
                'K';
                'Ca';
                'Ba';
                'Fe';};

[dontNeed, dontNeed, newTargets] = unique(ds.getTargets); %#ok<ASGLU>
ds = ds.setTargets(newTargets);
            
classNames = {'building windows/float processed';
              'building windows/non-float processed';
              'vehicle windows/float processed'; %'vehicle_windows_non_float_processed (none in this database)';
              'containers';
              'tableware';
              'headlamps';};

isWindowGlass = ismember(newTargets,1:3);          
isFloatProcessed = ismember(newTargets,[1 3]);

ds = ds.setObservationInfo('isWindow',isWindowGlass,'isFloatProcessed',isFloatProcessed);

ds = ds.setFeatureNames(featureNames);
ds = ds.setClassNames(classNames);
