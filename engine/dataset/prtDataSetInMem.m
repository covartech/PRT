classdef prtDataSetInMem < prtDataSetBase

% Copyright (c) 2013 New Folder
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


    properties (SetAccess = protected,GetAccess = protected)
        internalData
        internalTargets
        internalSizeConsitencyCheck = true;
    end
    
    properties (Dependent)
        data  
        targets
    end
    
    methods
        
        function self = set.data(self,input)
            self = self.setData(input);
        end
        
        function self = set.targets(self,input)
            self = self.setTargets(input);
        end
        
        function self = get.data(self)
            self = self.internalData;
        end
        
        function self = get.targets(self)
            self = self.internalTargets;
        end
        
        function self = setObservations(self,data,varargin)
            % dataSet = setObservations(dataSet,data)
            %  This is outdated, use dataSet.data = ...;
            self = self.setData(data,varargin{:});
        end
        
        function self = setObservationsAndTargets(self,data,targets)
            %dataSet = setObservationsAndTargets(dataSet,data,targets)
            % Replace both the data and targets in a data set with new
            % "data" and "targets".  The inputs should have the same size
            % in the first dimension.
            %
            % setObservationsAndTargets is useful when the size of a data
            % set has to change.
            %   
            
            if ~(isempty(targets) || isempty(data)) && size(data,1) ~= size(targets,1)
                error('prt:DataTargetsSizeMisMatch','Neither targets nor data is empty, and the number of observations in data (%d) does not match the number of observations in targets (%d)',size(data,1),size(targets,1));
            end
            
            self.internalSizeConsitencyCheck = false;
            self = self.setData(data);
            self = self.setTargets(targets);
            self.internalSizeConsitencyCheck = true;
            self = self.update;
        end
        
        function d = getObservations(self,varargin)
            %d = getObservations(dataSet)
            %  This is outdated, use dataSet.data(...)
            %  
            try
                d = self.data(varargin{:});
            catch ME
                prtDataSetBase.parseIndices(self.nObservations,varargin{:});
                throw(ME);
            end
            
        end
        
        
        function self = removeTargets(self,indices)
            % dsOut = removeTargets(dataSet,indices)
            %   Remove the target columns specified by indices from the
            %   dataSet target matrix.
            %
            if islogical(indices)
                indices = ~indices;
            else
                indices = setdiff(1:self.nTargetDimensions,indices);
            end
            self = self.retainTargets(self,indices);
        end
        
        function self = retainTargets(self,indices)
            % dsOut = retainTargets(dataSet,indices)
            %   Retain the target columns specified by indices in the
            %   dataSet target matrix.
            %
            self.Y = self.Y(:,indices);
            self.targetNamesInternal = self.targetNamesInternal.retain(indices);
            self = self.update;
        end
        
        function self = catTargets(self,varargin)
            % dsOut = catTargets(dataSet1,dataSet2)
            %   Return a new data set with targets formed by the
            %   concatenation of dataSet1.targets and dataSet2.targets.
            %
            if nargin == 1
                return;
            end
            
            for i = 1:length(varargin)
                currInput = varargin{i};
                if ~isa(currInput,'prtDataSetStandard')
                    self.targets = cat(2,self.targets,currInput);
                else
                    self.targets = cat(2,self.targets,currInput.targets);
                end
            end
            
            % Updated chached data info
            self = self.update;
        end
        
        function nTargets = getNumTargetDimensions(self)
            %nTargets = getNumTargetDimensions(dataSet)
            % Return the size(dataSet.targets,2)
            %
            nTargets = size(self.targets,2);
        end
        
        function n = getNumObservations(self)
            %nObs = getNumObservations(dataSet)
            % Return the number of observations
            %
            if isempty(self.data)
                n = size(self.targets,1);
            else
                n = size(self.data,1);
            end
        end
        
        function data = getData(self,varargin)
            % data = getData(dataSet)
            %  Return dataSet.data
            
            if nargin == 2
                varargin{2} = ':';
            end
            
            try
                data = self.data(varargin{:});
            catch ME
                prtDataSetBase.parseIndices(self.nObservations ,varargin{:});
                rethrow(ME);
            end
        end
        
        function data = getTargets(self,varargin)
            % targets = getTargets(dataSet)
            %  Return dataSet.targets
            
            if nargin == 1
                data = self.targets;
                return;
            end
            try
                data = self.targets(varargin{:});
            catch ME
                prtDataSetBase.parseIndices([self.nObservations,self.nTargetDimensions] ,varargin{:});
                rethrow(ME);
            end
        end
        
        function self = setData(self,dataIn,varargin)
            %dsOut = setData(dataSet,dataIn)
            % Return a new data set, dsOut, with data specified by dataIn.
            %
            if nargin > 2
                self.internalData(varargin{:}) = dataIn;
            else
                self.internalData = dataIn;
            end
           
            if self.internalSizeConsitencyCheck
                prtDataSetInMem.checkConsistency(self.internalData,self.internalTargets);
            end
            self = self.update;
        end
        
        function self = setTargets(self,dataIn,varargin)
            %dsOut = setTargets(dataSet,dataIn)
            % Return a new data set, dsOut, with targets specified by dataIn.
            %
            
            if nargin > 2
                self.internalTargets(varargin{:}) = dataIn;
            else
                self.internalTargets = dataIn;
            end
            
            if self.internalSizeConsitencyCheck
                prtDataSetInMem.checkConsistency(self.internalData,self.internalTargets);
            end
            self = self.update;
        end
    end
    
    methods (Hidden = true)
        %Don't call these; they get called internally
        
		function Summary = summarize(self,Summary)
			% Summarize   Summarize the prtDataSetStandard object
			%
			% SUMMARY = dataSet.summarize() Summarizes the prtDataSetStandard
			% object and returns the result in the struct SUMMARY.
			if nargin == 1
                Summary = struct;
            end
			Summary.nObservations = Obj.nObservations;
        end
        
        function self = catObservationData(self, varargin)
            % dsOut = catObservationData(dataSet1,dataSet2)
            %   
            if nargin == 1
                return;
            end
            
            for i = 1:length(varargin)
                currInput = varargin{i};
                if ~isa(currInput,class(self))
                    %currInput = prtDataSetStandard(currInput);
                    currInput = feval(class(self),currInput); %try to call the constructor
                end
                
                self.internalSizeConsitencyCheck = false;
                self.data = cat(1,self.data,currInput.data);
                self.targets = cat(1,self.targets,currInput.targets);
                self.internalSizeConsitencyCheck = true;
                prtDataSetInMem.checkConsistency(self.internalData,self.internalTargets);
            end
            
            % Updated chached data info
            %             self = updateObservationsCache(self);
            self = self.update;
        end
        
        function self = retainObservationData(self,indices)
            
            self.internalSizeConsitencyCheck = false;
            try
                self.data = self.data(indices,:);
                if self.isLabeled
                    self.targets = self.targets(indices,:);
                end
            catch  ME
                prtDataSetBase.parseIndices(self.nObservations ,indices);
                rethrow(ME);
            end
            self.internalSizeConsitencyCheck = true;
            self = self.update;
        end
    end
    
    methods (Access = 'protected', Static)
        function checkConsistency(data,targets)
            if ~(isempty(data) || isempty(targets)) && size(data,1) ~= size(targets,1)
                error('prt:DataTargetsSizeMisMatch','Neither targets nor data is empty, and the number of observations in data (%d) does not match the number of observations in targets (%d)',size(data,1),size(targets,1));
            end
        end
    end
end
