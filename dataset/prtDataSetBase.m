classdef prtDataSetBase
    
    properties (Abstract, Dependent)
        nObservations       % size(data,1)
        nFeatures           % size(data,2)
    end
    
    properties (GetAccess = 'protected',SetAccess = 'protected')
        observationNames = {}
        featureNames = {}
    end
    
    methods
        
        function obsNames = getObservationNames(obj,indices1)
            % getObservationNames - Return DataSet's Observation Names
            %
            %   featNames = getObservationNames(obj) Return a cell array of 
            %   an object's observation names; if setObservationNames has not been 
            %   called or the 'observationNames' field was not set at construction,
            %   default behavior is to return sprintf('Observation %d',i) for all
            %   observations.
            %
            %   featNames = getObservationNames(obj,indices) Return the observation
            %   names for only the specified indices.
            
            if nargin == 1
                indices1 = (1:obj.nObservations)';
            end
            if isempty(obj.observationNames)
                obsNames = prtUtilCellPrintf('Observation %d',num2cell(indices1));
            else
                obsNames = obj.observationNames(indices1);
            end
        end
        
        function obj = setObservationNames(obj,obsNames,indices1)
            % setObservationNames - Set DataSet's Observation Names
            %
            if ~isvector(obsNames)
                error('setObservationNames requires vector obsNames');
            end
            if nargin == 2
                if length(obsNames) ~= obj.nObservations
                    error('setObservationNames with one input requires length(obsNames) == obj.nObservations');
                end
                indices1 = (1:obj.nObservations)';
            end
            
            %Put the default string names in there; otherwise we might end
            %up with empty elements in the cell array 
            if isempty(obj.observationNames)
                obj.observationNames = obj.getObservationNames;
            end 
            obj.observationNames(indices1) = obsNames;
        end
        
        function featNames = getFeatureNames(obj,indices2)
            % getFeatureNames - Return DataSet's Feature Names
            %
            %   featNames = getFeatureNames(obj) Return a cell array of 
            %   an object's feature names; if setFeatureNames has not been 
            %   called or the 'featureNames' field was not set at construction,
            %   default behavior is to return sprintf('Feature %d',i) for all
            %   features.
            %
            %   featNames = getFeatureNames(obj,indices) Return the feature
            %   names for only the specified indices.
            
            if nargin == 1
                indices2 = (1:obj.nFeatures)';
            end
            if isempty(obj.featureNames)
                featNames = prtUtilCellPrintf('Feature %d',num2cell(indices2));
            else
                featNames = obj.featureNames(indices2);
            end
        end
        
        function obj = setFeatureNames(obj,featNames,indices1)
            % setFeatureNames - Set DataSet's Feature Names
            %
            if ~isvector(featNames)
                error('setFeatureNames requires vector featNames');
            end
            if nargin == 2
                if length(featNames) ~= obj.nFeatures
                    error('setFeatureNames with one input requires length(featNames) == obj.nFeatures');
                end
                indices1 = (1:obj.nFeatures)';
            end
            
            %Put the default string names in there; otherwise we might end
            %up with empty elements in the cell array 
            if isempty(obj.featureNames)
                obj.featureNames = obj.getFeatureNames;
            end 
            obj.featureNames(indices1) = featNames;
        end
        
        function bool = isempty(obj)
            bool = obj.nObservations == 0 || obj.nFeatures == 0;
        end
        function s = size(obj)
            s = [obj.nObservations,obj.nFeatures];
        end
        
    end

    methods (Abstract) 
        %all sub-classes must define these behaviors, this is the contract
        %that all "data sets" must follow
        
        %Return the data by indices
        data = getObservations(obj,indices1,indices2)
        %Set the observations to a new set
        obj = setObservations(obj,data,indices1,indices2)
        
        %         handles = plot(obj)
        %         obj = joinFeatures(obj1,obj2)
        %         obj = joinObservations(obj1,obj2)
        %         obj = catObservations(obj1,newObservations)
        %         obj = catFeatures(obj1,newFeatures)
        %
        %         obj = removeObservations(obj,indices)
        %         obj = retainObservations(obj,indices)
        %         obj = replaceObservations(obj,data,indices)
        %
        %         %Note: for BIG data sets, these have to be implemented "trickily" -
        %         %I have an idea
        %         obj = removeFeatures(obj,indices)
        %         obj = retainFeatures(obj,indices)
        %         obj = replaceFeatures(obj,data,indices)
        %
        %         export(obj,exportOptions)
    end
end
