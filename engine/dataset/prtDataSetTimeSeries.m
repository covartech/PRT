classdef prtDataSetTimeSeries < prtDataSetCellArray
	%prtDataSetTimeSeries < prtDataSetCellArray
	% dataSet = prtDataSetTimeSeries generates a prtDataSetTimeSeries object
	%




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
