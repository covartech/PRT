classdef prtDataSetUnLabeled < prtDataSetInMemory
    
    % There are no new properties
    % All properties are inherited from prtDataSetInMemory

    methods
        %% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function prtDataSet = prtDataSetUnLabeled(varargin)
            % prtDataSet = prtDataSetUnLabeled
            % prtDataSet = prtDataSetUnLabeled(data)
            % prtDataSet = prtDataSetUnLabeled(data, paramName1, paramVal1, ...)
            
            if nargin == 0 % Empty constructor
                % Nothing to do
                return
            end
            
            % Check if we are supplying a set of data sets to join
            if all(cellfun(@(c)isa(c,'prtDataSetUnLabeled'),varargin)) || all(cellfun(@(c)isa(c,'prtDataSetLabeled'),varargin))
                prtDataSet = varargin{1};
                if isa(varargin{1},'prtDataSetLabeled')
                    prtDataSet = prtDataSetUnLabeled(prtDataSet.data);
                end
                for i = 2:length(varargin)
                    prtDataSet = prtDataSetUnLabeled(prtDataSet,'data',cat(2,prtDataSet.data,varargin{i}.data));
                end
                return
            end
            
            if isa(varargin{1},'prtDataSetUnLabeled')
                prtDataSet = varargin{1};
                varargin = varargin(2:end);
            else
                prtDataSet.data = varargin{1};
                varargin = varargin(2:end);
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
                error('prt:prtDataSetUnLabeled:invalidInputs','additional input arguments must be specified as parameter string, value pairs.')
            end
            % Set Values
            for iPair = 1:length(paramNames)
                prtDataSet.(paramNames{iPair}) = paramValues{iPair};
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end
end