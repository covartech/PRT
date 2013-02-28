classdef prtClassOneClassRvm < prtClass
    %prtClassOneClassRvm < prtClass
    % This is a one-class RVM.  It learns a regression RVM to approximate
    % an estimated PDF.  You can set the base RV used to estimate the PDF
    % with the field baseRv.  By default, it's a prtRvKde.
    %
    % ds = prtDataGenUnimodal;
    % ocRvm = prtClassOneClassRvm;
    % ocRvm = train(ocRvm,ds);
    % plot(ocRvm);
    %
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
        name = 'One Class RVM'  % Relevance Vector Machine
        nameAbbreviation = 'ocRVM'           % RVM
        isNativeMary = false;  % False
    end
    properties (Dependent)
        kernels
    end
    
    properties
        useLogPdf = true;
        internalRegressRvm = prtRegressRvm;
        baseRv = prtRvKde;
    end
    
    methods
        function self = prtClassOneClassRvm(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
        function self = set.kernels(self,kernelVals)
            self.internalRegressRvm.kernels = kernelVals;
        end
        function outKernels = get.kernels(self)
            outKernels = self.internalRegressRvm.kernels;
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,dataSet)
            %self = trainAction(self,dataSet)
                
            dsH1 = dataSet.retainClassesByInd(2);
            
            rv = self.baseRv;
            rv = rv.mle(dsH1);
            
            if self.useLogPdf
                dsH1Regress = prtDataSetRegress(dsH1.getX,rv.logPdf(dsH1));
            else
                dsH1Regress = prtDataSetRegress(dsH1.getX,rv.pdf(dsH1));
            end
            
            self.internalRegressRvm = self.internalRegressRvm.train(dsH1Regress);
        end
            
        
        function yOut = runAction(self,dataSet)
            yOut = dataSet;
            
            regressDataSet = prtDataSetRegress(dataSet.getX);
            regressDataSetOut = self.internalRegressRvm.run(regressDataSet);
            
            if self.useLogPdf
                yOut.X = exp(regressDataSetOut.X);
            else
                yOut.X = regressDataSetOut.X;
            end
            
        end
    end
end
