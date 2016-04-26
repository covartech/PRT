function classDefToUml(className)







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
    

