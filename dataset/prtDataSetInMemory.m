classdef prtDataSetInMemory < prtDataSetBase & prtDataSetBaseInMemory
    
    properties (Dependent)
        nObservations       % size(data,1)
        nFeatures           % size(data,2)
    end
    
    % inherits: data, targets from prtDataSetInMemoryTemp
    
    methods
        
        function nObservations = get.nObservations(obj)
            nObservations = size(obj.data,1); %use InMem's .data field
        end
        function nFeatures = get.nFeatures(obj)
            nFeatures = size(obj.data,2);
        end
        
        function obj = joinObservations(obj, varargin)
            for iCat = 1:length(varargin)
                %note: use the protected .observationNames here to avoid 
                %building these cell arrays if they aren't already set (as opposed to
                %getObservationNames)
                obj = catObservations(obj, varargin{iCat}.getObservations, varargin{iCat}.observationNames);
            end
        end
        
        function obj = joinFeatures(obj, varargin)
            for iCat = 1:length(varargin)
                %note: use the protected .featureNames here to avoid 
                %building these cell arrays if they aren't already set (as opposed to
                %getFeatureNames)
                obj = catFeatures(obj, varargin{iCat}.getObservations, varargin{iCat}.featureNames);
            end
        end
        
        function obj = catFeatures(obj, newData, newFeatureNames)
            
            if nargin < 3
                newFeatureNames = {};
            elseif ~isempty(newFeatureNames)
                if ~iscellstr(newFeatureNames)
                    error('prt:prtDataSetInMemory:incorrectInput','newObsNames, must be a cellstr.');
                end
                if length(newFeatureNames) ~= size(newData,2)
                    error('prt:prtDataSetInMemory:incorrectInput','The number of features in the new data and the new f names do not match.');
                end
            end
            oldDim = obj.nFeatures;
            
            obj = catFeatures@prtDataSetInMemory(obj,newData); %inMemory
            obj = addFeatureNames(obj,newFeatureNames,oldDim); %dataSetBase
        end
        
        function obj = catObservations(obj, newData, newObsNames)
            if nargin < 3
                newObsNames = {};
            elseif ~isempty(newObsNames)
                if ~iscellstr(newObsNames)
                    error('prt:prtDataSetInMemory:incorrectInput','newObsNames, must be a cellstr.');
                end
                if length(newObsNames) ~= size(newData,1)
                    error('prt:prtDataSetInMemory:incorrectInput','The number of observations in the new data and the new observation names do not match.');
                end
            end
            
            if size(newData,2) ~= obj.nFeatures
                error('prt:prtDataSetInMemory:incorrectDimensionality','The dimensionality of the specified data (%d) does not match the dimensionality of this dataset (%d).', size(newData,2), obj.nFeatures);
            end
            
            oldN = obj.nObservations;
            
            obj = catObservations@prtDataSetInMemory(obj,newData);     %inMemory
            obj = addObservationNames(obj,newObsNames,oldN);           %dataSetBase
        end
        
               
    end
        
end