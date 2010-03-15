% prtPlotOpt contains available options for plotting within the PRT
% 
% Properties
%   nSamplesPerDim - 1x3 int array - number of samples to use for plotting 
%       classifier confidence as a function of dimensionality [1D 2D 3D]
%       Default=[500 100 20]
%   colorsFunction - Function handle that returns the colors to use for
%       plotting datasets. Must accept an int (nClasses) and return an
%       nClassesx3 double of RGB colors Default=@prtPlotUtilClassColors;
%   symbolsFunction - Function handle that returns the symbols to use for
%       plotting datasets. Must accept an int (nClasses) and return a
%       1xnClasses char array of plotting symbols. 
%       Default=@prtPlotUtilClassSymbols
%   twoClassColorMapFunction - Function handle that returns a colormap for 
%       plotting confidence in two class problems. Must be able to accept
%       a single int (nColorInds) and return a valid MATLAB colormap
%       Default=@prtPlotUtilTwoClassColorMap
%   mappingFunction - A function handle that maps the confidence values
%       prior to visualization traditional plot function. Must accept a
%       double array of Nx1, Nx2, or Nx3 and return a double array of the
%       same size. Default=[]
%   additionalPlotFunction - A function handle that gets executed after the
%       traditional plot function. Must accept two arguments
%       (PrtActionObj, DataSet) Default=[]
%
% Methods
%   Obj = prtPlotOpt('paramName',paramVal,...) - Contructor
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
classdef prtClassPlotOpt %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        nSamplesPerDim = [500 100 20]; % Number of samples to use for plotting
        colorsFunction = @prtPlotUtilClassColors; % Colors function handle
        symbolsFunction = @prtPlotUtilClassSymbols; % Symbols function handle
        twoClassColorMapFunction = @prtPlotUtilTwoClassColorMap; % Two class colormap function handle
        mappingFunction = []; % Confidence mapping function handle
        additionalPlotFunction = []; % Additional plotting function function handle
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = prtPlotOpt(varargin) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % prtPlotOpt - Constructor for prtPlotOpt
            % 
            % Obj = prtPlotOpt();
            % Obj = prtPlotOpt('paramName',paramVal,...);
            
            if nargin == 0
                % Nothing to do default object
                return
            end
            
            stringValuePairs = varargin;
            % Check parameter string, value pairs
            inputError = false;
            if mod(length(stringValuePairs),2)
                inputError = true;
            end
            
            paramNames = varargin(1:2:(end-1));
            if ~iscellstr(paramNames)
                inputError = true;
            end
            paramValues = varargin(2:2:end);
            if inputError
                error('prt:prtPlotOpt:invalidInputs','Additional input arguments must be specified as parameter string, value pairs.')
            end
            
            % Now we loop through and apply the properties
            for iPair = 1:length(paramNames)
                obj.(paramNames{iPair}) = paramValues{iPair};
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%