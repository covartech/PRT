classdef prtPreProcZmuv < prtPreProc & prtActionBig
    % prtPreProcZmuv   Zero mean unit variance processing
    %
    %   ZMUV = prtPreProcZmuv creates a zero mean unit variance pre
    %   processing object. A prtPreProcZmuv object processes the input data
    %   so that it has zero mean and unit variance.  Use TRAIN to determine
    %   the parameters of the ZMUV object:
    % 
    %   zmuv = prtPreProcZmuv;
    %   zmuv = zmuv.train(ds); 
    %
    %   And use RUN to process a data set:
    %
    %   dsPreProc = zmuv.run(ds);
    %
    %   A prtPreProcZmuv object also inherits all properties and functions from
    %   the prtAction class
    %
    %   Example:
    %
    %   dataSet = prtDataGenIris;       % Load a data set.
    %   dataSet = dataSet.retainFeatures(1:2);
    %   zmuv = prtPreProcZmuv;           % Create a zero-mean unit variance
    %                                    % object
    %   zmuv = zmuv.train(dataSet);      % Compute the mean and variance
    %   dataSetNew = zmuv.run(dataSet);  % Normalize the data
    % 
    %   % Plot
    %   subplot(2,1,1); plot(dataSet);
    %   title(sprintf('Mean: %s; Stdev: %s',mat2str(mean(dataSet.getObservations),2),mat2str(std(dataSet.getObservations),2)))
    %   subplot(2,1,2); plot(dataSetNew);
    %   title(sprintf('Mean: %s; Stdev: %s',mat2str(mean(dataSetNew.getObservations),2),mat2str(std(dataSetNew.getObservations),2)))
    %
     %   See Also: prtPreProc, prtPreProcPca, prtPreProcPls,
    %   prtPreProcHistEq, prtPreProcZeroMeanColumns, prtPreProcLda,
    %   prtPreProcZeroMeanRows, prtPreProcLogDisc, prtPreProcZmuv,
    %   prtPreProcMinMaxRows 

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
        name = 'Zero Mean Unit Variance'  % Zero Mean Unit Variance
        nameAbbreviation = 'ZMUV'  % ZMUV
    end
    
    properties (SetAccess=private)
        % General Classifier Properties
        means = [];   % The original data means
        stds = [];    % The original data standard deviation
    end
    
    methods
        function Obj = prtPreProcZmuv(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected,Hidden=true)
        
        function self = trainAction(self,ds)
            % Compute the means and standard deviation
            self.stds = prtUtilNanStd(ds.getObservations(),1);
            self.means = prtUtilNanMean(ds.getObservations(),1);
            if any(~isfinite(self.stds) | self.stds == 0)
                warning('prtPreProcZmuv:nonFiniteStds','Non-finite or zero standard deviation encountered.  Replacing invalid standard deviations with 1');
                self.stds(~isfinite(self.stds) | self.stds == 0) = 1;
            end
            if any(~isfinite(self.means))
                warning('prtPreProcZmuv:nonFiniteMean','Non-finite mean encountered.  Replacing invalid means with 0');
                self.means(~isfinite(self.means)) = 0;
            end
        end
        
        function self = trainActionBig(self, dsBig)
            mrMeanObj = prtMapReduceMean;
            self.means = mrMeanObj.run(dsBig);

            mrStdObj = prtMapReduceStd; 
            mrStdObj.mean = self.means;
            self.stds = mrStdObj.run(dsBig);
            
            if any(~isfinite(self.stds) | self.stds == 0)
                warning('prtPreProcZmuv:nonFiniteStds','Non-finite or zero standard deviation encountered.  Replacing invalid standard deviations with 1');
                self.stds(~isfinite(self.stds) | self.stds == 0) = 1;
            end
            if any(~isfinite(self.means))
                warning('prtPreProcZmuv:nonFiniteMean','Non-finite mean encountered.  Replacing invalid means with 0');
                self.means(~isfinite(self.means)) = 0;
            end
        end
        
        function ds = runAction(self,ds)
            % Remove the means and normalize the variance
            ds = ds.setObservations(bsxfun(@rdivide,bsxfun(@minus,ds.getObservations(),self.means),self.stds));
        end
        
        function xOut = runActionFast(self,xIn,ds) %#ok<INUSD>
           xOut = bsxfun(@rdivide,bsxfun(@minus,xIn,self.means),self.stds);
        end
    end
    
    methods (Hidden)
        
        function str = exportSimpleText(self) %#ok<MANU>
            titleText = sprintf('%% prtPreProcZmuv\n');
            zmuvMeansText = prtUtilMatrixToText(self.means,'varName','means');
            zmuvVarsText = prtUtilMatrixToText(self.stds,'varName','std');
            str = sprintf('%s%s%s',titleText,zmuvMeansText,zmuvVarsText);
        end
    end
end
