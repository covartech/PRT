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
        dataSetName         %String
        featureNames        %1 x nDimensions cell of strings
        observationNames    %nObservations x 1 cell of strings
    end
    properties (Dependent, Abstract)
        nObservations       %gets the size of the data in dimension 1
        nDimensions         %gets the size of the data in dimension 2
    end
end
