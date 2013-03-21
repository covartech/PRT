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
        perfLimsKfoldsUnimodal = [.9 1];
    end
    
    methods
        function self = prtUnitTestClassifier(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
    end
    methods (Test)
        function testKfoldsPercentCorrectUnimodal(self)
            
            ds = prtDataGenUnimodal;
            yOut = kfolds(self.classifier,ds,3);
            yOut = rt(prtDecisionBinaryMinPe,yOut);
            answer = prtScorePercentCorrect(yOut);
            self.verifyGreaterThan(answer,self.perfLimsKfoldsUnimodal(1));
            self.verifyLessThan(answer,self.perfLimsKfoldsUnimodal(2));
            
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
end
