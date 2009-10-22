classdef prtDataSetLabeled < prtDataSetInMemory
    % Standard prtDataSet for labeled training data.
    %
    % Inherited propeties from prtDataSetInMemory
    %   Dependent:
    %    nDimensions   % scalar, number of dimensions (columns) of the data
    %    nObservations % scalar, number of observations (rows) of the data
    %   GetAccess = private
    %    dataSetName = ''      % char
    %    featureNames  = {}    % strcell, 1 x nDimensions
    %    observationNames = {} % strcell, nObservations x 1
    %    data = []             % matrix, doubles, features
    %
    % Inherited methods from prtDataSetInMemory
    %   
    %   plot()
    %   explore() 
    
    % Additional properties for labeled data only:
    properties (SetAccess = 'protected', GetAccess = 'protected')
        targets = []         % matrix, doubles, probably integers
    end
    properties (Dependent)
        nTargetDimensions
    end
    methods
        %% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = prtDataSetLabeled(varargin)
            % Nothing to do.
            % This should only be called when initializing a sub-class
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Get Methods for Dependent properties %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function ntd = get.nTargetDimensions(obj)
            ntd = size(obj.targets,2);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Access methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function t = getTargets(obj, indices1, indices2)
            if nargin < 2 || isempty(indices1)
                indices1 = 1:obj.nObservations;
            end
            if max(indices1) > obj.nObservations || min(indices1) < 1
                error('prt:prtDataSetLabeled:invalidInputs','Invalid requested observation dimensions.')
            end
            if nargin < 3 || isempty(indices2)
                indices2 = 1:obj.nTargetDimensions;
            end
            if max(indices2) > obj.nTargetDimensions || min(indices2) < 1
                error('prt:prtDataSetLabeled:invalidInputs','Invalid requested target dimensions.')
            end
            
            t = obj.targets(indices1,indices2);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Other Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = catObservations(obj, newData, newTargets, newObsNames)
            % This is an overload of the method in prtDataSetInMemory
            % because we need newTargets. So we do the error checking, run
            % the base function to add the data and observation names and
            % then add the newLabels
            
            if nargin < 4
                newObsNames = {};
            end
            
            if size(newData,1) ~= size(newTargets,1)
                error('prt:prtDataSetLabeled:incorrectInput','The number of observations in the new data and new targets do not match.');
            end
            
            if obj.nTargetDimensions ~= size(newTargets,2)
                error('prt:prtDataSetLabeled:incorrectInput','The dimensionality of newTargets does not match the existing target dimensionality.');
            end
            
            % Add the new data
            obj = catObservations@prtDataSetInMemory(obj, newData, newObsNames);
            
            % Add the new labels
            obj.targets = cat(1, obj.targets, newTargets);
        end
        function obj = joinFeatures(obj, varargin)
            for iCat = 1:length(varargin)
                if ~isequal(obj.getTargets, varargin{iCat}.getTargets);
                    error('prt:prtDataSetLabeled:truthMismatch','To join the features of multiple datasets, the targets of all of the dataSets must be identical.');
                end
                obj = catFeatures(obj, varargin{iCat}.getObservations, varargin{iCat}.getFeatureNames);
            end
        end
        function obj = joinObservations(obj, varargin)
            for iCat = 1:length(varargin)
                obj = catObservations(obj, varargin{iCat}.getObservations, varargin{iCat}.getTargets, varargin{iCat}.getObservationNames);
            end
        end
        
        function obj = sortByTargets(obj, varargin)
            error('Not Done Yet')
            %obj = sortByTargets(obj, 'ascend') % Use Rows
            %obj = sortByTargets(obj, targetInd, 'ascend')
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end
