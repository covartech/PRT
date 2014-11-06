classdef prtPreProcBootstrapTraining < prtPreProc
    % prtPreProcBootstrapTraining  Bootstrap data during training; do nothing
    %   at run time.
    %
    % prtPreProcBootstrapTraining creats a BootstrapTraining object which
    % when used as part of an algorithm, bootstrap's data during training,
    % and passes data through to the next block without bootstrapping
    % at run time.  This is generally the expected behavior - we
    % down-sample to train, but don't use a bootstrap estimate to generate
    % our ROC curves.  prtPreProcBootstrapTraining is useful for building
    % algorithms from data sets where the computational complexity of
    % training is computationally intractable for the entire data set.
	%
    %
    % Properties:
    %   nSamples (1000): The number of samples to bootstrap in total or
    %       from each class; see boostrapByClass.
    %
    %   boostrapByClass (true): Whether to call dataSet.bootstrapByClass 
    %       or dataSet.bootstrap
    %
    %  % Example use; this generates 10 different FLD's using very few (10)
    %  %samples from each class in prtDataGenBimodal
    %  ds = prtDataGenBimodal;
    %  algo = prtPreProcBootstrapTraining('nSamples',10) + prtClassFld;
    %  for i = 1:10;
    %     algo = algo.train(ds);
    %     yOut = algo.run(ds);
    %     [pf,pd] = prtScoreRoc(yOut);
    %     plot(pf,pd); 
    %     hold on;
    %  end
    %  hold off; 
    %
    %  % Note, the following lines of code does nothing,
    %  % prtPreProcBootstrapTraining is only useful inside of multi-object
    %  % algorithms (see above).
    %
    %  boot = prtPreProcBootstrapTraining;
    %  boot = boot.train(ds);
    %  yOut = boot.run(ds);  %do nothing, since .run doesn't call .runOnTraining
    % 

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


    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Bootstrap (Training)'
        nameAbbreviation = 'BootTrain'
    end
    
    properties
        %no properties
        nSamples = 1000;
        bootstrapByClass = true;
    end
    properties (SetAccess=private)
        % General Classifier Properties
    end
    
    methods
        
          % Allow for string, value pairs
        function self = prtPreProcBootstrapTraining(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Hidden)
        function DataSet = runOnTrainingData(self,DataSet)
            
            if self.bootstrapByClass
                DataSet = DataSet.bootstrapByClass(self.nSamples);
            else
                DataSet = DataSet.bootstrap(self.nSamples);
            end            
        end
    end
    
    methods (Access=protected,Hidden=true)
        
        function self = trainAction(self,DataSet)
            %do nothing; this should never be called. since we overload
            %runOnTrainingData
        end
        
        function DataSet = runAction(self,DataSet)
            % Note, prtPreProcBootstrap.run does nothing;
            % .runOnTrainingData does all the work, and only within a
            % prtAlgorithm
        end
        
        function DataSet = runActionFast(self,DataSet)
            % Note, prtPreProcBootstrap.run does nothing;
            % .runOnTrainingData does all the work, and only within a
            % prtAlgorithm
        end
    end
    
end
