function testPassed = prtTestCatObservationsCatNames

testPassed = true;
nObs = 10;

% Test class ordering for different classes
for i = 1:3
    classNames{i} = sprintf('Class %d',i);
    ds{i} = prtDataSetClass(randn(nObs,1),prtUtilY(nObs));
    ds{i}.classNames = classNames(i);
end
dsCat = catObservations(ds{:});

try
    assert(isequal(dsCat.targets,prtUtilY(nObs,nObs,nObs)));
catch ME
    prtUtilTestErrorDisplay(ME);
    testPassed = false;
end

try
    assert(isequal(dsCat.classNames,classNames(:)));
catch ME
    prtUtilTestErrorDisplay(ME);
    testPassed = false;
end


%What about different class indices but with the same class name? (Should
%merge all the indices to be the same, and point to the same class name)
for i = 1:3
    classNames{i} = sprintf('Class Test');
    ds{i} = prtDataSetClass(randn(nObs,1),ones(nObs,1)*i);
    ds{i}.classNames = classNames(i);
end
dsCat = catObservations(ds{:});

try
    assert(isequal(dsCat.targets,ones(dsCat.nObservations,1)))
catch ME
    prtUtilTestErrorDisplay(ME);
    testPassed = false;
end

try
    assert(isequal(dsCat.classNames,'Class Test'));
catch ME
    prtUtilTestErrorDisplay(ME);
    testPassed = false;
end
