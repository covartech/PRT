classdef prtDataSetFile < prtDataSetBase
    % xxx NEED HELP xxx

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.
    properties

        fileList
        readOnly
        
        loadFn
        writeFn
        
        ObservationDependentUserData
    end
    
    properties (Dependent)
        nObservations         % Abstract, implement as size(data,1)
        nTargetDimensions     % Abstract, implement as size(targets,2)
    end
    
    properties (Hidden)
        internalStandardDataSet
    end
    
    methods
        function obj = prtDataSetFile(varargin)
            
            if nargin == 0
                return;
            end
            if isa(varargin{1},'prtDataSetFile')
                obj = varargin{1};
                varargin = varargin(2:end);
            end
            targets = [];
            if isa(varargin{1},'cell')
                obj.fileList = varargin{1}(:);
                varargin = varargin(2:end);   
                if nargin >= 2 && (isnumeric(varargin{1}) || islogical(varargin{1}))%targets!
                    targets = varargin{1};
                    varargin = varargin(2:end);
                end
            end
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
            obj.internalStandardDataSet = prtDataSetClass(nan(obj.nObservations,1),targets);
        end
        
        function fileList = getFiles(obj,varargin)
            indices1 = prtDataSetBase.parseIndices(obj.nObservations,varargin{:});
            fileList = obj.fileList(indices1);
        end
        
        function obj = setFiles(obj,files,varargin)
            
            indices1 = prtDataSetBase.parseIndices(obj.nObservations,varargin{:});
            for i = 1:length(indices1)
                obj.fileList{indices1(i)} = files{i};
            end
            obj.internalStandardDataSet = prtDataSetClass(nan(obj.nObservations,1));
            keyboard
        end
        
        function nObservations = get.nObservations(obj)
            nObservations = size(obj.fileList,1);
        end
        
        function nTargetDimensions = get.nTargetDimensions(obj)
            nTargetDimensions = obj.internalStandardDataSet.nTargetDimensions;
        end
        
        
        function data = getObservations(obj,indices1)
            if nargin < 2 || strcmpi(indices1,':')
                indices1 = 1:obj.nObservations;
            end
            for i = 1:length(indices1)
                data(i,:) = obj.loadFn(obj.fileList{indices1(i)});
            end
        end
        
        function targets = getTargets(obj,varargin)
            targets = obj.internalStandardDataSet.getTargets(varargin{:});
        end
        
        function [data,targets] = getObservationsAndTargets(obj,varargin)
            data = getObservations(obj,varargin{:});
            targets = getTargets(obj,varargin{:});
        end
        
        function obj = setObservations(obj,data,indices1)
            if obj.readOnly
                error('Attempt to set observations for a read-only prtDataSetFile; this will attempt to overwrite existing files.');
            end
            if nargin < 3 || strcmpi(indices1,':')
                indices1 = 1:obj.nObservations;
            end
            for i = 1:length(indices1)
                obj.writeFn(obj.fileList{i},data(i,:));
            end
        end
        
        function obj = setTargets(obj,varargin)
            obj.internalStandardDataSet = obj.internalStandardDataSet.setTargets(varargin{:});
        end
            
        function obj = setObservationsAndTargets(obj,data,targets)
            if obj.readOnly
                error('Attempt to set observations for a read-only prtDataSetFile; this will attempt to overwrite existing files.');
            end
            if nargin < 3 || strcmpi(indices1,':')
                indices1 = 1:obj.nObservations;
            end
            for i = 1:length(indices1)
                obj.writeFn(obj.fileList{i},data(i,:));
            end
            obj.internalStandardDataSet = obj.internalStandardDataSet.setTargets(targets);
        end
        
        function [obj,retainedIndices] = removeObservations(obj,varargin)
            %
            removeIndices = prtDataSetBase.parseIndices(obj.nObservations,varargin{:});
            
            if islogical(removeIndices)
                keepObservations = ~removeIndices;
            else
                keepObservations = setdiff(1:obj.nObservations,removeIndices);
            end
            [obj,retainedIndices] = retainObservations(obj,keepObservations);
        end
        
        function obj = removeTargets(obj,indices)
            obj.internalStandardDataSet = obj.internalStandardDataSet.removeTargets(obj,indices);
        end
        
        function [obj,retainedIndices] = retainObservations(obj,varargin)
            %[obj,retainedIndices] = retainObservations(obj,retainedIndices)
            warning('prt:Fixable','Does not handle observation names');
            retainedIndices = prtDataSetBase.parseIndices(obj.nObservations,varargin{:});
            
            obj.fileList = obj.fileList(retainedIndices);
            if obj.isLabeled
                obj.targets = obj.targets(retainedIndices,:);
            end
            
            if ~isempty(obj.ObservationDependentUserData)
                obj.ObservationDependentUserData = obj.ObservationDependentUserData(retainedIndices);
            end
        end
        
        function obj = retainTargets(obj,indices)
            obj.internalStandardDataSet = obj.internalStandardDataSet.removeTargets(obj,indices);
        end
        
        function obj = catObservations(obj,varargin)
            error('not implemented');
        end
        function obj = catTargets(obj,dataSet)
            error('not implemented');
        end
        
        function handles = plot(obj)
            error('not implemented');
        end
        function export(obj,prtExportObject)
            error('not implemented');
        end
        function Summary = summarize(obj)
            error('not implemented');
        end
    end
    
end
