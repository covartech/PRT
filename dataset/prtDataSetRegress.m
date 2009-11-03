classdef prtDataSetRegress < prtDataSetInMemoryLabeled
    % Standard prtDataSet for labeled training data.
    %
    % Inherited propeties from prtDataSetInMemory
    %   Dependent:
    %    nFeatures   % scalar, number of dimensions (columns) of the data
    %    nObservations % scalar, number of observations (rows) of the data
    %   GetAccess = private
    %    dataSetName = ''      % char
    %    featureNames  = {}    % strcell, 1 x nFeatures
    %    observationNames = {} % strcell, nObservations x 1
    %    data = []             % matrix, doubles, features
    %
    % Inherited methods from prtDataSetInMemory
    %   
    %   plot()
    %   explore() 
    
    methods
        %% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function prtDataSet = prtDataSetRegress(varargin)
            % prtDataSet = prtDataSetRegress
            % prtDataSet = prtDataSetRegress(prtDataSetRegressIn, paramName1, paramVal2, ...)
            % prtDataSet = prtDataSetRegress(data, targets, paramName1, paramVal2, ...)
            
            if nargin == 0 % Empty constructor
                % Nothing to do
                return
            end
            
            if isa(varargin{1},'prtDataSetRegress')
                prtDataSet = varargin{1};
                varargin = varargin(2:end);
            else
                if nargin < 2
                    error('prt:prtDataSetRegress:invalidInputs','both data and labels must be specified.');
                end
                if size(varargin{1},1) ~= size(varargin{2},1)
                    error('prt:prtDataSetRegress:dataLabelsMismatch','size(data,1) (%d) must match size(labels,1) (%d)',size(varargin{1},1), size(varargin{2},1));
                end
                prtDataSet.data = varargin{1};
                prtDataSet.targets = varargin{2};
                varargin = varargin(3:end);
            end
            
            % Quick exit if no more inputs.
            if isempty(varargin)
                return
            end
            
            % Check Parameter string, value pairs
            inputError = false;
            if mod(length(varargin),2)
                inputError = true;
            end
            paramNames = varargin(1:2:(end-1));
            if ~iscellstr(paramNames)
                inputError = true;
            end
            paramValues = varargin(2:2:end);
            if inputError
                error('prt:prtDataSetRegress:invalidInputs','additional input arguments must be specified as parameter string, value pairs.')
            end
            % Set Values
            for iPair = 1:length(paramNames)
                prtDataSet.(paramNames{iPair}) = paramValues{iPair};
            end
        end
        
        function varargout = plot(obj, featureIndices)
            
            if nargin < 2 || isempty(featureIndices)
                featureIndices = 1:obj.nFeatures;
            end
            if islogical(featureIndices)
                featureIndices = find(featureIndices);
            end
            
            nPlotDimensions = length(featureIndices);
            if nPlotDimensions < 1
                warning('prt:plot:NoPlotDimensionality','No plot dimensions requested.');
                return
            elseif nPlotDimensions > 2
                warning('prt:plot:NoPlotDimensionality','Regression plots only for 1 dimensional data');
                return
            end
            
            holdState = get(gca,'nextPlot');
            h = plot(obj.getObservations,obj.getTargets,'b.');
            set(gca,'nextPlot',holdState);
            % Set title
            title(obj.name);
            
            % Handle Outputs
            varargout = {};
            if nargout > 0
                varargout = {h};
            end
        end
        
    end
end
