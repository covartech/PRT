classdef prtUnitTestClassVisualization < matlab.unittest.TestCase
    % prtUnitTestClassVisualization
    %  Example test for prtDataSetClass visualization methods.
    %
    %  tester = prtUnitTestClassVisualization('method',@imagesc);
    %  imagescResults = tester.run;
    %
    %  tester = prtUnitTestClassVisualization('method',@plot);
    %  plotResults = tester.run;
    %
    %  tester = prtUnitTestClassVisualization('method',@plotAsTimeSeries);
    %  plotTimeSeriesResults = tester.run; %note - this errors
    % 
    
    properties
        method
        varargin = {};
        pauseAfter = false;
    end
    
    methods
        function self = prtUnitTestClassVisualization(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Test)
        function testBinary(self)
            ds = prtDataGenUnimodal;
            evaluate(self,ds);
            close all;
        end
        
        function testMary(self)
            ds = prtDataGenMary;
            evaluate(self,ds);
        end
        
        
        function testUnlabeled(self)
            ds = prtDataGenMary;
            ds.targets(1:10) = nan;
            evaluate(self,ds);
        end
        
        function testHighDim(self)
            ds = prtDataGenFeatureSelection;
            evaluate(self,ds);
        end
        
        
        function testEmpty(self)
            ds = prtDataSetClass;
            evaluate(self,ds);
        end
        
        
        function testUnary(self)
            ds = prtDataGenMary;
            ds = ds.retainClasses(1);
            evaluate(self,ds);
        end
    end
    
    methods
        
        function result = evaluate(self,ds)
            result = self.method(ds,self.varargin{:});
            drawnow;
            if self.pauseAfter
                disp('paused');
                pause;
            end
            close all;
        end
        
    end
    methods (Static)
        
    end
end
