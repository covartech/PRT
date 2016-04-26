classdef prtOutlierRemovalNonFinite < prtOutlierRemoval
    % prtOutlierRemovalNonFinite  Removes missing data from a prtDataSet
    %
    %   OutRemove = prtOutlierRemovalNonFinite creates a pre-processing
    %   object that removes all missing data as outliers. Missing data are
    %   respresented as NaN's in the original data set.
    %
    %   A prtOutlierRemovalNonFinite object also inherits all properties and
    %   functions from the prtOutlierRemoval class.  For more information
    %   on how to control the behaviour of outlier removal objects, see the
    %   help for prtOutlierRemoval.
    %
    %   Example:
    %
    %   dataSet = prtDataGenUnimodal;               % Load a data Set
    %   outlier = prtDataSetClass([NaN NaN; inf inf],[1;1]);     % Create and insert
    %   dataSet = catObservations(dataSet,outlier); % an Outlier
    %
    %   % Create the prtOutlierRemoval object
    %   nonFiniteRemove = prtOutlierRemovalNonFinite('runMode','removeObservation');
    %
    %   nonFiniteRemove = nonFiniteRemove.train(dataSet);    % Train and run
    %   dataSetNew = nonFiniteRemove.run(dataSet);
    %
    %   See Also:  prtOutlierRemoval,
    %   prtOutlierRemovalMissingData ,prtOutlierRemovalNstd







    properties (SetAccess=private)
        % Required by prtAction
        name = 'Non Finite Data Outlier Removal';  % NonFinite Data Outlier Removal
        nameAbbreviation = 'NonFiniteDataRemove'   % NonFiniteDataRemove
    end
    
    methods
        
        % Allow for string, value pairs
        function Obj = prtOutlierRemovalNonFinite(varargin)
            
            %Need to check this with the string - setting the string in
            %prtOutlierRemoval should change this value...
            Obj.isCrossValidateValid = true;
            
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,~)
            %Nothing to do
        end
        
        function outlierIndices = calculateOutlierIndices(Obj,DataSet) %#ok<MANU> This is OK - don't make it static.
            outlierIndices = ~isfinite(DataSet.getObservations);
        end
        
    end
    
end
