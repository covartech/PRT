function classDefToUml(className)

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


meta = eval(['?',className]);

className = meta.Name;

for i = 1:length(meta.PropertyList)
    name{i} =  meta.PropertyList(i).Name;
    getAccess{i} = meta.PropertyList(i).GetAccess;
    setAccess{i} = meta.PropertyList(i).SetAccess;
    dependent(i) = meta.PropertyList(i).Dependent;
    abstract(i) = meta.PropertyList(i).Abstract;
    spec{i} = {getAccess{i},setAccess{i},dependent(i),abstract(i)};
    
    specString{i} = sprintf('Set: %s Get: %s',getAccess{i},setAccess{i});
    if dependent(i)
        specString{i} = cat(2,specString{i},', Dependent');
    end
    if abstract(i)
        specString{i} = cat(2,specString{i},', Abstract');
    end
    
end

[uSpecs,ind1,ind2] = unique(specString);

fprintf('Class: %s\n',className);
for i = 1:length(uSpecs)
    currSpec = uSpecs{i};
    currInds = find(strcmpi(currSpec,specString));
    
    fprintf('--\n');
    fprintf('Properties (%s)\n',specString{ind1(i)});
    fprintf('--\n');
    for j = 1:length(currInds)
        fprintf('\t%s \n',name{currInds(j)});
    end
    fprintf('\n');
end


defClass = cat(1,meta.MethodList.DefiningClass);
localMethodList = meta.MethodList(strcmpi({defClass.Name},className));

clear name access abstract spec specString
for i = 1:length(localMethodList)
    name{i} =  localMethodList(i).Name;
    access{i} = localMethodList(i).Access;
    abstract(i) = localMethodList(i).Abstract;
    spec{i} = {access{i},abstract(i)};
    
    specString{i} = sprintf('%s',access{i},abstract(i));
    if abstract(i)
        specString{i} = cat(2,specString{i},' Abstract');
    end
end

[uSpecs,ind1,ind2] = unique(specString);

for i = 1:length(uSpecs)
    currSpec = uSpecs{i};
    currInds = find(strcmpi(currSpec,specString));
    
    fprintf('--\n');
    fprintf('Methods (%s)\n',specString{ind1(i)});
    fprintf('--\n');
    for j = 1:length(currInds)
        fprintf('\t%s \n',name{currInds(j)});
    end
    fprintf('\n');
end
    

