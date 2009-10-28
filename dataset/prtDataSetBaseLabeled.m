classdef prtDataSetBaseLabeled < prtDataSetBase
    
    properties (Dependent, Abstract)
        nTargetDimensions
    end
    properties (GetAccess = 'protected',SetAccess = 'private')
        targetNames = {}
    end
    methods (Abstract)
        %All labeled data sets must implement at a minumum the folowing:
        targets = getTargets(obj,indices1,indices2)
        obj = setTargets(obj,targets,indices)
    end
    methods
        function targetNames = getTargetNames(obj,indices2)
            % getTargetNames - Return DataSet's Target Names
            %
            %   targetNames = getTargetNames(obj) Return a cell array of
            %   an object's target names; if setTargetNames has not been
            %   called or the 'targetNames' field was not set at construction,
            %   default behavior is to return sprintf('Target %d',i) for all
            %   target dimensions.
            %
            %   targetNames = getTargetNames(obj,indices) Return the target
            %   names for only the specified indices.
            
            if nargin == 1
                indices2 = (1:obj.nTargetDimensions)';
            end
            if isempty(obj.targetNames)
                targetNames = prtDataSetBaseLabeled.generateDefaultTargetNames(indices2);
            else
                targetNames = obj.targetNames(indices2);
            end
        end
        
        function obj = setTargetNames(obj,targetNames,indices1)
            % setTargetNames - Set DataSet's Target Names
            
            if ~isvector(targetNames)
                error('setTargetNames requires vector targetNames');
            end
            if nargin == 2
                if length(targetNames) ~= obj.nTargetDimensions
                    error('setTargetNames with one input requires length(targetNames) == obj.nTargetDimensions');
                end
                indices1 = (1:obj.nTargetDimensions)';
            end
            
            %Put the default string names in there; otherwise we might end
            %up with empty elements in the cell array
            if isempty(obj.targetNames)
                obj.targetNames = obj.getTargetNames;
            end
            obj.targetNames(indices1) = targetNames;
        end
    end
    methods (Access = 'private', Static = true)
        function targetNames = generateDefaultTargetNames(indices2)
            targetNames = prtUtilCellPrintf('Target %d',num2cell(indices2));
            targetNames = targetNames(:);
        end
    end
end
