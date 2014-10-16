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

% Copyright (c) 2014 CoVar Applied Technologies
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
