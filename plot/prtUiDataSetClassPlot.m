classdef prtUiDataSetClassPlot < hgsetget
    
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
    
    
    % ds = prtDataGenIris;
    % p = prtUiDataSetClassPlot(ds);
    %
    % %% At this point a plot has been created. These commands modify it
    % p.colors(1,:) = [0 0 0];
    % p.edgeColors(1,:) = [0 0 0];
    % p.markers(3) = 'p';
    % p.markers(2) = 's';
    % p.markerSizes(3) = 12;
    % p.markerSizes(1) = 4;
    %
    % %% You can also switch the features that are plotted;
    %
    % p.featureIndices = [2 3 4]
    %
    % There are potential issues with closing the window and maipulating
    % "p" but just dont do that for now
    
    properties
        dataSet
        
        titleStr = 'prtDataSetClassPlot';
        
        handles
        
        defaultColorFunction = @(n)prtPlotUtilClassColors(n);
        defaultEdgeColorFunction = @(n)prtPlotUtilSymbolEdgeColorModification(prtPlotUtilClassColors(n));
        defaultMarkerFunction = @(n)prtPlotUtilClassSymbols(n);
        defaultMarkerLineWidth = 1;
        defaultMarkerSize = 8;
        defaultIsVisible = true;
        
        % These will be set
        featureIndices = []; %1, 2 or 3 natural numbers
        
        markerSizes = [];
        colors = [];
        edgeColors = [];
        markerLineWidths = [];
        markers = [];
        isVisible = [];
        
        legendStrings = {};
        featureNames = {};
        
        colorUnlabeled = prtPlotUtilClassColorUnlabeled;
        edgeColorUnlabeled = prtPlotUtilClassColorUnlabeled;
        markerUnlabeled = prtPlotUtilClassSymbolsUnlabeled;
        markerLineWidthUnlabeled = 1;
        markerSizeUnlabeled = 8;
        isVisibleUnlabeled = true;
        
        legendStringUnlabeled = prtPlotUtilUnlabeledLegendString;
        
        madeThisWindow = false;
        
        onClickCallback
    end
    properties (SetAccess = 'protected', SetObservable)
        clickedIndex
    end
    
    methods
        function self = prtUiDataSetClassPlot(varargin)
            
            if nargin == 1
                self.dataSet = varargin{1};
            elseif ~mod(nargin,2)
                self = prtUtilAssignStringValuePairs(self,varargin{:});
            else
                self.dataSet = varargin{1};
                self = prtUtilAssignStringValuePairs(self,varargin{2:end});
            end
            
            init(self);
        end
        
        function init(self)
            if isempty(self.dataSet)
                error('prt:prtDataSetClassPlot:noDataSet','dataSet must be defined');
            end
            
            initDefaultParametersFromDataSet(self);
            
            initContainerGraphics(self);
            
            self.setDataSetDependentProperties();
            self.plot();
        end
        function initDefaultParametersFromDataSet(self)
            self.defaultColorFunction = self.dataSet.plotOptions.colorsFunction;
            self.defaultEdgeColorFunction = @(n)self.dataSet.plotOptions.symbolEdgeModificationFunction(self.dataSet.plotOptions.colorsFunction(n)); 
            self.defaultMarkerFunction = self.dataSet.plotOptions.symbolsFunction;
            self.defaultMarkerLineWidth = self.dataSet.plotOptions.symbolLineWidth;
            self.defaultMarkerSize = self.dataSet.plotOptions.symbolSize;
        end
        function initContainerGraphics(self)
            
            % Check if there is currently an axis
            % If that is the case then we should
            if ~isfield(self.handles,'axes') || isempty(self.handles.axes)
                maybeGcf = get(0,'CurrentFigure');
                if isempty(maybeGcf)
                    % No figure open
                    self.initFigure();
                else
                    self.handles.figure = gcf;
                end
                
                maybeGca = get(self.handles.figure,'CurrentAxes');
                if isempty(maybeGca);
                    self.initAxes();
                else
                    self.handles.axes = gca;
                end
            end
        end
        
        function initFigure(self)
            self.handles.figure = figure('Name',self.titleStr);
        end
        function initAxes(self)
            self.handles.axes = axes('parent', self.handles.figure);
        end
        
        function setDataSetDependentProperties(self)
            nClasses = self.dataSet.nClasses;
            if nClasses == 0 && ~self.dataSet.hasUnlabeled
                self.dataSet.Y = zeros(self.dataSet.nObservations,1);
                nClasses = 1;
            end
            
            self.markerSizes = ones(1,nClasses)*self.defaultMarkerSize;
            self.colors = self.defaultColorFunction(nClasses);
            self.edgeColors = self.defaultEdgeColorFunction(nClasses);
            self.markers = self.defaultMarkerFunction(nClasses);
            self.markerLineWidths = ones(1,nClasses)*self.defaultMarkerLineWidth;
            self.isVisible = true(1,nClasses).*self.defaultIsVisible;
            
            self.legendStrings = getClassNames(self.dataSet);
            
            self.featureIndices = 1:min(2,self.dataSet.nFeatures);
        end
        
        function plot(self)
            % Plot   Plot the prtDataSetClass object
            %
            %   dataSet.plot() Plots the prtDataSetClass object.
            
            if ~ishandle(self.handles.axes)
                % Something happen to our axes? What should we do? quit?
                % I decided to just remake the axes
                initContainerGraphics(self);
            end
            
            % make our axes the current axes;
            axes(self.handles.axes);
            
            isRealFeature = self.featureIndices>0;
            
            isTruthFeature = ~isRealFeature;
            
            selFeatsNoZeros = self.featureIndices(isRealFeature);
            
            nClasses = self.dataSet.nClasses;
            nFeatures = length(self.featureIndices);
            
            realFeatureNames = self.dataSet.getFeatureNames(selFeatsNoZeros);
            
            self.featureNames = cell(1,nFeatures);
            self.featureNames(isRealFeature) = realFeatureNames;
            self.featureNames(isTruthFeature) = repmat({'Target'}, 1, sum(isTruthFeature));
            
            holdState = get(self.handles.axes, 'nextPlot');
            
            self.handles.lineUnlabeled = [];
            if self.dataSet.hasUnlabeled
                cRealX = self.dataSet.getObservationsUnlabeled(selFeatsNoZeros);
                if any(isTruthFeature)
                    cX = nan(size(cRealX,1), nFeatures);
                    cX(:, isRealFeature) = cRealX;
                    % We just use nans for the targets that are
                    % techinically nan? Not sure what to do. This way they
                    % wont plot
                else
                    cX = cRealX;
                end
                
                self.handles.lineUnlabeled = prtPlotUtilScatter(cX, self.featureNames, self.markerUnlabeled, self.colorUnlabeled, self.edgeColorUnlabeled, self.markerLineWidthUnlabeled, self.markerSizeUnlabeled);
                hold on;
            end
            
            uClasses = self.dataSet.uniqueClasses;
            self.handles.lines = prtUtilPreAllocateHandles(1,self.dataSet.nClasses);
            for iClass = 1:nClasses
                
                
                if any(isTruthFeature)
                    cRealX = self.dataSet.getObservationsByClassInd(iClass,selFeatsNoZeros);
                    
                    cX = uClasses(iClass)*ones(size(cRealX,1), nFeatures);
                    cX(:, isRealFeature) = cRealX;
                    
                else
                    cX = self.dataSet.getObservationsByClassInd(iClass, selFeatsNoZeros);
                end
                
                self.handles.lines(iClass) = prtPlotUtilScatter(cX, self.featureNames, self.markerUnlabeled , self.colorUnlabeled, self.edgeColorUnlabeled, self.markerLineWidthUnlabeled, self.markerSizeUnlabeled); % For now
                
                hold on;
            end
            
            set(gca,'nextPlot',holdState);
            
            self.setAllClassAttributes();
            
            % Turn on the click callback and turn off the line hittests
            set(self.handles.axes,'ButtonDownFcn',@self.axesOnClickCallback);
            set(self.handles.lines,'HitTest','off')
            set(self.handles.lineUnlabeled,'HitTest','off')
            
            % Set title
            title(self.dataSet.name);
            
            % Create legend
            if self.dataSet.isLabeled
                if self.dataSet.hasUnlabeled
                    strs = cat(1,self.legendStrings,{self.legendStringUnlabeled});
                    hands = cat(1,self.handles.lines(:), self.handles.lineUnlabeled);
                else
                    strs = self.legendStrings;
                    hands = self.handles.lines(:);
                end
                self.handles.legend = legend(hands,strs,'Location','SouthEast');
                
                % Get a function handle to refresh this legend
                uic = get(self.handles.legend,'UIContextMenu');
                uimenu_refresh = findall(uic,'Label','Refresh');
                self.handles.legendRefresh =  get(uimenu_refresh,'Callback');
                
                %hgfeval(callback,[],[]);
            end
        end
        
        function setAllClassAttributes(self)
            if ~isempty(self.handles) && isfield(self.handles,'lines') && ~isempty(self.handles.lines)
                for iClass = 1:length(self.handles.lines)
                    self.setClassAttributes(iClass, true);
                end
            end
        end
        
        function setClassAttributes(self, iClass, byPass)
            if nargin < 3
                byPass = false;
            end
            
            if (byPass || (~isempty(self.handles) && isfield(self.handles,'lines') && ~isempty(self.handles.lines))) && (length(self.handles.lines) >= iClass) && ishandle(self.handles.lines(iClass))
                onOff = {'off','on'};
                set(self.handles.lines(iClass),'marker',self.markers(iClass),...
                    'markerSize',self.markerSizes(iClass),...
                    'markerFaceColor',self.colors(iClass,:),...
                    'MarkerEdgeColor',self.edgeColors(iClass,:),...
                    'lineWidth',self.markerLineWidths(iClass),...
                    'visible',onOff{self.isVisible(iClass)+1});
            end
        end
        
        function setUnlabeledAttributes(self)
            if ~isempty(self.handles) && isfield(self.handles,'lines') && ~isempty(self.handles.lineUnlabeled) && ishandle(self.handles.lineUnlabeled)
                onOff = {'off','on'};
                set(self.handles.lineUnlabeled,'marker', self.symbolUnlabeled, ...
                    'markerFaceColor',self.colorUnlabeled, ...
                    'markerEdgeColor',self.edgeColorUnlabeled, ...
                    'lineWidth',self.symbolLineWidthUnlabeled, ...
                    'markerSize',self.makerSizeUnlabeled,...
                    'visible',onOff{self.isVisibleUnlabeled(iClass)+1});
            end
        end
        
        %         function close(self)
        %             if self.madeThisWindow
        %                 try %#ok<TRYNC>
        %                     close(self.handleStruct.figureHandle);
        %                 end
        %             else
        %                 % I don't know
        %             end
        %         end
        
        function set.markers(self,val)
            self.markers = val;
            self.setAllClassAttributes();
        end
        
        function set.markerSizes(self,val)
            self.markerSizes = val;
            self.setAllClassAttributes();
        end
        
        function set.colors(self,val)
            self.colors = val;
            self.setAllClassAttributes();
        end
        
        function set.edgeColors(self, val)
            self.edgeColors = val;
            self.setAllClassAttributes();
        end
        function set.markerLineWidths(self, val)
            self.markerLineWidths = val;
            self.setAllClassAttributes();
        end
        
        function set.isVisible(self, val)
            self.isVisible = val;
            self.setAllClassAttributes();
        end
        
        function set.markerUnlabeled(self,val)
            self.markerUnlabeled = val;
            self.setUnlabeledAttributes();
        end
        
        function set.markerSizeUnlabeled(self,val)
            self.markerSizeUnlabeled = val;
            self.setUnlabeledAttributes();
        end
        
        function set.colorUnlabeled(self,val)
            self.colorUnlabeled = val;
            self.setUnlabeledAttributes();
        end
        
        function set.edgeColorUnlabeled(self, val)
            self.edgeColorUnlabeled = val;
            self.setUnlabeledAttributes();
        end
        function set.markerLineWidthUnlabeled(self, val)
            self.markerLineWidthUnlabeled = val;
            self.setUnlabeledAttributes();
        end
        function set.isVisibleUnlabeled(self, val)
            self.isVisibleUnlabeled = val;
            self.setUnlabeledAttributes();
        end
        
        function set.legendStrings(self, val)
            self.legendStrings = val;
            self.updateLegendStrings;
        end
        
        function set.legendStringUnlabeled(self, val)
            self.legendStringUnlabeled = val;
            self.updateLegendStrings;
        end
        function updateLegendStrings(self)
            if isfield(self.handles,'legend') && ishandle(self.handles.legend)
                
                if self.dataSet.hasUnlabeled
                    strs = cat(1,self.legendStrings,{self.legendStringUnlabeled});
                else
                    strs = self.legendStrings;
                end
                
                set(self.handles.legend,'String',strs);
            end
        end
        function legendRefresh(self)
            try %#ok<TRYNC>
                hgfeval(self.handles.legendRefresh,[],[]);
            end
        end
        
        function set.featureIndices(self, val)
            oldVal = self.featureIndices;
            
            self.featureIndices = val;
            
            if isempty(oldVal) || isequal(oldVal, val)
                % First set, or same set don't update plot
                return;
            end
            
            % Store some legend properties, just incased it was
            % moved/altered.
            legendStruct = getPersistantLegendProperties(self);
            
            self.plot();
            
            % Restore the legend properties
            setPersistantLegendProperties(self,legendStruct);
        end
        
        function set.dataSet(self,val)
            self.dataSet = val;
            self.setDataSetDependentProperties();
        end
        
        function controller = controls(self)
            controller = prtUiDataSetClassExploreWidget('plotManager',self);
        end
        
        
        
    end
    methods (Hidden)
        function legendStruct = getPersistantLegendProperties(self)
            if isfield(self.handles,'legend') && ishandle(self.handles.legend)
                legendStruct.Position = get(self.handles.legend,'Position');
                legendStruct.Location = get(self.handles.legend, 'Location');
                legendStruct.Orientation = get(self.handles.legend,'Orientation');
                legendStruct.String = get(self.handles.legend,'String');
            else
                legendStruct = [];
            end
        end
        
        function setPersistantLegendProperties(self,legendStruct)
            if isempty(legendStruct)
                return
            end
            
            if isfield(self.handles,'legend') && ishandle(self.handles.legend)
                set(self.handles.legend,'Position',legendStruct.Position);
                set(self.handles.legend, 'Location',legendStruct.Location);
                set(self.handles.legend,'Orientation',legendStruct.Orientation);
                set(self.handles.legend,'String',legendStruct.String);
            end
        end
        
        function axesOnClickCallback(self, myHandle,eventData)  %#ok<INUSD>
            
            cData = self.dataSet;
            obsIsVisible = ismember(self.dataSet.targets, self.dataSet.uniqueClasses(logical(self.isVisible)));
            if self.isVisibleUnlabeled
                obsIsVisible = obsIsVisible | isnan(self.dataSet.targets);
            end
            cData = cData.retainObservations(obsIsVisible);

            cX = cData.X;
            
            isRealFeature = self.featureIndices>0;
            isTruthFeature = ~isRealFeature;
            selFeatsNoZeros = self.featureIndices(isRealFeature);
            
            cRealX = cX(:,selFeatsNoZeros);
            if any(isTruthFeature)
                cX = nan(size(cRealX,1), length(self.featureIndices));
                cX(:, isRealFeature) = cRealX;
                cX(:, isTruthFeature) = cData.targets;
            else
                cX = cRealX;
            end
            
            [rP,rD] = rotateDataAndClick(self,cX);
            
            dist = prtDistanceEuclidean(rP,rD);
            [minDist,justClickedIndex] = min(dist);  %#ok<ASGLU>
            
            if ~all(obsIsVisible)
                visibleObsInds = find(obsIsVisible);
                justClickedIndex = visibleObsInds(justClickedIndex);
            end
            
            self.clickedIndex = justClickedIndex;
            
            clickUpdateEvent(self)
        end
    
        function clickUpdateEvent(self)
            if ~isempty(self.onClickCallback)
                self.onClickCallback(self); 
            end    
        end
        function [rotatedData,rotatedClick] = rotateDataAndClick(self,data)
            % Used internally; from Click3dPoint from matlab central;
            % See prtExternal.ClickA3DPoint.()
            %
            % It has been modified slightly to fit into this framework.
            %
            % The copyright info from the original file is below.
            %
            % Copyright (c) 2009, Babak Taati All rights reserved.
            %
            % Redistribution and use in source and binary forms, with or
            % without modification, are permitted provided that the following
            % conditions are met:
            %
            %     * Redistributions of source code must retain the above
            %     copyright
            %       notice, this list of conditions and the following
            %       disclaimer.
            %     * Redistributions in binary form must reproduce the above
            %     copyright
            %       notice, this list of conditions and the following
            %       disclaimer in the documentation and/or other materials
            %       provided with the distribution
            %
            % THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND
            % CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
            % INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
            % MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
            % DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS
            % BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
            % EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
            % TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
            % DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
            % ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
            % OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
            % OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
            % POSSIBILITY OF SUCH DAMAGE.
            
            plotAxes = self.handles.axes;
            point = get(plotAxes, 'CurrentPoint'); % mouse click position
            camPos = get(plotAxes, 'CameraPosition'); % camera position
            camTgt = get(plotAxes, 'CameraTarget'); % where the camera is pointing to
            
            camDir = camPos - camTgt; % camera direction
            camUpVect = get(plotAxes, 'CameraUpVector'); % camera 'up' vector
            
            % build an orthonormal frame based on the viewing direction and the
            % up vector (the "view frame")
            zAxis = camDir/norm(camDir);
            upAxis = camUpVect/norm(camUpVect);
            xAxis = cross(upAxis, zAxis);
            yAxis = cross(zAxis, xAxis);
            
            rot = [xAxis; yAxis; zAxis]; % view rotation
            
            % the clicked point represented in the view frame
            rotatedClick = rot * point' ;
            rotatedClick = rotatedClick(1:2,1)';
            
            if size(data,2) < 3
                if size(data,2) < 2
                    rot = rot(1);
                else
                    rot = rot(1:2,1:2);
                end
            end
            
            % the point cloud represented in the view frame
            rotatedData = (rot * data')';
            
            if size(rotatedData,2) > 2
                rotatedData = rotatedData(:,1:2);
            end
            
            if size(data,2) < 2
                rotatedClick = rotatedClick(1);
            end
        end
    
        
        
    end
end
