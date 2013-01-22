classdef prtPreProcZmuv < prtPreProc
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
        
        function Obj = trainAction(Obj,DataSet)
            % Compute the means and standard deviation
            Obj.stds = prtUtilNanStd(DataSet.getObservations(),1);
            Obj.means = prtUtilNanMean(DataSet.getObservations(),1);
            if any(~isfinite(Obj.stds) | Obj.stds == 0)
                warning('prtPreProcZmuv:nonFiniteStds','Non-finite or zero standard deviation encountered.  Replacing invalid standard deviations with 1');
                Obj.stds(~isfinite(Obj.stds) | Obj.stds == 0) = 1;
            end
            if any(~isfinite(Obj.means))
                warning('prtPreProcZmuv:nonFiniteMean','Non-finite mean encountered.  Replacing invalid means with 0');
                Obj.means(~isfinite(Obj.means)) = 0;
            end
        end
        
        function DataSet = runAction(Obj,DataSet)
            % Remove the means and normalize the variance
            DataSet = DataSet.setObservations(bsxfun(@rdivide,bsxfun(@minus,DataSet.getObservations(),Obj.means),Obj.stds));
        end
        
        function xOut = runActionFast(Obj,xIn,ds) %#ok<INUSD>
           xOut = bsxfun(@rdivide,bsxfun(@minus,xIn,Obj.means),Obj.stds);
        end
    end
end