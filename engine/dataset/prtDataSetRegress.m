classdef prtDataSetRegress < prtDataSetStandard
    % prtDataSetRegress   Data set object for regression
    %
    %   DATASET = prtDataSetRegress returns a prtDataSetRegress object
    %
    %   DATASET = prtDataSetRegress(PROPERTY1, VALUE1, ...) constructs a
    %   prtDataSetRegress object DATASET with properties as specified by
    %   PROPERTY/VALUE pairs.
    %
    %   A prtDataSetRegress object inherits all properties from the
    %   prtDataSetStandard class. 
    %
    %   A prtDataSetRegress inherits all methods from the
    %   prtDataSetStandard object. In addition it overloads the following
    %   functions:
    %
    %   plot      - Plot the prtDataSetRegress object
    %   summarize - Summarize the prtDataSetRegress object.
    % 
    %   See also: prtDataSetStandard, prtDataSetClass, prtDataSetBase

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
        plotOptions = prtDataSetRegress.initializePlotOptions()
    end
    
    methods
        %% Constructor %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function prtDataSet = prtDataSetRegress(varargin)
  
            prtDataSet = prtDataSet@prtDataSetStandard(varargin{:});
        end
        
        function keys = getKFoldKeys(DataSet,K)
            % keys = getKFoldKeys(dataSet,K)
            %   Return a vector of integers specifying fold indices.  THis
            %   is used in prtAction.kfolds, for example.
        
            % This is overloaded here as the default behvior in base
            % assumes categorical targets.
            keys = prtUtilEquallySubDivideData(ones(DataSet.nObservations,1),K);
        end  
        
        function varargout = plot(obj, featureIndices)
            % Plot   Plot the prtDataSetRegress object
            %
            %   dataSet.plot() Plots the prtDataSetRegress object.
            
            if ~obj.isLabeled
                obj = obj.setTargets(zeros(obj.nObservations,1));
            end
            
            if nargin < 2 || isempty(featureIndices)
                featureIndices = 1:obj.nFeatures;
            end
            if islogical(featureIndices)
                featureIndices = find(featureIndices);
            end
            
            nPlotDimensions = length(featureIndices);
            if nPlotDimensions < 1
                warning('prt:plot:NoPlotDimensionality','No plot dimensions requested.');
                return
            elseif nPlotDimensions >= 2
                error('prt:plot:NoPlotDimensionality','Regression plots are currently only valid for 1 dimensional data, but the requested plot has %d dimensions',nPlotDimensions);
            end
            
            holdState = get(gca,'nextPlot');
            
            classColors = obj.plotOptions.colorsFunction(1);
            markerSize = obj.plotOptions.symbolSize;
            lineWidth = obj.plotOptions.symbolLineWidth;
            classSymbols = obj.plotOptions.symbolsFunction(1);
            
            iPlot = 1;
            classEdgeColor = obj.plotOptions.symbolEdgeModificationFunction(classColors(iPlot,:));
            
            h = plot(obj.getObservations(:,featureIndices),obj.getTargets, classSymbols(iPlot), 'MarkerFaceColor', classColors(iPlot,:), 'MarkerEdgeColor', classEdgeColor,'linewidth',lineWidth,'MarkerSize',markerSize);
            
            set(gca,'nextPlot',holdState);
            
            % Set title
            title(obj.name);
            switch nPlotDimensions
                case 1
                    xlabel(obj.getFeatureNames(featureIndices));
                    ylabel(obj.getTargetNames(1));
                otherwise
                    error('prt:plot:NoPlotDimensionality','Regression plots are currently only valid for 1 dimensional data, but DataSet has %d dimensions',obj.nFeatures);
            end
            
            % Handle Outputs
            varargout = {};
            if nargout > 0
                varargout = {h};
            end
        end
	end
	
    methods (Static, Hidden = true)
        
        function plotOptions = initializePlotOptions()
            
            if ~isdeployed
                plotOptions = prtOptionsGet('prtOptionsDataSetRegressPlot');
            else
                plotOptions = prtOptions.prtOptionsDataSetRegressPlot;
            end
        end
	end
	
	methods (Static)
		function obj = loadobj(obj)
			obj = loadobj@prtDataSetStandard(obj,'prtDataSetRegress');
		end
	end
end
