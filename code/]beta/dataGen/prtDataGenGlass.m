function ds = prtDataGenGlass

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
