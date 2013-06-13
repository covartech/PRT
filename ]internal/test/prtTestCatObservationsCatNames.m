function testPassed = prtTestCatObservationsCatNames

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
    %assert(isequal(dsCat.classNames,'Class Test'));
    assert(isequal(dsCat.classNames,{'Class Test'})); % Test changed 2013-06-12
catch ME
    prtUtilTestErrorDisplay(ME);
    testPassed = false;
end
