classdef prtDataSetClass < prtDataSetStandard & prtDataInterfaceCategoricalTargets
    %prtDataSetClass < prtDataSetStandard & prtDataInterfaceCategoricalTargets
    % dataSet = prtDataSetClass generates a prtDataSetClass object
    %
    %     dataSet = prtDataSetClass(X,Y) generates a prtDataSetClass from
    %     the nObservations x nFeatures double matrix X and the
    %     nObservations x 1 label vector Y.
    %
    %     dataSet = prtDataSetClass(PROPERTY1, VALUE1, ...) constructs a
    %     prtDataSetClass object dataSet with properties as specified by
    %     PROPERTY/VALUE pairs.
    %
    %     A prtDataSetClass object inherits all properties from the
    %     prtDataSetStandard class. In addition, it has the following properties:
    %
    %     nClasses             - The number of classes
    %     uniqueClasses        - An array of the integer class labels
    %     isUnary              - True if the number of classes = 1
    %     isBinary             - True if the number of classes = 2
    %     isMary               - True if the number of classes > 2
    %     isZeroOne            - True if the unique classes are 0 and 1
    %     nObservationsByClass - The number of observations per class.
    %
    %     A prtDataSetClass inherits all methods from the prtDataSetStandard
    %     class. In addition, it has the following methods:
    %
    %     getObservationsByClass     - Return the observations per class
    %     getObservationsByClassInd  - Return the observations by class and index
    %     getTargetsAsBinaryMatrix   - Return a binary matrix of targets.
    %     explore                    - Explore the prtDataSetClass object
    %     plot                       - Plot the data set
    %     plotFeatureDensity         - Plot the probability density estimate
    %                                  of a single feature, labeled by class.
    %     plotStar                   - Create a star plot to visualize higher
    %                                  dimensional data
    %     plotAsTimeSeries           - Plot the prtDataSetClass object as a
    %                                  time series
    %     plotPairs                  - Plot a grid of plots containing each
    %                                  set of two-features with density
    %                                  estimates on the diagonals
    %     plotDensity                - Plot the density of each feature
    %                                  independently as a volume
    %
    %     Note: As of Jan 5, 2013 prtDataSetClass enables the use of NAN
    %     values in the target vector to specify unlabled data.  This data
    %     and class value (NAN) are treated specially.  e.g., NAN labels do
    %     not count towards the nClasses and will not appear in
    %     uniqueClasses.  It is not possible to set the name of
    %     the class corresponding to NAN.  See
    %     prtDataInterfaceCategoricalTargets for more information.
    %
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
    
    methods (Static, Hidden = true)
        function plotOptions = initializePlotOptions()
            if ~isdeployed
                plotOptions = prtOptionsGet('prtOptionsDataSetClassPlot');
            else
                plotOptions = prtOptions.prtOptionsDataSetClassPlot;
            end
        end
    end
    
    methods
        
        function obj = prtDataSetClass(varargin)
            % prtDataSetClass Constructor for class prtDataSetClass
            %
            % class = prtDataSetClass(X,Y)
            %   Create a prtDataSetClass object with data X and targets Y.
            %   X shouls be a #obs x #feat matrix, and Y should be a #obs x
            %   1 vector of target labels.
            %
            % class = prtDataSetClass(X,Y,field1,val1,field2,val2,...)
            %   As above, but also set additional public fields field1,
            %   field2,... to values val1, val2, etc.
            %
            % x = randn(100,2);
            % y = prtUtilY(50,50);
            % ds = prtDataSetClass(x,y);
            % plot(ds); % An unseparable data set
            %
            % x = randn(100,2);
            % y = prtUtilY(50,50);
            % ds = prtDataSetClass(x,y,'name','My Data Set');
            % plot(ds); % An unseparable data set
            
            if nargin == 0
                return;
            end
            if isa(varargin{1},'prtDataSetClass')
                obj = varargin{1};
                varargin = varargin(2:end);
            end
            
            %handle first input data:
            if length(varargin) >= 1 && (isnumeric(varargin{1}) || islogical(varargin{1}))
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
            
            self = catObservations@prtDataSetStandard(self,varargin{:});
            self = catClasses(self,varargin{:});
            self = self.update;
        end
        
        function self = setTargets(self,targets)
            % dataSet = setTargets(ds,targets)
            %  setTargets outputs a dataSet with targets set to targetsIn.
            %  targetsIn should be a ds.nObservations x 1 matrix of target
            %  values.
            %
            self = setTargets@prtDataSetStandard(self,targets);
            self = self.update;
        end
        
        
        % Overload this from prtDataSetBase to also check for all nan
        % targets, we would like to overload this in
        % prtDataInterfaceCategoricalTargets but we can't because of
        % multiple inheritance
        %
        % Furthermore you cant do this because there are many places in the
        % existing codebase where we assume that isLabled checks if targets
        % exists.
        %
        % Instead in prtDataInterfaceCategoricalTargets we decided to add
        % isFullUnlabeled as a Dependent property. Incases where you want
        % to check if labels exist and are all non-NaN you need to use
        % ~self.isLabeled || self.isFullyUnlabeled
        %
        %function b = getIsLabeled(self)
        %    b = ~(isempty(self.targets) || (self.hasUnlabeled && (self.nUnlabeled == self.nObservations)));
        %end
        
        function Summary = summarize(self)
            % Summarize   Summarize the prtDataSetStandard object
            %
            % SUMMARY = dataSet.summarize() Summarizes the prtDataSetStandard
            % object and returns the result in the struct SUMMARY.
            
            Summary = summarize@prtDataSetStandard(self);
            %from prtDataInterfaceCategoricalTargets
            Summary = summarize@prtDataInterfaceCategoricalTargets(self,Summary);
        end
    end
    
    methods %Plotting methods
        
        function handles = boxplot(self,varargin)
            %handles = boxplot(dataSet)
            % Draw a box plot for each feature in the data set. (Only
            % really usable for data sets with fewer than 25 features).
            %   
            
            nFeatures = self.nFeatures;
            if nFeatures > 25;
                error('prtDataSetClass:boxPlot','boxplot is only appropriate for data sets with fewer than 25 features');
            end
            [ii,jj] = prtUtilGetSubplotDimensions(nFeatures);
            handles = cell(nFeatures,1);
            for i = 1:nFeatures
                if nFeatures > 1
                    subplot(ii,jj,i);
                    %otherwise, if we only have to make one, just use
                    %whatever existing AXES were provided
                    % That means 
                    %    subplot(2,1,1); boxplot(ds); 
                    % Does what is expected for a ds with one feature.
                    %
                end
                handles{i} = boxplot(self.X(:,i),self.Y,varargin{:});
                title(self.getFeatureNames(i));
            end
           
        end
        
        function varargout = plotBox(self)
            
            X = self.X';
            targetIndicator = kron(self.Y,ones(self.nFeatures,1));
            featureIndicator = repmat((1:self.nFeatures)',self.nObservations,1);
            h = boxplot(X(:),cat(2,featureIndicator, targetIndicator),...
                'factorseparator',1,...
                'fullfactors','on',...
                'colorgroup',targetIndicator,...
                'colors',prtPlotUtilClassColors(self.nClasses),...
                'symbol','.',...
                'outliersize',2,...
                'plotstyle','compact',...
                'labelverbosity','majorminor');
            
            if nargout 
                varargout = {h};
            end
        end
        
        function varargout = plotStarIndividual(obj,featureIndices)
            % plotStarIndividual   Create a star plot
            %
            %   dataSet.plotStarIndividual() creates a star plot of the data
            %   contained in the prtDataSetClass dataSet. Star plots can be
            %   useful in visulaizing higher dimensional data sets.
            %   plotStarIndividual plots each observation by itself.
            
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
            end
            if nPlotDimensions < 3
                warning('prt:plotStar:TooFewDimensions','Star plots with fewer than 3 dimensions will look like lines or dots; star plots are best suited for data sets with > 2 features');
            end
            
            M = ceil(sqrt(obj.nObservations));
            
            theta = linspace(0,2*pi,length(featureIndices)+1);
            theta = theta(1:end-1);
            cT = cos(theta);
            sT = sin(theta);
            maxVal = max(abs(obj.getObservations(:,featureIndices)));
            
            nFeats = length(featureIndices);
            classColors = obj.plotOptions.colorsFunction(max(obj.nClasses,1));
            unlabeledColor = prtPlotUtilClassColorUnlabeled;
            
            if obj.isLabeled
                uClasses = obj.uniqueClasses;
                targs = obj.getTargets;
            else
                uClasses = 1;
                targs = ones(obj.nObservations,1);
            end
            holdState = get(gca,'nextPlot');
            
            for i = 1:obj.nObservations;
                [centerI,centerJ] = ind2sub([M,M],i);
                centerJ = M - centerJ;
                
                currObs = obj.getObservations(i,featureIndices)./(maxVal*2);
                points = bsxfun(@plus,[cT.*currObs;sT.*currObs],[centerI;centerJ]);
                
                ppoints = cat(2,points,points(:,1));
                
                h = plot([repmat(centerI,nFeats,1),points(1,:)']',[repmat(centerJ,nFeats,1),points(2,:)']',ppoints(1,:)',ppoints(2,:)','lineWidth',obj.plotOptions.starLineWidth);
                classInd = targs(i) == uClasses;
                
                if ~any(classInd)
                    cColor = unlabeledColor;
                else
                    cColor = classColors(classInd,:);
                end
                
                set(h,'color',cColor);
                hold on;
            end
            handleArray = prtUtilPreAllocateHandles(obj.nClasses + obj.hasUnlabeled,1);
            for iClass = 1:obj.nClasses
                handleArray(iClass) = plot(nan,nan,'color',classColors(iClass,:));
            end
            if obj.hasUnlabeled
                handleArray(end) = plot(nan,nan,'color',unlabeledColor);
            end
            
            % Create legend
            if obj.isLabeled
                legendStrings = getClassNamesInterp(obj);
                if obj.hasUnlabeled
                    legendStrings = cat(1,legendStrings,{prtPlotUtilUnlabeledLegendString});
                end
                legend(handleArray,legendStrings,'Location','SouthEast');
            end
            
            set(gca,'nextPlot',holdState);
            set(gca,'xtick',[]);
            set(gca,'ytick',[]);
            
            title(obj.name);
            if nargout > 0
                varargout = {h};
            end
        end
        
        function varargout = plotStar(obj,featureIndices)
            % plotStar   Create a star plot
            %
            %   dataSet.plotStar() creates a star plot of the data
            %   contained in the prtDataSetClass dataSet. Star plots can be
            %   useful in visulaizing higher dimensional data sets.
            
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
            end
            if nPlotDimensions < 3
                warning('prt:plotStar:TooFewDimensions','Star plots with fewer than 3 dimensions will look like lines or dots; star plots are best suited for data sets with > 2 features');
            end
            
            theta = linspace(0,2*pi,length(featureIndices)+1);
            theta = theta(1:end-1);
            cT = cos(theta);
            sT = sin(theta);
            maxVal = max(abs(obj.getObservations(:,featureIndices)));
            
            nFeats = length(featureIndices);
            classColors = obj.plotOptions.colorsFunction(max(obj.nClasses,1));
            unlabeledColor = prtPlotUtilClassColorUnlabeled;
            
            if obj.isLabeled
                uClasses = obj.uniqueClasses;
                targs = obj.getTargets;
            else
                uClasses = 1;
                targs = ones(obj.nObservations,1);
            end
            
            holdState = get(gca,'nextPlot');
            if strcmpi(holdState,'replace')
                delete(gca);
                gca;
            end
            hold on
            for i = 1:obj.nObservations;
                centerI = 0;
                centerJ = 0;
                
                currObs = obj.getObservations(i,featureIndices)./(maxVal*2);
                points = bsxfun(@plus,[cT.*currObs;sT.*currObs],[centerI;centerJ]);
                
                ppoints = cat(2,points,points(:,1));
                
                h = plot([repmat(centerI,nFeats,1),points(1,:)']',[repmat(centerJ,nFeats,1),points(2,:)']',ppoints(1,:)',ppoints(2,:)','lineWidth',obj.plotOptions.starLineWidth);
                classInd = targs(i) == uClasses;
                
                
                if ~any(classInd)
                    cColor = unlabeledColor;
                else
                    cColor = classColors(classInd,:);
                end
                
                set(h,'color',cColor);
            end
            title(obj.name);
            
            % Plot axes and text:
            %textRotationAngles = rem(theta-pi/2,2*pi)/pi*180;
            axesLength = .6;
            
            if obj.nFeatures < 100
                plot(axesLength*cat(1,zeros(1,length(cT)),cT),axesLength*cat(1,zeros(1,length(sT)),sT),'color',[0 0 0],'lineWidth',2)
                
                fNames = obj.getFeatureNames();
                
                textOffSet = 0.2;
                textRadius = axesLength+textOffSet;
                
                textRotationAngles = zeros(size(theta));
                for iAxes = 1:length(cT)
                    text(textRadius*cT(iAxes),textRadius*sT(iAxes), fNames{iAxes}, 'rotation', textRotationAngles(iAxes),'HorizontalAlignment','Center','VerticalAlignment','Middle');
                end
            end
            axis([-1 1 -1 1]*(axesLength + 0.4));
            
            handleArray = prtUtilPreAllocateHandles(obj.nClasses + obj.hasUnlabeled,1);
            for iClass = 1:obj.nClasses
                handleArray(iClass) = plot(nan,nan,'color',classColors(iClass,:));
            end
            if obj.hasUnlabeled
                handleArray(end) = plot(nan,nan,'color',unlabeledColor);
            end
            
            % Create legend
            if obj.isLabeled
                legendStrings = getClassNamesInterp(obj);
                if obj.hasUnlabeled
                    legendStrings = cat(1,legendStrings,{prtPlotUtilUnlabeledLegendString});
                end
                legend(handleArray,legendStrings,'Location','SouthEast');
            end
            
            set(gca,'XTick',[],'YTick',[],'Box','on')
            
            set(gca,'nextPlot',holdState);
            
            if nargout > 0
                varargout = {handleArray};
            end
        end
        
        function varargout = plotPairs(obj,containingHandle)
            % plotPairs() - Plot each pair of features in feature space
            %   along the diagonals the densities of the two features are
            %   plotted. A DataSet.nFeatures x DataSet.nFeatures array of
            %   axes are created for the plots.
            %
            % [plotHandles, axesHandles] = plotPairs(prtDataSetClassObj)
            % [...] = plotPairs(prtDataSetClassObj, containingHandle);
            %       containingHandle should be a valid parent for a MATLAB
            %       axes object such as a uipanel or a figure. The default
            %       is gcf.
            
            if nargin < 2 || isempty(containingHandle)
                containingHandle = gcf;
            end
            
            if obj.nFeatures > 4
                warning('prt:prtDataSetClassPlotPairs:BigNFeatures','Number of features is greater than 4 plotting may be slow. Consider selecting features using plotPairs(retainFeatures(ds,selectedFeatureInds)).');
            end
            
            assert(ishghandle(containingHandle),'prt:prtDataSetClass:prtPlotPairs','containingHandle must be a MATLAB handle graphics handle that is a valid parent for MATLAB axes');
            
            cChildren = get(containingHandle,'Children');
            if ~isempty(cChildren)
                delete(cChildren);
            end
            
            N = obj.nFeatures;
            Summary = obj.summarize();
            
            fNames = obj.getFeatureNames();
            
            borderH = 0.1;
            interBorderH = 0.005;
            borderV = 0.1;
            interBorderV = 0.005;
            
            containerPos = get(containingHandle,'Position');
            containerAspect = containerPos(3)/containerPos(4);
            borderV = borderV*containerAspect;
            interBorderV = interBorderV*containerAspect;
            
            sizeH = (1 - borderH*2 - interBorderH*2*(N-1))/N;
            sizeV = (1 - borderV*2 - interBorderV*2*(N-1))/N;
            
            axesStartsH = borderH:(sizeH+interBorderH*2):(1-borderH);
            axesStartsV = fliplr(borderV:(sizeV+interBorderV*2):(1-borderV));
            
            hs = cell(N);
            axesHandles = prtUtilPreAllocateHandles(N,N);
            for iFeature = 1:N
                for jFeature = 1:N
                    axesHandles(iFeature,jFeature) = axes('Parent',containingHandle,'Position',[axesStartsH(iFeature) axesStartsV(jFeature) sizeH sizeV]);
                    
                    if iFeature == jFeature
                        hs{iFeature,jFeature} = plotFeatureDensity(obj, iFeature);
                    else
                        hs{iFeature,jFeature} = obj.plot([iFeature jFeature]);
                        axis([Summary.lowerBounds(iFeature), Summary.upperBounds(iFeature) Summary.lowerBounds(jFeature), Summary.upperBounds(jFeature)])
                    end
                    
                    ylabel('');
                    xlabel('');
                    title('');
                    
                    legend('off')
                    grid on;
                    if iFeature == 1 || iFeature == N
                        ylabel(fNames{jFeature})
                    end
                    if ~(iFeature == 1 || iFeature == N)
                        set(gca,'YTickLabel',{});
                    end
                    if iFeature == N && N>1
                        set(gca,'YAxisLocation','Right')
                    end
                    if jFeature == N  || jFeature == 1
                        xlabel(fNames{iFeature})
                    end
                    if ~(jFeature == 1 || jFeature == N)
                        set(gca,'XTickLabel',{});
                    end
                    if (jFeature == 1)  && N>1
                        set(gca,'XAxisLocation','Top')
                    end
                    
                    if (iFeature==N && jFeature==N)
                        % Create legend
                        if obj.isLabeled
                            legendStrings = getClassNamesInterp(obj);
                            legendHandle = legend(hs{iFeature,jFeature},legendStrings,'Location','SouthEast'); %#ok<NASGU>
                        else
                            legendHandle = []; %#ok<NASGU>
                        end
                    end
                    
                end
            end
            
            if nargout
                varargout = {hs,axesHandles};
            end
        end
        
        function varargout = plotFeatureDensity(obj,featureInd,varargin)
            % plotFeatureDensity - Plot the densities of a single feature
            % as a function of class. With one input the supplied dataset
            % must have only a single feature. Otherwise, the second input
            % specifies which feature to plot.
            %
            % plotHandles = plotFeatureDensity(prtDataSetClassObj)
            % plotHandles = plotFeatureDensity(prtDataSetClassObj, featureInd)
            % [...] = plotFeatureDensity(prtDataSetClassObj, featureInd, 'PARMNAME', PARAMVALUE,...)
            %
            %   Additional parameters:
            %       nDensitySamples        - Number of linearly spaced
            %                                samples used to construct the
            %                                density estimate. Default 500.
            %       minimumKernelBandwidth - minimumBandwidth parameter of
            %                                prtRvKde that is used to
            %                                estimate each density. default
            %                                []. See prtRvKde.
            %
            % Example:
            %    ds = prtDataGenMary;
            %    plotDensity(ds,2)
            %
            %    ds = prtDataGenIris;
            %    plotFeatureDensity(ds,1,'minimumKernelBandwidth',5e-3);
            %
            %    plotFeatureDensity(ds.retainFeatures(2),'nDensitySamples',20);
            
            inputs = varargin;
            if mod(length(inputs),2) && ischar(featureInd)
                % featureInd was skipped
                inputs = cat(1,{featureInd},inputs(:));
                featureInd = [];
            end
            
            if nargin > 1 && ~isempty(featureInd)
                assert(prtUtilIsPositiveScalarInteger(featureInd) && featureInd <= obj.nFeatures,'prt:prtDataSetClass:plotFeatureDensity','featureInd must be a scalar, positive integer less than prtDataSetClass.nFeatures')
                obj = obj.retainFeatures(featureInd);
            end
            
            assert(obj.nFeatures==1,'prt:prtDataSetClass:plotFeatureDensity','prtDataSetClass must have only one feature or the feature to be plotted must be specified.');
            
            % Parse Options (additional string value pairs)
            Options.nDensitySamples = 500;
            Options.minimumKernelBandwidth = [];
            
            if nargin > 1
                assert(mod(length(inputs),2)==0,'Additional inputs must be string value pairs')
                
                paramNames = inputs(1:2:end);
                paramValues = inputs(2:2:end);
                
                optionFieldNames = fieldnames(Options);
                for iPair = 1:length(paramNames)
                    assert(ismember(paramNames{iPair},optionFieldNames),'%s is not a valid parameter name for plotDensity() (These parameters are case sensitive.)',paramNames{iPair});
                    Options.(paramNames{iPair}) = paramValues{iPair};
                end
            end
            
            nKSDsamples =  Options.nDensitySamples;
            
            Summary = obj.summarize();
            nClasses = max(obj.nClasses,1);
            colors = cat(1,obj.plotOptions.colorsFunction(nClasses), prtPlotUtilClassColorUnlabeled); % FIX me. Use plotOptions
            
            
            xLoc = linspace(Summary.lowerBounds, Summary.upperBounds, nKSDsamples);
            
            F = zeros([nKSDsamples, nClasses+obj.hasUnlabeled]);
            for cY = 1:nClasses;
                if obj.nClasses == 0
                    cX = obj.X;
                else
                    cX = obj.getObservationsByClassInd(cY);
                end
                    
                F(:,cY) = pdf(mle(prtRvKde('minimumBandwidth',Options.minimumKernelBandwidth),cX),xLoc(:));
            end
            
            if obj.hasUnlabeled
                F(:,end) = pdf(mle(prtRvKde('minimumBandwidth',Options.minimumKernelBandwidth),obj.getDataUnlabeled),xLoc(:));
            end
            
            hs = plot(xLoc,F);
            for iLine = 1:length(hs)
                set(hs(iLine),'color',colors(iLine,:));
            end
            
            try
                % Sometimes lowerBounds = upperBounds
                xlim([Summary.lowerBounds, Summary.upperBounds]);
            end
            
            
            grid on;
            xlabel(obj.getFeatureNames{1});
            
            % Create legend
            if obj.isLabeled
                legendStrings = getClassNamesInterp(obj);
                if obj.hasUnlabeled
                    legendStrings = cat(1,legendStrings,{prtPlotUtilUnlabeledLegendString});
                end
                legend(hs,legendStrings,'Location','NorthEast');
            end
            
            if nargout
                varargout = {hs};
            end
        end
        
        function varargout = plotDensity(ds,varargin)
            % Plot the density of each feature independently as a volume.
            %
            % plotDensity(ds)
            % patchHandles = plotDensity(ds);
            %
            % plotDensity(ds,'PARMNAME',PARAMVALUE)
            %   Additional parameters:
            %       nDensitySamples        - Number of linearly spaced
            %                                samples used to construct the
            %                                density estimate. Default 500.
            %       faceAlpha              - Face alpha value of the patch
            %                                for each density. Must be a
            %                                value between 0 and 1. Default
            %                                0.5
            %       minimumKernelBandwidth - minimumBandwidth parameter of
            %                                prtRvKde that is used to
            %                                estimate each density. default
            %                                []. See prtRvKde
            %
            % Example:
            %    ds = prtDataGenMary;
            %    plotDensity(ds)
            %
            %    ds = prtDataGenIris;
            %    plotDensity(ds,'minimumKernelBandwidth',5e-3);
            
            Options.nDensitySamples = 500;
            Options.faceAlpha = 0.5;
            Options.minimumKernelBandwidth = [];
            
            if nargin > 1
                assert(mod(length(varargin),2)==0,'Additional inputs must be string value pairs')
                
                paramNames = varargin(1:2:end);
                paramValues = varargin(2:2:end);
                
                optionFieldNames = fieldnames(Options);
                for iPair = 1:length(paramNames)
                    assert(ismember(paramNames{iPair},optionFieldNames),'%s is not a valid parameter name for plotDensity() (These parameters are case sensitive.)',paramNames{iPair});
                    Options.(paramNames{iPair}) = paramValues{iPair};
                end
            end
            
            Summary = ds.summarize();
            nClasses = Summary.nClasses;
            if isempty(nClasses)
                nClasses = 1;
            end
            
            patchH = prtUtilPreAllocateHandles(Summary.nFeatures,nClasses + ds.hasUnlabeled);
            colors = cat(1,ds.plotOptions.colorsFunction(nClasses), prtPlotUtilClassColorUnlabeled); % FIX me. Use plotOptions
            holdState = get(gca,'NextPlot');
            
            if strcmpi(get(gcf,'NextPlot'),'New')
                figure
            end
            
            if strcmp(holdState,'replace')
                cla; % Clear axes since patch doesn't automatically
            end
            
            for iFeature = 1:Summary.nFeatures
                low = Summary.lowerBounds(iFeature);
                high = Summary.upperBounds(iFeature);
                
                range = high-low;
                low = low - range/10;
                high = high + range/10;
                
                xLoc = linspace(low, high, Options.nDensitySamples);
                xLoc = sort(cat(1,xLoc(:),ds.getObservations(:,iFeature)),'ascend');
                
                F = zeros([length(xLoc), nClasses+ ds.hasUnlabeled]);
                for cY = 1:nClasses
                    F(:,cY) = pdf(mle(prtRvKde('minimumBandwidth',Options.minimumKernelBandwidth),ds.getObservationsByClassInd(cY,iFeature)),xLoc(:));
                end
                if ds.hasUnlabeled
                    F(:,end) = pdf(mle(prtRvKde('minimumBandwidth',Options.minimumKernelBandwidth),ds.getDataUnlabeled(iFeature)),xLoc(:));
                end
                
                %F = bsxfun(@rdivide,F,trapz(xLoc, F));
                %F = bsxfun(@rdivide,F,max(F,[],1));.>
                F = bsxfun(@rdivide,F,max(max(F),trapz(xLoc, F))); % Prefer to integrate but it might not look right, so if big peaks in density (>1)set the max to 1
                
                %xLoc = (xLoc-mean(xLoc))./std(xLoc); % No longer centered
                
                for cY = 1:nClasses
                    cPatch = cat(2,cat(1,-F(:,cY),flipud(F(:,cY))), cat(1,xLoc, flipud(xLoc)));
                    patchH(iFeature,cY) = patch(cPatch(:,1)+iFeature, cPatch(:,2), colors(cY,:),'edgecolor','none');
                end
                if ds.hasUnlabeled
                    cY = cY + 1;
                    cPatch = cat(2,cat(1,-F(:,cY),flipud(F(:,cY))), cat(1,xLoc, flipud(xLoc)));
                    patchH(iFeature,cY) = patch(cPatch(:,1)+iFeature, cPatch(:,2), colors(cY,:),'edgecolor','none');
                end
            end
            
            set(patchH,'FaceAlpha',Options.faceAlpha);
            
            set(gca,'NextPlot',holdState);
            grid on
            xlabel('Feature');
            ylabel('Feature Value');
            
            % Create legend
            if ds.isLabeled
                legendStrings = getClassNamesInterp(ds);
                if ds.hasUnlabeled
                    legendStrings = cat(1,legendStrings,{prtPlotUtilUnlabeledLegendString});
                end
                legend(patchH(1,:),legendStrings,'Location','SouthEast');
            end
            
            if Summary.nFeatures < 10
                set(gca,'XTick',1:Summary.nFeatures,'XTickLabel',ds.getFeatureNames());
            end
            
            if nargout
                varargout = {patchH};
            end
            
        end
        
        function varargout = plotBeeSwarm(ds,varargin)
            % Plot the density of each feature independently as a scatter
            %
            % plotBeeSwarm(ds)
            % patchHandles = plotBeeSwarm(ds);
            % [patchHandles, boxHandles] = plotBeeSwarm(ds);
            %
            % plotBeeSwarm(ds,'PARMNAME',PARAMVALUE)
            %   Additional parameters:
            %       minimumKernelBandwidth - minimumBandwidth parameter of
            %                                prtRvKde that is used to
            %                                estimate each density. default
            %                                eps.
            %
            % Example:
            %    ds = prtDataGenIris;
            %    plotBeeSwarm(ds)
            %
            %    ds = prtDataGenIris;
            %    plotBeeSwarm(ds,'minimumKernelBandwidth',5e-3);
            
            Options.minimumKernelBandwidth = [];
            
            if nargin > 1
                assert(mod(length(varargin),2)==0,'Additional inputs must be string value pairs')
                
                paramNames = varargin(1:2:end);
                paramValues = varargin(2:2:end);
                
                optionFieldNames = fieldnames(Options);
                for iPair = 1:length(paramNames)
                    assert(ismember(paramNames{iPair},optionFieldNames),'%s is not a valid parameter name for plotBeeSwarm() (These parameters are case sensitive.)',paramNames{iPair});
                    Options.(paramNames{iPair}) = paramValues{iPair};
                end
            end
            
            Summary = ds.summarize();
            
            holdState = get(gca,'NextPlot');
            
            if strcmpi(get(gcf,'NextPlot'),'New')
                figure
            end
            
            if strcmp(holdState,'replace')
                cla; % Clear axes since patch doesn't automatically
            end
            
            % Estimate each features density and plot
            F = nan([Summary.nObservations, Summary.nFeatures]);
            for iFeature = 1:Summary.nFeatures
                F(:,iFeature) = pdf(mle(prtRvKde('minimumBandwidth',Options.minimumKernelBandwidth),ds.getObservations(:,iFeature)),ds.getObservations(:,iFeature));
            end
            F = bsxfun(@rdivide,F,max(F))/4;
            FLeft = F;
            F = bsxfun(@plus,F,1:Summary.nFeatures);
            FLeft = bsxfun(@plus,-FLeft,1:Summary.nFeatures);
            %centeredX = bsxfun(@minus,bsxfun(@rdivide,ds.getObservations(),Summary.upperBounds),Summary.lowerBounds./Summary.upperBounds);
            x = ds.getObservations(); % No longer actually centered
            
            % In the new version each point is distributed according
            % to the local density. (drawn uniformly)
            hold on;
            ds = ds.setObservationsAndTargets(cat(2,rand(size(F(:))).*(F(:)-FLeft(:)) + FLeft(:),x(:)),repmat(ds.getTargets(),Summary.nFeatures,1));
            plotHandles = plot(ds);
            
            
            xlabel('Feature');
            ylabel('Feature Value');
            
            set(gca,'NextPlot',holdState,'YTick',[]);
            
            set(legend,'location','best');
            
            if Summary.nFeatures < 10
                set(gca,'XTick',1:Summary.nFeatures,'XTickLabel',ds.getFeatureNames());
            end
            xlim([0.5 Summary.nFeatures+0.5]);
            grid on
            
            if nargout
                varargout = {plotHandles, boxHandles};
            end
        end
        
        function varargout = plotAsTimeSeries(obj,featureIndices,xData)
            % plotAsTimeSeries  Plot the data set as time series data
            %
            % dataSet.plotAsTimeSeries() plots the data contained in
            % dataSet as if it were a time series.
            
            if ~obj.isLabeled
                obj = obj.setTargets(zeros(obj.nObservations,1));
                obj = obj.setClassNames({'Unlabeled'});
            end
            
            if nargin < 2 || isempty(featureIndices)
                featureIndices = 1:obj.nFeatures;
            end
            
            nClasses = obj.nClasses;
            classColors = obj.plotOptions.colorsFunction(obj.nClasses);
            lineWidth = obj.plotOptions.symbolLineWidth;
            
            handleArray = prtUtilPreAllocateHandles(nClasses,1);
            allHandles = cell(nClasses,1);
            
            holdState = get(gca,'nextPlot');
            
            if obj.hasUnlabeled
                % There are unlabeled observations so we should plot those
                % first That way they appear underneath of the labeled
                % observations
                
                cX = obj.getDataUnlabeled(featureIndices);
                classColor = prtPlotUtilClassColorUnlabeled; % FIX: Move to plotOptions?
                
                if nargin < 3
                    xInd = 1:size(cX,2);
                else
                    xInd = xData;
                end
                
                unlabeledHandles = prtPlotUtilLinePlot(xInd,cX,classColor,lineWidth);
                unlabeledHandle = unlabeledHandles(1);
                hold on;
            end
            
            
            % Loop through classes and plot
            for i = 1:nClasses
                %Use "i" here because it's by uniquetargetIND
                cX = obj.getObservationsByClassInd(i, featureIndices);
                
                if nargin < 3
                    xInd = 1:size(cX,2);
                else
                    xInd = xData;
                end
                
                h = prtPlotUtilLinePlot(xInd,cX,classColors(i,:),lineWidth);
                handleArray(i) = h(1);
                allHandles{i} = h(:);
                
                if i == 1
                    hold on;
                end
            end
            set(gca,'nextPlot',holdState);
            % Set title
            title(obj.name);
            
            if obj.hasUnlabeled
                handleArray = cat(1,handleArray(:),unlabeledHandle);
                allHandles = cat(1, allHandles(:), {unlabeledHandles});
            end
            
            
            % Create legend
            if obj.isLabeled
                legendStrings = getClassNamesInterp(obj);
                if obj.hasUnlabeled
                    legendStrings = cat(1,legendStrings,{prtPlotUtilUnlabeledLegendString});
                end
                legend(handleArray,legendStrings,'Location','SouthEast');
            end
            
            
            % Handle Outputs
            varargout = {};
            if nargout > 0
                varargout = {handleArray, legendStrings, allHandles};
            end
        end
        
        function explore(obj, AdditionalOptions)
            % explore  Explore the prtDataSetObject
            %
            %   dataSet.explore() opens the prtDataSetObject explorer for
            %   visualizing high dimensional data sets.
            
            if nargin < 2
                AdditionalOptions = [];
            end
            if isa(AdditionalOptions,'function_handle');
                AdditionalOptions = struct('additionalOnClickFunction',AdditionalOptions);
            end
            try
                prtPlotUtilDataSetExploreGuiWithNavigation(obj,AdditionalOptions);
            catch %#ok<CTCH>
                error('prt:prtDataSetClassExplore','An unexpected error was encountered with explore(). If this error persists you may want to try using exploreSimple().')
            end
        end
        
        function exploreSimple(obj,varargin)
            % exploreSimple Explore the prtDataSetObject using basic
            % controls
            %
            %   dataSet.exploreSimple() opens the prtDataSetObject
            %   explorer for visualizing high dimensional data sets.
            prtPlotUtilDataSetExploreGuiSimple(obj,varargin{:})
        end
        
        function varargout = imagesc(dataSet,varargin)
            % imagesc Generate an imagesc-like visualization of dataSet
            %
            % imagesc(dataSet) genereates an imagesc visualization of
            %   the data field in dataSet, with lines separating the data
            %   from various classes.  Class names are specified along the
            %   Y-axis.  Features are along the X-axis.  Prior to
            %   visualization, the data set is re-ordered so classes with
            %   the same class index are contiguous and class indices are
            %   monotonically increasing.
            %
            % imagesc(dataSet,cLim) specify the limits of
            %   the colormap for visualization.  See imagesc for more
            %   information.
            %
            % [imHandle,lineHandle] = prtUtilDataSetImagesc(...) output a
            %   handle to the image and lines used in the visualization.
            %
            % [imHandle,lineHandle] = prtUtilDataSetImagesc(...,param,val)
            %   enables specification of addition input arguments as
            %   parameter/value pairs.  Valid parameters are:
            %       x - the x input to imagesc.
            %       y - the y input to imagesc
            %       cLim - the imagesc color limits; see above
            %
            % Example usage:
            %   ds = prtDataGenMary;
            %   ds.imagesc;
            %
            %   ds.imagesc([-1 1]); % ds.imagesc('cLim',[-1 1]); %equivalent
            %
            %
            if nargin == 2
                varargin{2} = varargin{1};
                varargin{1} = 'cLim';
            end
            if nargin > 2 && isa(varargin{1},'double')
                varargin(end+1:end+2) = {'cLim',varargin{1}};
                varargin = varargin(2:end);
            end
            
            p = inputParser;
            p.addParameter('x',[]);
            p.addParameter('y',[]);
            p.addParameter('cLim',[]);
            p.parse(varargin{:});
            inputs = p.Results;
            
            lineWidthSpec = 3;
            
            % Handle sorting, make image, and figure out class names:
            x = dataSet.X;
            hasTargets = dataSet.isLabeled;
            
            % Resort the data relative to the targets
            [sortedTargets,inds] = sort(dataSet.targets);
            uTargets = unique(sortedTargets);
            if any(isnan(uTargets))
                uTargets = uTargets(~isnan(uTargets));
                uTargets(end+1) = nan;
            end
            if hasTargets
                x = x(inds,:);
            end
            
            if isempty(inputs.cLim)
                handleOut = imagesc(inputs.x,inputs.y,x);
            else
                handleOut = imagesc(inputs.x,inputs.y,x,inputs.cLim);
            end
            
            legendStrings = getClassNamesInterp(dataSet);
            if dataSet.hasUnlabeled
                unlabledLegenedName = prtPlotUtilUnlabeledLegendString;
                legendStrings = cat(1,legendStrings,{unlabledLegenedName});
            end
            
            % Find the places to draw the lines, and the places to make the ticks
            prevFound = 0;
            lastFound = size(x,1);
            if ~isempty(inputs.y);
                prevFound = inputs.y(1);
                lastFound = inputs.y(end);
            end
            xLims = [0, size(x,2)+1];
            if ~isempty(inputs.x);
                xLims = [inputs.x(1),inputs.x(end)];
            end
            textLocs = [];
            lHandleOut = nan(length(uTargets)-1);
            for i = 2:length(uTargets)
                cTarget = uTargets(i);
                found = find(sortedTargets == cTarget);
                if isempty(found)
                    found = find(isnan(sortedTargets));
                end
                found = found(1);
                
                if ~isempty(inputs.y)
                    found = found/length(sortedTargets)*(inputs.y(end)-inputs.y(1)) + inputs.y(1);
                end
                textLocs = cat(1,textLocs,mean([found,prevFound]));
                hold on;
                lHandleOut(i) = plot(xLims,[found,found]-.5,'k');
                set(lHandleOut(i),'linewidth',lineWidthSpec);
                hold off;
                prevFound = found;
            end
            textLocs = cat(1,textLocs,mean([prevFound,lastFound]));
            
            % Make the ticks
            xlabel('Features');
            set(gca,'xtick',unique(round(get(gca,'xtick'))));
            set(gca,'ytick',textLocs);
            set(gca,'ytickLabel',legendStrings);
            title(dataSet.name);
            
            % Handle silent outputs
            if nargout > 0
                varargout = {handleOut lHandleOut};
            end
            
        end
        
        function varargout = plot(obj, featureIndices)
            % Plot   Plot the prtDataSetClass object
            %
            %   dataSet.plot() Plots the prtDataSetClass object.
            
            if nargin < 2 || isempty(featureIndices)
                featureIndices = 1:obj.nFeatures;
            end
            if islogical(featureIndices)
                featureIndices = find(featureIndices);
            end
            
            nPlotDimensions = length(featureIndices);
            if nPlotDimensions < 1
                warning('prt:plot:NoPlotDimensionality','No plot dimensions requested.');
                varargout = {};
                return
            elseif nPlotDimensions > 3
                %Too many dimensions; default to explore()
                explore(obj);
                varargout = {};
                return
            end
            nClasses = obj.nClasses;
            if nClasses == 0 && ~obj.hasUnlabeled
                obj.Y = zeros(obj.nObservations,1);
                nClasses = obj.nClasses;
            end
            
            classColors = obj.plotOptions.colorsFunction(obj.nClasses);
            classSymbols = obj.plotOptions.symbolsFunction(obj.nClasses);
            lineWidth = obj.plotOptions.symbolLineWidth;
            markerSize = obj.plotOptions.symbolSize;
            
            handleArray = prtUtilPreAllocateHandles(nClasses,1);
            
            holdState = get(gca,'nextPlot');
            % This call to gca will create a figure if it doesn't already
            % exist
            
            if obj.hasUnlabeled
                % There are unlabeled observations so we should plot those
                % first That way they appear underneath of the labeled
                % observations
                
                featureNames = obj.getFeatureNames(featureIndices);
                cX = obj.getDataUnlabeled(featureIndices);
                classEdgeColor = prtPlotUtilClassColorUnlabeled; % FIX: Move to plotOptions?
                classColor = prtPlotUtilClassColorUnlabeled; % FIX: Move to plotOptions?
                classSymbol = prtPlotUtilClassSymbolsUnlabeled; % FIX: Move to plotOptions
                unlabaledLegenedName = prtPlotUtilUnlabeledLegendString; % FIX: Move to plotOptions
                unlabeledHandle = prtPlotUtilScatter(cX,featureNames,classSymbol,classColor,classEdgeColor,lineWidth, markerSize);
                
                hold on;
            end
            
            % Loop through classes and plot
            uniqueClasses = obj.uniqueClasses;
            for i = 1:nClasses
                cX = obj.getObservationsByClassInd(i, featureIndices);
                %Note, class colors should really be linked to
                %uniqueClasses(i), not i
                classEdgeColor = obj.plotOptions.symbolEdgeModificationFunction(classColors(i,:));
                
                featureNames = obj.getFeatureNames(featureIndices);
                if size(cX,2) == 1
                    if ~isempty(uniqueClasses)
                        cX = cat(2,cX,repmat(uniqueClasses(i),size(cX,1),1));
                    else
                        %Default behaviour:
                        cX = cat(2,cX,ones(size(cX,1),1));
                    end
                    featureNames{end+1} = 'Target'; %#ok<AGROW>
                end
                handleArray(i) = prtPlotUtilScatter(cX,featureNames,classSymbols(i),classColors(i,:),classEdgeColor,lineWidth, markerSize);
                
                hold on;
            end
            set(gca,'nextPlot',holdState);
            % Set title
            title(obj.name);
            
            if obj.hasUnlabeled
                handleArray = cat(1, handleArray(:), unlabeledHandle);
            end
            
            % Create legend
            legendStrings = [];
            if obj.isLabeled
                legendStrings = getClassNamesInterp(obj);
                if obj.hasUnlabeled
                    legendStrings = cat(1,legendStrings,{unlabaledLegenedName});
                end
                legend(handleArray,legendStrings,'Location','SouthEast');
            end
            
            % Handle Outputs
            varargout = {};
            if nargout > 0
                varargout = {handleArray,legendStrings};
            end
        end
        function varargout = plotSortedFeature(obj, featureIndex)
            % PlotSortedFeature   Plots a feature of a prtDataSetClass
            % object sorted 
            %
            %   dataSet.plotSortedFeature(1)
            
            if nargin < 2 || isempty(featureIndex)
                featureIndex = 1:obj.nFeatures;
            end
            if islogical(featureIndex)
                featureIndex = find(featureIndex);
            end
            
            nPlotDimensions = length(featureIndex);
            if nPlotDimensions < 1
                warning('prt:plotSortedFeature:NoPlotDimensionality','No featureIndex requested.');
                varargout = {[]};
                return
            elseif nPlotDimensions > 1
                %Too many dimensions; default to explore()
                warning('prt:plotSortedFeature:TooManyPlotDimensionality','featureIndex must be a single feature.');
                varargout = {[]};
                return;
            end
            
            obj = obj.retainFeatures(featureIndex);
            
            nClasses = obj.nClasses;
            if nClasses == 0 && ~obj.hasUnlabeled
                obj.Y = zeros(obj.nObservations,1);
                nClasses = obj.nClasses;
            end
            
            % Sort by the feature
            [~, sortingInds] = sort(obj.X,'descend');
            obj = obj.retainObservations(sortingInds);
            
            classColors = obj.plotOptions.colorsFunction(obj.nClasses);
            classSymbols = obj.plotOptions.symbolsFunction(obj.nClasses);
            lineWidth = obj.plotOptions.symbolLineWidth;
            markerSize = obj.plotOptions.symbolSize;
            
            handleArray = prtUtilPreAllocateHandles(nClasses,1);
            
            holdState = get(gca,'nextPlot');
            % This call to gca will create a figure if it doesn't already
            % exist
            
            if obj.hasUnlabeled
                % There are unlabeled observations so we should plot those
                % first That way they appear underneath of the labeled
                % observations
                
                [cX, isNans] = obj.getDataUnlabeled();
                xInd = find(isNans);
            
                classEdgeColor = prtPlotUtilClassColorUnlabeled; % FIX: Move to plotOptions?
                classColor = prtPlotUtilClassColorUnlabeled; % FIX: Move to plotOptions?
                classSymbol = prtPlotUtilClassSymbolsUnlabeled; % FIX: Move to plotOptions
                unlabaledLegenedName = prtPlotUtilUnlabeledLegendString; % FIX: Move to plotOptions
                
                unlabeledHandle = stem(xInd, cX, classSymbol,'Color',classColor,'MarkerFaceColor',classColor,'MarkerEdgeColor',classEdgeColor,'linewidth',lineWidth,'MarkerSize',markerSize);
                
                hold on;
            end
            
            % Loop through classes and plot
            for i = 1:nClasses
                [cX,isThisClass] = obj.getDataByClassInd(i);
                xInd = find(isThisClass);
    
                classEdgeColor = obj.plotOptions.symbolEdgeModificationFunction(classColors(i,:));
                
                handleArray(i) = stem(xInd, cX, classSymbols(i),'Color',classColors(i,:), 'MarkerFaceColor',classColors(i,:),'MarkerEdgeColor',classEdgeColor,'linewidth',lineWidth,'MarkerSize',markerSize);
                
                hold on;
            end
            set(gca,'nextPlot',holdState);
            % Set title
            title(obj.name);
            
            if obj.hasUnlabeled
                handleArray = cat(1, handleArray(:), unlabeledHandle);
            end
            
            % Create legend
            legendStrings = [];
            if obj.isLabeled
                legendStrings = getClassNamesInterp(obj);
                if obj.hasUnlabeled
                    legendStrings = cat(1,legendStrings,{unlabaledLegenedName});
                end
                legend(handleArray,legendStrings,'Location','SouthEast');
            end
            
            % Handle Outputs
            varargout = {};
            if nargout > 0
                varargout = {handleArray,legendStrings};
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
        function varargout = exploreObjectOriented(ds)
            p = prtUiDataSetClassPlot(ds);
            c = p.controls();
            if nargout
                varargout = {p, c};
            else
                varargout = {};
            end
        end
        function dsFoldOut = crossValidateCheckFoldResults(dsIn, dsTrain, dsTest, dsFoldOut)
            dsFoldOut = crossValidateCheckFoldResults@prtDataSetBase(dsIn, dsTrain, dsTest, dsFoldOut);
            dsFoldOut = crossValidateCheckFoldResultsWarnNumberOfClassesBad(dsIn, dsTrain, dsTest, dsFoldOut);
        end
        function self = acquireNonDataAttributesFrom(self, dataSet)
            self = acquireNonDataAttributesFrom@prtDataSetBase(self, dataSet);
            self = acquireCategoricalTargetsNonDataAttributes(self, dataSet);
        end
        
        function dsBig = toPrtDataSetBigMat(self,step,fileDir)
            % dsBig = toPrtDataSetBig(self,step,fileDir)
            %  Convert a prtDataSetClass to a prtDataSetBig using a
            %  prtDataHandlerMatFiles data handler.  
            nBlocks = ceil(self.nObservations./step);
            maxSize = self.nObservations;
            for block = 1:nBlocks;
                start = (block-1)*step+1;
                stop = min([block*step, maxSize]);
                ds = self.retainObservations(start:stop);
                
                file = fullfile(fileDir,sprintf('bigDataFile_%05d.mat',block));
                if exist(file,'file')
                    error('prt:prtDataSetClass:toPrtDataSetBig','File %s already exists; aborting',file);
                end
                save(file,'ds','-v7.3');
            end
            h = prtDataHandlerMatFiles('fileList',fileDir);
            dsBig = prtDataSetBigClass('dataHandler',h);
        end
    end
end
