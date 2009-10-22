classdef prtDataSetBase
    % Abstract class prtDataSetBase serves as a base class for all labeled and
    % unlabeled data sets.  Concrete classes that inherit from
    % prtDataSetBase must implement the abstract methods.
    %   
    % Abstract properties:
    %   dataSetName
    %   featureNames
    %   observationNames
    %   
    % Abstract Dependent properties:
    %   nDimensions
    %   nObservations
    
    properties (Abstract)
        name                % char
        description         % char
        UserData            % Struct of additional data
    end
    properties (Abstract, SetAccess = 'protected', GetAccess = 'protected')
        featureNames        % cellstr, 1 x nDimensions
        observationNames    % cellstr, nObservations x 1 cell
        data                % matrix, doubles, features, (for loaded data)
    end
    properties (Abstract, Dependent)
        nObservations       % size(data,1)
        nFeatures           % size(data,2)
    end
    
    methods (Abstract)
        %% Access methods for protected properties
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        data = getObservations(obj,indices1,indices2)
        obsNames = getObservationNames(obj,indices)
        featureNames = getFeatureNames(obj,indices)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%        
        %% Other methods to be nice to users
        % These are not abstract but they should be implimented by most
        % sub-classes
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % obj = catFeatures(obj, newData, newFeatureNames)
        % obj = catObservations(obj, newData, newObsNames)
        % obj = joinFeatures(obj,varargin)
        % obj = joinObservations(obj,varargin)
        %
        % n = size(obj)
        % b = isempty(obj)
        % disp(obj)
        % display(obj)
        % export(obj)
        %
        % replaceObservations(obj, obsInds, newObs, featureDimInds)
        % removeObservations(obj, obsInds, featureDimInds)
        % replaceTargets(obj, obsInds, newTargets, targetDimInd)
        % removeTargets(obj, targetDimInd)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end
