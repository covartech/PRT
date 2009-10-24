classdef prtDataSetBaseInMemoryLabeled < prtDataSetBaseInMemory
    
    properties %public... for now... this is controversial :)
        targets = [];         % matrix, doubles, targets, for unlabeled data sets, just ignore(?)
    end
    
    methods
        
        %Required by prtDataSetLabeled
        function targets = getTargets(obj,indices1,indices2)
            if nargin < 3
                indices2 = 1:obj.nTargetDimensions;
            end
            if nargin < 2
                indices1 = 1:obj.nObservations;
            end
            if max(indices1) > obj.nObservations
                error('prt:prtDataSetLabeledInMemory:incorrectInput','max(indices1) (%d) must be <= nObservations (%d)',max(indices1),obj.nObservations);
            end
            if max(indices2) > obj.nTargetDimensions
                error('prt:prtDataSetLabeledInMemory:incorrectInput','max(indices2) (%d) must be <= nTargetDimensions (%d)',max(indices1),obj.nTargetDimensions);
            end
            targets = obj.targets(indices1,indices2);
        end
        
        function obj = setTargets(obj,targets,indices1,indices2)
            if nargin < 4
                indices2 = 1:size(targets,2);
            end
            if nargin < 3
                indices1 = 1:obj.nObservations;
            end
            if max(indices1) > obj.nObservations
                error('prt:prtDataSetLabeledInMemory:incorrectInput','max(indices1) (%d) must be <= nObservations (%d)',max(indices1),obj.nObservations);
            end
            obj.targets(indices1,indices2) = targets;
        end
        
        %% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = prtDataSetBaseInMemoryLabeled(varargin)
            % Nothing to do.
            % This should only be called when initializing a sub-class
        end
        
        %Required by prtDataSetBase:
        function obj = set.targets(obj, targets)
            if ~isa(targets,'double') || ndims(targets) ~= 2
                error('prt:prtDataSetLabeled:invalidData','targets must be a 2-Dimensional double array');
            end
            obj.targets = targets;
        end
        
        function targets = get.targets(obj)
            targets = obj.targets;
        end
        
        function export(obj,varargin)
            error('Not Done Yet');
        end
    end
    
end