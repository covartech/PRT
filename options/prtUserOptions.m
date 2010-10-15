classdef prtUserOptions
    % xxx NEED HELP xxx
    properties
        DataSetClassPlotOptions = prtDataSetClassPlotOpt;
        DataSetRegressPlotOptions = prtDataSetRegressPlotOpt;
        ClassifierPlotOptions = prtClassPlotOpt;
        RegressionPlotOptions = prtRegressPlotOpt;
        RvPlotOptions = prtRvPlotOpt;
        
        largestMatrixSize = 1e6; % Total number of elements in the matrix
        nProcessors = 1;
    end
    
    methods
        function obj = prtUserOptions(varargin)
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
            % Change default options here.
        end
    end
end