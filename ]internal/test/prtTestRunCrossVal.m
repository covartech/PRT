function result = prtTestRunCrossVal(files,baselineCell,dataGen, scoreMetric)
% RESULT = prtTestRunCrossVal(files,baselineCell,dataGen, scoreMetric)
%  FILES must be a list of M-file objects to be validated
%
%  BASELINECELL is a cell array of file names and their corresponding
%  baseline metrics
%
%  DATAGEN must be a function handle pointing to a prtDataGen function
%
%  SCOREMETRIC must be a function handle pointing to a prtScore function


% use SCORE Functions instead of eval bc i want it to work with cross-val


result = true;

for i = 1:length(files)
    
     class = files{i};
    class(end-1:end) = [];  % delete the .m
    if ~isAbstract(class)
        classifier = eval(class);
        %         TestDataSet = prtDataGenUnimodal;
        %         TrainingDataSet = prtDataGenUnimodal;
        rng(12345)
        TestDataSet = dataGen();
        rng(56789)
        TrainingDataSet = dataGen();
        if isa(classifier,'prtClass')
            classifier.internalDecider = prtDecisionBinaryMinPe;
        end
        classifier = classifier.train(TrainingDataSet);
        
        classNames =  baselineCell;
        classNames(:,2) = [];
        idx = find( strcmp(classNames,class));
        
        if isempty(idx)
            disp(['no baseline found for', class]);
            result = false;
        end
        
        runResult = classifier.run(TestDataSet);
        resultMetric = scoreMetric(runResult.getX, runResult.getY);
        
        if(~prtUtilApproxEqual(resultMetric, baselineCell{idx,2}, 1e-3));
            disp([files{i} ' classification below baseline'])
            result = false;
        end
        
        keys = mod(1:TestDataSet.nObservations,2);
        crossVal = classifier.crossValidate(TestDataSet,keys);
        
        resultMetric = scoreMetric(crossVal, TestDataSet);
        
        if(~prtUtilApproxEqual(resultMetric, baselineCell{idx,3}, 1e-3));
            
            disp([files{i} ' cross-val below baseline'])
            result = false;
        end
        
        % % k-folds
        rng(1111)
        crossVal = classifier.kfolds(TestDataSet,2);
        
        resultMetric = scoreMetric(crossVal, TestDataSet);
        
        if(~prtUtilApproxEqual(resultMetric, baselineCell{idx,4}, 1e-2));
            
            disp([files{i} ' k-folds below baseline'])
            result = false;
        end
        
    end
end