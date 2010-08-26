classdef prtPreProcZmuv < prtPreProc
    % prtPreProcZmuv   Zero mean unit variance
    %
    %   ZMUV = prtPreProcZmuv creates a zero mean unit variance pre
    %   processing object. A prtPreProcZmuv object processes the input data
    %   so that it has zero mean and unit variance.
    %
    %   A prtPreProcZmuv object also inherits all properties and functions from
    %   the prtAction class
    %
    %   Example:
    %
    %   dataSet = prtDataGenProstate;       % Load a data set.
    %   zmuv = prtPreProcZmuv;           % Create a zero-mean unit variance
    %                                    % object
    %   zmuv = zmuv.train(dataSet);      % Compute the mean and variance
    %   dataSetNew = zmuv.run(dataSet);  % Normalize the data
    % 
    %   mean(dataSetNew.getObservations())     %Check the mean
    %   var(dataSetNew.getObservations())      %Check the variance
    %
    %   See Also: prtPreProcPca, prtPreProcHistEq, preProcLogDisc
 
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Zero Mean Unit Variance'
        nameAbbreviation = 'ZMUV'
        isSupervised = false;
    end
    
    properties (SetAccess=private)
        % General Classifier Properties
        means = [];   % The original data means
        stds = [];    % The original data standard deviation
    end
    
    methods
        % Allow for string, value pairs
        % There are no user settable options though.
        function Obj = prtPreProcZmuv(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected)
        
        function Obj = trainAction(Obj,DataSet)
            % Compute the means and standard deviation
            Obj.stds = nanstd(DataSet.getObservations(),0,1);
            Obj.means = nanmean(DataSet.getObservations(),1);
        end
        
        function DataSet = runAction(Obj,DataSet)
            % Remove the means and normalize the variance
            DataSet = DataSet.setObservations(bsxfun(@rdivide,bsxfun(@minus,DataSet.getObservations(),Obj.means),Obj.stds));
        end
        
    end
    
end