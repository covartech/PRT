function  prtTestGenerateRegressBaseline

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


files = what([prtRoot, '/regress']);  % get a list of files
files = files.m;

baselineCell = cell(length(files),4);

for i = 1:length(files)
 
    class = files{i};
    class(end-1:end) = [];  % delete the .m
    if ~isAbstract(class)
        classifier = eval(class);
         rng(12345)
        TestDataSet = prtDataGenNoisySinc;
         rng(56789)
        TrainingDataSet = prtDataGenNoisySinc;
        
        classifier = classifier.train(TrainingDataSet);
        runResult = classifier.run(TestDataSet);
        percentCorr = prtScoreRmse(runResult.getX, runResult.getY);
        
        baselineCell{i,1} = class;
        baselineCell{i,2} = percentCorr;
        
        
        % cross-val baseline        
        keys = mod(1:TestDataSet.nObservations,2);
        crossVal = classifier.crossValidate(TestDataSet,keys);
        baselineCell{i,3} = prtScoreRmse(crossVal.getX, crossVal.getY);
        
        % k-folds baseline
        % one more re-seed.
        rng(1111)
        crossVal = classifier.kfolds(TestDataSet,2);
        baselineCell{i,4} = prtScoreRmse(crossVal.getX, crossVal.getY);
    end
    
end

save baselineRegress baselineCell
