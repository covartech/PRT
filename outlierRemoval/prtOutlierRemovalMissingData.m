classdef prtOutlierRemovalMissingData < prtOutlierRemoval
    % prtOutlierRemovalMissingData  Removes missing data from a prtDataSet
    %
    %   NSTDOUT = prtOutlierRemovalMissingData creates a pre-processing
    %   object that removes all missing data as outliers. Missing data are
    %   respresented as NaN's in the original data set.
    %
    %   A prtOutlierRemovalMissingData object also inherits all properties and
    %   functions from the prtOutlierRemoval class.  For more information
    %   on how to control the behaviour of outlier removal objects, see the
    %   help for prtOutlierRemoval.
    %
    %   Example:
    %
    %   dataSet = prtDataGenUnimodal;               % Load a data Set
    %   outlier = prtDataSetClass([NaN NaN],1);     % Create and insert
    %   dataSet = catObservations(dataSet,outlier); % an Outlier
    %
    %   % Create the prtOutlierRemoval object
    %   outRemove = prtOutlierRemovalMissingData('runMode','removeObservation');
    %
    %   outRemove = outRemove.train(dataSet);    % Train and run
    %   dataSetNew = outRemove.run(dataSet);
    %
    %   See Also:  prtOutlierRemoval,
    %   prtOutlierRemovalNonFinite,prtOutlierRemovalNstd







    properties (SetAccess=private)
        % Required by prtAction
        name = 'Missing Data Outlier Removal';  % Missing Data Outlier Removal
        nameAbbreviation = 'MissingDataRemove'   % MissingDataRemove
    end
    
    methods
        
        % Allow for string, value pairs
        function Obj = prtOutlierRemovalMissingData(varargin)
            
            %Need to check this with the string - setting the string in
            %prtOutlierRemoval should change this value...
            Obj.isCrossValidateValid = true;
            
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,twiddle)
            %Nothing to do
        end
        
        function outlierIndices = calculateOutlierIndices(Obj,DataSet) %#ok<MANU> This is OK - don't make it static.
            outlierIndices = isnan(DataSet.getObservations);
        end
        
    end
    
end
