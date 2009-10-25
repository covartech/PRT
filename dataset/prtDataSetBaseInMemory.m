classdef prtDataSetBaseInMemory
    
    properties (SetAccess = 'protected') %public... for now... this is controversial :); this can be changed to protected without breaking anything
        data = [];            % matrix, doubles, features
    end
    
    methods (Access = 'protected',Static = true);
        function [err,errorID,errorMsg] = checkIndices(indices,maxVal,boolError)
            if islogical(indices)
                indices = find(indices);
            end
            if nargin < 3
                boolError = true;
            end
            err = 0;
            if any(indices < 1)
                errorID = 'prt:prtDataSetBaseInMemory:indexOutOfRange';
                errorMsg = 'Index elements out of range';
                err = 1;
            end
            if any(indices > maxVal)
                errorID = 'prt:prtDataSetBaseInMemory:indexOutOfRange';
                errorMsg = 'Index elements out of range';
                err = 2;
            end
            if ~isvector(indices)
                errorID = 'prt:prtDataSetBaseInMemory:invalidIndices';
                errorMsg = 'Indices must be a vector';
                err = 3;
            end
            if err ~= 0 && boolError
                error(errorID,errorMsg);
            end
        end
    end
    methods
        
        
        %% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = prtDataSetBaseInMemory(varargin)
            % Nothing to do.
            % This should only be called when initializing a sub-class
        end
        
        %Required by prtDataSetBase:
        function [obj,retainedFeatures] = removeFeatures(obj,indices)
            
            prtDataSetBaseInMemory.checkIndices(indices,obj.nFeatures);
            [obj,retainedFeatures] = retainFeatures(obj,setdiff(1:obj.nFeatures,indices));
        end
        function [obj,retainedFeatures] = retainFeatures(obj,retainedFeatures)
            
            prtDataSetBaseInMemory.checkIndices(indices,obj.nFeatures);
            obj.data = obj.data(:,retainedFeatures);
        end
        
        function obj = replaceFeatures(obj,data,indices)
            
            prtDataSetBaseInMemory.checkIndices(indices,obj.nFeatures);
            indices = indices(:);
            if size(indices,1) ~= size(data,2)
                error('prt:prtDataSetBaseInMemory:invalidIndices','length(indices) (%d) ~= size(data,1) (%d)',length(indices),size(data,1));
            end
            
            obj.data(:,indices) = data;
        end
        
        function [obj,retainedIndices] = removeObservations(obj,indices)
            
            prtDataSetBaseInMemory.checkIndices(indices,obj.nObservations);
            [obj,retainedIndices] = retainObservations(obj,setdiff(1:obj.nObservations,indices));
        end
        
        function [obj,retainedIndices] = retainObservations(obj,retainedIndices)
            
            prtDataSetBaseInMemory.checkIndices(retainedIndices,obj.nObservations);
            obj.data = obj.data(retainedIndices,:);
        end
        
        function obj = replaceObservations(obj,data,indices)
            
            prtDataSetBaseInMemory.checkIndices(indices,obj.nObservations);
            if size(indices,1) ~= size(data,1)
                indices = indices(:);
                error('prt:prtDataSetBaseInMemory:invalidIndices','length(indices) (%d) ~= size(data,1) (%d)',length(indices),size(data,1));
            end
            
            obj.data(indices,:) = data;
        end
        
        %Return the data by indices
        function data = getObservations(obj,indices1,indices2)
            if nargin < 2 || isempty(indices1)
                indices1 = 1:obj.nObservations;
            end
            if nargin < 3 || isempty(indices2)
                indices2 = 1:obj.nFeatures;
            end
            
            prtDataSetBaseInMemory.checkIndices(indices1,obj.nObservations);
            prtDataSetBaseInMemory.checkIndices(indices2,obj.nFeatures);
            data = obj.data(indices1,indices2);
        end
        
        %Set the observations to a new set
        function obj = setObservations(obj,data,indices1,indices2)
            %check sizes:
            if nargin < 3 || isempty(indices1)
                indices1 = 1:obj.nObservations;
            end
            if nargin < 4 || isempty(indices2)
                indices2 = 1:obj.nFeatures;
            end
            if ~isequal([length(indices1),length(indices2)],size(data))
                error('setObservations sizes not commensurate');
            end
            obj.data(indices1,indices2) = data;
            return;
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %% Set Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % These just provide sanity error checking
        function obj = set.data(obj, data)
            obj.data = data;
        end
        
        %Required by prtDataSetBase:
        function obj = setData(obj,data)
            if ~isa(data,'double') || ndims(data) ~= 2
                error('prt:prtDataSetBaseInMemeoryLabeled:invalidData','data must be a 2-Dimensional double array');
            end
            obj.data = data;
        end
        
        function data = get.data(obj)
            data = obj.data;
        end
        
        function obj = joinObservations(obj, varargin)
            for iCat = 1:length(varargin)
                obj = catObservations(obj, varargin{iCat}.getObservations);
            end
        end
        
        function obj = joinFeatures(obj, varargin)
            for iCat = 1:length(varargin)
                obj = catFeatures(obj, varargin{iCat}.getObservations);
            end
        end
        
        function obj = catFeatures(obj, newData)
            obj.data = cat(2,obj.data, newData);
        end
        
        function obj = catObservations(obj, newData)
            obj.data = cat(1,obj.data, newData);
        end
        
        function export(obj,varargin)
            error('Not Done Yet');
        end
    end
       
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %% Other Methods %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
       
%         function display(obj)
%             isCompact = strcmp(get(0,'FormatSpacing'),'compact');
%             
%             if ~isCompact
%                 fprintf('\n');
%             end
%             fprintf('%s =\n',inputname(1));
%             if ~isCompact
%                 fprintf('\n');
%             end
%             fprintf('\t%s\n',class(obj))
%             % Convert stuff we want to be displayed into a struct and use
%             % the struct display function
%             display(struct('name',obj.name,'description',obj.description,'nObservations',obj.nObservations,'nFeatures',obj.nFeatures,'UserData',obj.UserData))
%             
%             if ~isCompact
%                 fprintf('\n')
%             end
%         end

end
