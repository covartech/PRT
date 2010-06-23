classdef prtDataSetBaseInMemoryLabeled < prtDataSetBaseInMemory
    
    properties (SetAccess = 'protected') %public... for now... this is controversial :) ; this can be changed to protected without breaking anything
        targets = [];         % matrix, doubles, targets
    end
    
    methods
        %Set the observations to a new set
        function obj = setObservations(obj,data,varargin)
            %obj = setObservations(obj,data,varargin)
            
            obj = setObservations@prtDataSetBaseInMemory(obj,data,varargin{:});
            if size(obj.data,1) ~= size(obj.targets,1)
                error('Cannot change the size of prtDataSetBaseInMemoryLabeled observations; use obj = setDataAndTargets(obj,data,targets)');
            end
        end
        
        function obj = removeTargetDimensions(obj,indices)
            indices = setdiff(1:size(obj.targets,2),indices);
            obj.targets = obj.targets(:,indices);
        end
        
        function obj = catTargetDimensions(obj,newTargets)
            obj.targets = cat(2,obj.targets,newTargets);
        end
        
        function [sortedObs,sortedTargets,sortedInds] = sortObservationsByTarget(obj,ascendDescend)
            if nargin == 1
                ascendDescend = 'ascend';
            end
            t = getTargets(obj);
            [sortedTargets,sortedInds] = sort(t,ascendDescend);
            sortedObs = getObservations(obj,sortedInds(:));
        end
        
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
        
        %Required by prtDataSetBase:
        function [obj,retainedInds] = removeObservations(obj,indices)
            if islogical(indices)
                [obj,retainedInds] = retainObservations(obj,~indices);
            else
                [obj,retainedInds] = retainObservations(obj,setdiff(1:obj.nObservations,indices));
            end
            %fprintf('need to check to see if we removed any labels which will change uniqueTargetNames, etc')
        end
        
        function [obj,retainedInds] = retainObservations(obj,indices)
            [obj,retainedInds] = retainObservations@prtDataSetBaseInMemory(obj,indices);
            obj.targets = obj.targets(retainedInds);
            %fprintf('need to check to see if we removed any labels which will change uniqueTargetNames, etc')
        end
        
        function [obj,retainedInds] = replaceObservations(obj,data,indices)
            [obj,retainedInds] = replaceObservations@prtDataSetBaseInMemory(obj,data,indices);
            %fprintf('need to check to see if we removed/added any labels which will change uniqueTargetNames, etc')
        end
        
        %% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = prtDataSetBaseInMemoryLabeled(varargin)
            % Nothing to do.
            % This should only be called when initializing a sub-class
        end
        
        %Required by prtDataSetBase:
        function obj = set.targets(obj, targets)
            %            obj = setTargets(obj,targets);
            obj.targets = targets;
        end
        
        function DS = bootstrap(obj,nSamples)
            sampleIndices = ceil(rand(1,nSamples).*obj.nObservations);
            DS = obj;
            DS = DS.setDataAndTargets(DS.getObservations(sampleIndices,:),DS.getTargets(sampleIndices));
        end
        
        function DS = bootstrapByClass(DS,nSamplesPerClass)
            error('Not implemented');
        end
        
        
        %Required by prtDataSetBase:
        function obj = setDataAndTargets(obj,data,targets)
            if ~isnumeric(data) || ndims(data) ~= 2
                error('prt:prtDataSetBaseInMemeoryLabeled:invalidData','data must be a 2-Dimensional double array');
            end
            if ~(isnumeric(targets) || islogical(targets)) || ndims(targets) ~= 2
                error('prt:prtDataSetBaseInMemeoryLabeled:invalidData','targets must be a 2-Dimensional double array');
            end
            if size(data,1) ~= size(targets,1)
                error('prt:prtDataSetBaseInMemeoryLabeled:invalidData','size(data,1) (%d) must match size(targets,1) (%d)',size(data,1),size(targets,1));
            end
            obj.data = data;
            obj.targets = targets;
        end
        
        %Required by prtDataSetBase:
        function obj = setData(obj,data)
            if ~isnumeric(data) || ndims(data) ~= 2
                error('prt:prtDataSetBaseInMemeoryLabeled:invalidData','data must be a 2-Dimensional double array');
            end
            if size(data,1) ~= size(obj.targets,1)
                error('prt:prtDataSetBaseInMemeoryLabeled:invalidData','size(data,1) (%d) must match size(targets,1) (%d)',size(data,1),size(obj.targets,1));
            end
            obj.data = data;
        end
        
        function obj = setTargets(obj,targets)
            if ~(isnumeric(targets) || islogical(targets)) ndims(targets) ~= 2
                error('prt:prtDataSetBaseInMemeoryLabeled:invalidTargets','targets must be a 2-Dimensional double array');
            end
            if size(obj.data,1) ~= size(targets,1)
                error('prt:prtDataSetBaseInMemeoryLabeled:invalidTargets','size(data,1) (%d) must match size(targets,1) (%d)',size(obj.data,1),size(targets,1));
            end
            obj.targets = targets;
            %obj.uniqueTargetNames = {};
        end
        
        function targets = get.targets(obj)
            targets = obj.targets;
        end
        
        function export(obj,varargin)
            error('Not Done Yet');
        end
    end
    
end