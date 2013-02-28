classdef prtDataSetTimeSeries < prtDataSetCellArray
	%prtDataSetTimeSeries < prtDataSetCellArray
	% dataSet = prtDataSetTimeSeries generates a prtDataSetTimeSeries object
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


	properties (Dependent)
        expandedData 
    end
    
	methods
	
        function val = get.expandedData(self)
            val = getExpandedData(self);
        end
        function val = getExpandedData(self)
           val = cat(1,self.X{:});
        end
        
        function ds = prtDataSetTimeSeries(varargin)
            ds = ds@prtDataSetCellArray(varargin{:});
        end
        
		function Summary = summarize(self)
			% Summarize   Summarize the prtDataSetStandard object
			%
			% SUMMARY = dataSet.summarize() Summarizes the prtDataSetStandard
			% object and returns the result in the struct SUMMARY.
			
            x = self.getExpandedData;
            
			Summary.upperBounds = max(x);
			Summary.lowerBounds = min(x);
			Summary.nFeatures = size(x,2);
			Summary.nTargetDimensions = self.nTargetDimensions;
			Summary.nObservations = self.nObservations;
            
			%from prtDataInterfaceCategoricalTargets
			Summary = summarize@prtDataInterfaceCategoricalTargets(self,Summary);
		end
	end
	
	methods %Plotting methods
		
		
		function varargout = plot(obj)
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
	
end
