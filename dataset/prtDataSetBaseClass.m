classdef prtDataSetBaseClass
    
    properties (Dependent)
        % New properties for labeled data only:
        nClasses = nan         % scalar, number of unique class labels
        isUnary = nan          % logical, true if nClasses == 1
        isBinary = nan         % logical, true if nClasses == 2
        isMary = nan           % logical, true if nClasses > 2
        isZeroOne = nan        % true if isequal(uniqueClasses,[0 1])
    end
    
    properties (Abstract)
        uniqueClasses          % vector, unique class names in the dataSet
        % We don't implement this here because big datasets might want to
        % cache it. 
    end
    properties (Dependent, Hidden)
        % Additional properties for plotting
        plottingColors
        plottingSymbols
    end
    
    properties (Abstract) %(GetAccess = 'protected') %why so protected?
        classNames % strcell, 1 x nClasses
    end
    
    methods (Abstract)
        cNames = getClassNames(obj)
        obj = setClassNames(obj,names)
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Get Methods for Dependent properties %%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function isBin = get.isBinary(obj)
            isBin = obj.nClasses == 2;
        end
        function isUnary = get.isUnary(obj)
            isUnary = obj.nClasses == 1;
        end
        function isMary = get.isMary(obj)
            isMary = obj.nClasses > 2;
        end
        function isZO = get.isZeroOne(obj)
            isZO = isequal(obj.uniqueClasses,[0 1]);
        end
        function nUT = get.nClasses(obj)
            nUT = length(obj.uniqueClasses);
        end
        function colors = get.plottingColors(obj)
            colors = prtPlotUtilClassColors(obj.nClasses);
        end
        function symbols = get.plottingSymbols(obj)
            symbols = prtPlotUtilClassSymbols(obj.nClasses);
        end
    end
end