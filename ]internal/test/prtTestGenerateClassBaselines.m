function  prtGenerateClassBaseline

files = what([prtRoot, '/class']);  % get a list of files
files = files.m;

baselineCell = cell(length(files),4);

for i = 1:length(files)
    
    class = files{i};
    class(end-1:end) = [];  % delete the .m
    if ~isAbstract(class)
        classifier = eval(class);
        rng(12345)
        TestDataSet = prtDataGenUnimodal;
        rng(56789)
        TrainingDataSet = prtDataGenUnimodal;
        classifier.internalDecider = prtDecisionBinaryMinPe;
        
        classifier = classifier.train(TrainingDataSet);
        %     percentCorr = prtEvalPercentCorrect(classifier, TestDataSet);
        result = classifier.run(TestDataSet);
        percentCorr = prtScorePercentCorrect(result.getX, result.getY);
        
        
        baselineCell{i,1} = class;
        baselineCell{i,2} = percentCorr;
        
        
        % cross-val baseline
        keys = mod(1:TestDataSet.nObservations,2);
        crossVal = classifier.crossValidate(TestDataSet,keys);
        baselineCell{i,3} = prtScorePercentCorrect(crossVal);
        
        % k-folds baseline
        rng(1111)
        crossVal = classifier.kfolds(TestDataSet,2);
        baselineCell{i,4} = prtScorePercentCorrect(crossVal);
    end
    
end

save baselineClassification baselineCell
