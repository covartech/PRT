classdef prtDataSetRegress < prtDataSetStandard
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
            else
                prtDataSet = prtUtilAssignStringValuePairs(prtDataSet,varargin{:});
            end
        end
        
        function varargout = plot(obj, featureIndices)
            
            if ~obj.isLabeled
                obj = obj.setTargets(0);
            end
            
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
                error('prt:plot:NoPlotDimensionality','Regression plots only for 1 dimensional data');
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
        
        function Summary = summarize(Obj)
            Summary.upperBounds = max(Obj.getObservations());
            Summary.lowerBounds = min(Obj.getObservations());
            Summary.nFeatures = Obj.nFeatures;
            Summary.nTargetDimensions = Obj.nTargetDimensions;
            Summary.nObservations = Obj.nObservations;
        end
    end
end
