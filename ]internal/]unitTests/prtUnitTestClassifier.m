classdef prtUnitTestClassifier < matlab.unittest.TestCase
    % prtUnitTestClassifier
    %  Example test for classifiers.
    %
    %  tester = prtUnitTestClassifier('classifier',prtClassFld,'perfLimsKfoldsUnimodal',[.9 1])
    %  fldResults = tester.run;
    %
    %  tester = prtUnitTestClassifier('classifier',prtClassKnn,'perfLimsKfoldsUnimodal',[.95 1])
    %  knnResults = tester.run;
    %
    properties
        classifier
        perfLimsKfoldsUnimodal
        forceFileRegenerate = false;
    end
    
    methods
        function self = prtUnitTestClassifier(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Test)
        function testKfoldsPercentCorrectUnimodal(self)
            
            performanceBounds = getExpectedResults(self,'prtDataGenUnimodal');
            ds = prtDataGenUnimodal;
            answer = evaluate(self,ds);
            self.verifyGreaterThan(answer,performanceBounds.minPerf);
            self.verifyLessThan(answer,performanceBounds.maxPerf);
        end
        
        function testPlot2D(self)
            c = self.classifier.train(prtDataGenUnimodal);
            plot(c);
        end
        
        function testPlot3D(self)
            ds = catFeatures(prtDataGenUnimodal,prtDataGenUnimodal);
            ds = ds.retainFeatures(1:3);
            
            c = self.classifier.train(ds);
            plot(c);
        end
        
    end
    
    methods
        
        function result = evaluate(self,ds)
            yOut = kfolds(self.classifier,ds,3);
            [~,~,~,result] = prtScoreRoc(yOut);
        end
        
        function genResultsFile(self,dataSetFn)
            resultsFileName = prtUnitTestClassifier.getResultsFile(self.classifier,dataSetFn);
            
            results = nan(20,1);
            for i = 1:20;
                ds = feval(dataSetFn);
                results(i) = evaluate(self,ds);
            end
            save(resultsFileName,'results');
        end
        
        function performanceBounds = getExpectedResults(self,dataSetFn)
            resultsFileName = prtUnitTestClassifier.getResultsFile(self.classifier,dataSetFn);
            
            if ~exist(resultsFileName,'file') || self.forceFileRegenerate
                genResultsFile(self,dataSetFn);
            end
            
            exist(resultsFileName,'file')
            performanceBounds = load(resultsFileName);
            performanceBounds.minPerf = min(performanceBounds.results);
            performanceBounds.maxPerf = max(performanceBounds.results);
        end
    end
    methods (Static)
        function resultsFileName = getResultsFile(classifier,dataSetFn)
            resultsFileName = cat(2,genvarname(cat(2,'unitTestMat_',classifier.nameAbbreviation,'_',dataSetFn)),'.mat');
        end 
    end
end
