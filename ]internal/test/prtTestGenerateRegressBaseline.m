function  prtTestGenerateRegressBaseline

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