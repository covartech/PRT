classdef prtUiClassLabeler < hgsetget


    properties

        useClassifier = true;
        
        dataSet
        classifier = prtClassMap;
        handles
        
        onClickDisplayFunction = @(ds, obsInd, featureInds)plotAsTimeSeries(ds.retainObservations(obsInd));
    end
    methods
        function self = prtUiClassLabeler(varargin)
            self = prtUtilAssignStringValuePairs(self, varargin{:});
            
            if isempty(self.dataSet)
                error('dataSet must be defined on input');
            end
            
            if isempty(self.dataSet.Y)
                self.dataSet.Y = nan(self.dataSet.nObservations,1);
            end
            
            self.init();
        end
        function init(self)
            self.handles.mainFigure = figure;
            gca;
            if self.useClassifier
                self.handles.classifierFigure = figure;
            end
            
            self.udpate();
        end
        function udpate(self)
            axesObj = findobj(self.handles.mainFigure,'type','axes');
            %oldView = view(axesObj);
            oldXlim = xlim(axesObj);
            oldYlim = ylim(axesObj);
            oldZlim = zlim(axesObj);
            figure(self.handles.mainFigure)
            explore(self.dataSet, @(ds,obsInd,featureInd)self.onClick(ds,obsInd,featureInd));
            
            %view(axesObj,oldView);
            xlim(axesObj,oldXlim);
            ylim(axesObj,oldYlim);
            zlim(axesObj,oldZlim);
            
            if self.useClassifier && self.dataSet.nClasses > 1 && all(self.dataSet.nObservationsByClass > 2*self.dataSet.nFeatures)
                self.classifier = train(self.classifier, self.dataSet);
                figure(self.handles.classifierFigure)
                plot(self.classifier);
            end
        end
        
        function onClick(self,ds,obsInd, featureInd)
            self.handles.secondaryFigure = figure;
            self.handles.secondaryFigure.KeyPressFcn = @(h,e)self.onClickKeypress(h,e,obsInd);
            self.handles.secondaryFigure.WindowStyle = 'modal';
            
            self.onClickDisplayFunction(ds, obsInd, featureInd);
            
        end
        function onClickKeypress(self, h, e, obsInd)
            key = e.Key;
            switch key
                case {'0','1','2','3','4','5','6','7','8','9'}
                    newY = str2double(key);
                    self.dataSet.Y(obsInd) = newY;
                    
                    close(self.handles.secondaryFigure);
                    self.udpate();
                otherwise
                    title('Invalid key')
            end
            
        end
    end
end
    
    
