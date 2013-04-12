classdef prtDataSetCellArray < prtDataSetInMem & prtDataInterfaceCategoricalTargets
	%prtDataSetCellArray < prtDataSetInMem & prtDataInterfaceCategoricalTargets
	% dataSet = prtDataSetTimeSeries generates a prtDataSet object which
	%     uses a cell array as internal data storage.  This is useful for
	%     data sets which are not appropriate for storage in matrices,
	%     e.g., time-series, or multi-dimensional data sets.  
	%

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


	properties (Hidden = true)
		plotOptions = prtDataSetClass.initializePlotOptions();
	end
	
	methods
		
		function obj = prtDataSetCellArray(varargin)
            % prtDataSetCellArray Constructor for class prtDataSetCellArray
            % 
            % class = prtDataSetCellArray(X,Y)
            %   Create a prtDataSetClass object with data X and targets Y.
            %   X shouls be a #obs x 1 cell-array, and Y should be a #obs x
            %   1 vector of target labels.  Each element of X is a
            %   #features x #samples time-series.
            
			if nargin == 0
				return;
			end
			if isa(varargin{1},'prtDataSetClass')
				obj = varargin{1};
				varargin = varargin(2:end);
			end
			
			%handle first input data:
			if length(varargin) >= 1 && iscell(varargin{1})
				obj = obj.setObservations(varargin{1});
				varargin = varargin(2:end);
				%handle first input data, second input targets:
				if length(varargin) >= 1 && ~isa(varargin{1},'char')
					if (isa(varargin{1},'double') || isa(varargin{1},'logical'))
						obj = obj.setTargets(varargin{1});
						varargin = varargin(2:end);
					else
						error('prtDataSet:InvalidTargets','Targets must be a double or logical array; but targets provided is a %s',class(varargin{1}));
					end
				end
			end
			
			obj = prtUtilAssignStringValuePairs(obj,varargin{:});
		end
	end
	
	
	methods (Access = protected)
		function self = update(self)
			% Updated chached target info
			self = updateTargetCache(self);
			% Updated chached data info
			self = updateObservationsCache(self);
		end
	end
	
	methods
		
		function self = catObservations(self,varargin)
			%dsOut = catObservations(dataSet1,dataSet2)
			%   Return a data set, dsOut, formed by vertically
			%   concatenating the observations, targets, and other fields
            %   in dataSet1 and dataSet2.
            %
            %   Note that when dataSet1 and dataSet2 have different class
            %   names, and/or targets dataSet1 and dataSet2's className
            %   fields are used to generate a proper target/className
            %   representation for the output dsOut.
            %
            %   As a result, the targets in the resulting dsOut may not
            %   exactly match the output of cat(1,dataSet1,dataSet2)
			%
            
			self = catObservations@prtDataSetInMem(self,varargin{:});
			self = catClasses(self,varargin{:});
			self = self.update;
		end
		
		function self = setTargets(self,targets)
			% dataSet = setTargets(ds,targets)
			%  setTargets outputs a dataSet with targets set to targetsIn.
			%  targetsIn should be a ds.nObservations x 1 matrix of target
			%  values.
            %  
			self = setTargets@prtDataSetInMem(self,targets);
			self = self.update;
		end
		
		function Summary = summarize(self)
			% Summarize   Summarize the prtDataSetStandard object
			%
			% SUMMARY = dataSet.summarize() Summarizes the prtDataSetStandard
			% object and returns the result in the struct SUMMARY.
			
			Summary = summarize@prtDataSetInMem(self);
			%from prtDataInterfaceCategoricalTargets
			Summary = summarize@prtDataInterfaceCategoricalTargets(self,Summary);
		end
	end
	
	methods %Plotting methods
		
		
		function varargout = plot(obj,xData)
			% plotAsTimeSeries  Plot the data set as time series data
			%
			% dataSet.plotAsTimeSeries() plots the data contained in
			% dataSet as if it were a time series.
			
			if ~obj.isLabeled
				obj = obj.setTargets(zeros(obj.nObservations,1));
				obj = obj.setClassNames({'Unlabeled'});
			end
			
			nClasses = obj.nClasses;
			classColors = obj.plotOptions.colorsFunction(obj.nClasses);
			lineWidth = obj.plotOptions.symbolLineWidth;
			
			handleArray = [];
			allHandles = cell(nClasses,1);
			
			holdState = get(gca,'nextPlot');
			
            % Loop through classes and plot
            for i = 1:nClasses
                %Use "i" here because it's by uniquetargetIND
                cX = obj.getObservationsByClassInd(i);
                
                h = {};
                for sample = 1:length(cX)
                    h{sample} = prtPlotUtilLinePlot(1:length(cX{sample}),cX{sample},classColors(i,:),lineWidth);
                    hold on;
                end
                handleArray(i) = h{1}(1);
                allHandles{i} = h(:);
                
                if i == 1
                    hold on;
                end
            end
            set(gca,'nextPlot',holdState);
			% Set title
			title(obj.name);
			
			% Create legend
			if obj.isLabeled
				legendStrings = getClassNames(obj);
				legend(handleArray,legendStrings,'Location','SouthEast');
			end
			
			
			% Handle Outputs
			varargout = {};
			if nargout > 0
				varargout = {handleArray, legendStrings, allHandles};
			end
        end
    end
	
	methods (Static)
		function obj = loadobj(obj)
			% dataSet = loadobj(obj)
            %   Load a prtDataSetClass properly.  This requires checking
            %   the object version number and possibly converting a few
            %   things...
            %
            
			if isstruct(obj)
				if ~isfield(obj,'version')
					% Version 0 - we didn't even specify version
					inputVersion = 0;
				else
					inputVersion = obj.version;
				end
				

				inObj = obj;
			    obj = loadobj@prtDataSetStandard(inObj,'prtDataSetClass');
				
				switch inputVersion
					case {0,1}
						
						if ~isempty(inObj.classNamesInternal.cellValues)
							obj = obj.setClassNames(inObj.classNamesInternal.cellValues, inObj.classNamesInternal.integerKeys);
						end
						
					case 2

						if ~isempty(inObj.classNamesArray.cellValues)
							obj = obj.setClassNames(inObj.classNamesArray.cellValues, inObj.classNamesArray.integerKeys);
						end
						
					case 3
						
						if ~isempty(inObj.classNamesArray.cellValues)
							obj = obj.setClassNames(inObj.classNamesArray.cellValues, inObj.classNamesArray.integerKeys);
						end
						
				end
				
			else
				% Nothin special hopefully?
				% How did this happen?
				% Hopefully it works out.
			end
		end
	end
	
	methods (Hidden)
		function dsFoldOut = crossValidateCheckFoldResults(dsIn, dsTrain, dsTest, dsFoldOut)
			dsFoldOut = crossValidateCheckFoldResults@prtDataSetBase(dsIn, dsTrain, dsTest, dsFoldOut);
			dsFoldOut = crossValidateCheckFoldResultsWarnNumberOfClassesBad(dsIn, dsTrain, dsTest, dsFoldOut);
        end
		function self = acquireNonDataAttributesFrom(self, dataSet)
            self = acquireNonDataAttributesFrom@prtDataSetBase(self, dataSet);
            self = acquireCategoricalTargetsNonDataAttributes(self, dataSet);
        end
	end
end
