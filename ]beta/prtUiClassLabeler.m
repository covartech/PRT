classdef prtUiClassLabeler < hgsetget

% Copyright (c) 2014 CoVar Applied Technologies
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
    
    
