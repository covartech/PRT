classdef prtDataSetRegress < prtDataSetLabeled
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
    methods
        %% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function prtDataSet = prtDataSetRegress(varargin)
            error('Not Done Yet')
            % prtDataSet = prtDataSetLabeled
            % prtDataSet = prtDataSetLabeled(data, labels)
            % prtDataSet = prtDataSetLabeled(data, labels, paramName1, paramVal1, ...)
            
            if nargin == 0 % Empty constructor
                % Nothing to do
                return
            end
            
            % Check if we are supplying multiple data sets to join
            if all(cellfun(@(c)isa(c,'prtDataSetLabeled'),varargin))
                prtDataSet = varargin{1};
                for i = 2:length(varargin)
                    prtDataSet = prtDataSetLabeled(prtDataSet,'data',cat(2,prtDataSet.data,varargin{i}.data));
                end
                return
            end
            
            if isa(varargin{1},'prtDataSetLabeled')
                prtDataSet = varargin{1};
                varargin = varargin(2:end);
            else
                if nargin < 2
                    error('prt:prtDataSetLabeled:invalidInputs','both data and labels must be specified.');
                end
                if size(varargin{1},1) ~= size(varargin{2},1)
                    error('prt:prtDataSetLabeled:dataLabelsMismatch','size(data,1) (%d) must match size(labels,1) (%d)',size(varargin{1},1), size(varargin{2},1));
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
                error('prt:prtDataSetLabeled:invalidInputs','additional input arguments must be specified as parameter string, value pairs.')
            end
            % Set Values
            for iPair = 1:length(paramNames)
                prtDataSet.(paramNames{iPair}) = paramValues{iPair};
            end
        end
    end
end
