classdef prtDataSetBase
    % Abstract class prtDataSetBase serves as a base class for all labeled and
    % unlabeled data sets.  Concrete classes that inherit from
    % prtDataSetBase must implement Abstract methods
    %   
    % Abstract properties:
    %   dataSetName
    %   featureNames
    %   observationNames
    %   
    % and Abstract Dependent properties:
    %   nDimensions
    %   nObservations
    
    
    methods (Abstract)
        data = getObservations(obj,indices1,indices2)
    end
    properties (Abstract, SetAccess = 'private')
        dataSetName         % char
        featureNames        % cellstr, 1 x nDimensions
        observationNames    % cellstr, nObservations x 1 cell
    end
    properties (Dependent, Abstract)
        nObservations       % size(data,1)
        nDimensions         % size(data,2)
    end
    
    methods
        %% Set Methods
        function obj = set.dataSetName(obj, dataSetName)
            if ~isa(dataSetName,'char');
                error('prt:prtDataSetLabeled:dataSetNameNonString','dataSetName is a (%s), but dataSetName must be a character array',class(dataSetName));
            end
            obj.dataSetName = dataSetName;
        end
        function obj = set.data(obj, data)
            if ~isa(data,'double') || ndims(data) ~= 2
                error('prt:prtDataSetLabeled:invalidData','data must be a 2-Dimensional double array');
            end
            obj.data = data;
        end
        function obj = set.featureNames(obj, featureNames)
            if size(featureNames(:),1) ~= obj.nDimensions
                error('prt:prtDataSetLabeled:dataFeaturesMismatch','obj.nDimensions (%d) must match size(featureNames(:),1) (%d)',obj.nDimensions,size(featureNames,2));
            end
            obj.featureNames = featureNames(:);
        end
        %%
    end
end
