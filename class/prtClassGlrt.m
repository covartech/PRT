classdef prtClassGlrt < prtClass
    % prtClassGlrt  Generalized likelihood ratio test classifier
    %
    %    CLASSIFIER = prtClassGlrt returns a Glrt classifier
    %
    %    CLASSIFIER = prtClassGlrt(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassGlrt object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClassGlrt object inherits all properties from the abstract class
    %    prtClass. In addition is has the following properties:
    %
    %    rvH0 - A prtRvMvn object representing hypothesis 0
    %    rvH1 - A prtRvMvn object representing hypothesis 1
    %
    %    A prtClassGlrt object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT method
    %    from prtClass.
    %
    %    Example:
    %
    %     testDataSet = prtDataGenUniModal;       % Create some test and
    %     trainingDataSet = prtDataGenUniModal;   % training data
    %     classifier = prtClassGlrt;              % Create a classifier
    %     classifier = classifier.train(trainingDataSet);    % Train
    %     classifier.plot;
    %     classified = classifier.run(testDataSet);
    %     subplot(2,1,1);
    %     classifier.plot;
    %     subplot(2,1,2);
    %     [pf,pd] = prtScoreRoc(classified,testDataSet);
    %     h = plot(pf,pd,'linewidth',3);
    %     title('ROC'); xlabel('Pf'); ylabel('Pd');
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassBinaryToMaryOneVsAll
    %    prtClassDlrt, prtClassPlsda, prtClassFld, prtClassRvm,
    %    prtClassGlrt,  prtClass

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
    
        name = 'Generalized likelihood ratio test'  % Generalized likelihood ratio test
        nameAbbreviation = 'GLRT'% GLRT
        isNativeMary = false;  % False
        
    end 
    
    properties
        rvH0 = prtRvMvn;  % Mean and variance of H0
        rvH1 = prtRvMvn;  % Mean and variance of H1
    end
    
    methods
        function self = set.rvH0(self,val)
            assert(isa(val,'prtRv'),'prt:prtClassGlrt:setrvH0','rvH0 must be a subclass of prtRv, but value provided is a %s',class(val));
            self.rvH0 = val;
        end
        function self = set.rvH1(self,val)
            assert(isa(val,'prtRv'),'prt:prtClassGlrt:setrvH1','rvH1 must be a subclass of prtRv, but value provided is a %s',class(val));
            self.rvH1 = val;
        end
        
        function self = prtClassGlrt(varargin)
            
            self = prtUtilAssignStringValuePairs(self,varargin{:});
            
        end
    end
    
    methods (Access=protected, Hidden = true)
       
        function self = trainAction(self,dataSet)
            
            assert(dataSet.isBinary, 'prt:prtClassGlrt:nonBinaryData','prtClassGlrt requires a binary dataSet.');
            
            self.rvH0 = mle(self.rvH0, dataSet.getObservationsByClassInd(1));
            self.rvH1 = mle(self.rvH1, dataSet.getObservationsByClassInd(2));
        end
        
        function dataSet = runAction(self,dataSet) 
            logLikelihoodH0 = logPdf(self.rvH0, dataSet.getObservations());
            logLikelihoodH1 = logPdf(self.rvH1, dataSet.getObservations());
            dataSet = dataSet.setObservations(logLikelihoodH1 - logLikelihoodH0);
        end        
        
        function xOut = runActionFast(self,xIn,ds) %#ok<INUSD>
            logLikelihoodH0 = logPdf(self.rvH0, xIn);
            logLikelihoodH1 = logPdf(self.rvH1, xIn);
            xOut = logLikelihoodH1 - logLikelihoodH0;
        end
    end
end
