classdef prtClassFld < prtClass
 %prtClassFld Fisher linear discriminant classifier
 % 
 %    CLASSIFIER = prtClassFld returns a Fisher linear discriminant classifier
 %
 %    CLASSIFIER = prtClassFld(PROPERTY1, VALUE1, ...) constructs a
 %    prtClassFld object CLASSIFIER with properties as specified by
 %    PROPERTY/VALUE pairs.
 %
 %    A prtClassFld object inherits all properties from the abstract class
 %    prtClass. In addition is has the following properties:
 %
 %    w                  - regression weights, estimated during training
 %    plotBasis          - Flag indicating whether to plot the basis
 %                         functions when the PLOT function is called
 %    plotProjections    - Flag indicating whether to plot the projection
 %                         of points to the basis when the PLOT function is
 %                         called
 %
 %    For information on the Fisher Linear Discriminant algorithm, please
 %    refer to the following URL:
 %
 %    http://en.wikipedia.org/wiki/Linear_discriminant_analysis#Fisher.27s_linear_discriminant
 %
 %    A prtClassFld object inherits the TRAIN, RUN, CROSSVALIDATE and
 %    KFOLDS methods from prtAction. It also inherits the PLOT method from
 %    prtClass.
 %
 %    Example:
 %
 %    ds1 = prtDataGenUnimodal;       % Create some test and
 %    ds2 = prtDataGenUnimodal;   % training data
 %    classifier = prtClassFld;           % Create a classifier
 %    classifier = classifier.train(ds1);    % Train
 %    classified = run(classifier, ds2);         % Test
 %    subplot(2,1,1);
 %    classifier.plot;
 %    subplot(2,1,2);
 %    [pf,pd] = prtScoreRoc(classified);
 %    h = plot(pf,pd,'linewidth',3);
 %    title('ROC'); xlabel('Pf'); ylabel('Pd');
 %  
 %   See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
 %   prtClassMap, prtClassCap, prtClassBinaryToMaryOneVsAll, prtClassDlrt,
 %   prtClassPlsda, prtClassKnn, prtClassRvm, prtClassGlrt,  prtClassSvm,
 %   prtClassTreeBaggingCap, prtClassKmsd, prtClassKnn  

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


 

    properties (SetAccess=private)
        
        name = 'Fisher Linear Discriminant' % Fisher Linear Discriminant
        nameAbbreviation = 'FLD'            % FLD
        isNativeMary = false;  % False
    end
    
    properties (SetAccess = protected)
        % w is a dataSet.nDimensions x 1 vector of projection weights
        % learned during Fld.train(dataSet)
        
        w = []; % The vector of weights, learned during training
        
        % plotting options
        plotBasis = false; % Flag indicating whether or not to plot the basis
        plotProjections = false; % Flag indicating whether or not to plot the projections
    end
    
    methods
     
               % Allow for string, value pairs
        function self = prtClassFld(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
        function self = set.plotProjections(self,value)
            if islogical(value) || (isnumeric(value) && (value == 1 || value == 0))
                self.plotProjections = value;
            else
                error('prt:prtClassFld:plotProjections','plotProjections can only take true or false (boolean or 0/1) values; user speficied value %d',value);
            end
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,dataSet)
            
            n = dataSet.nObservations;
            p = dataSet.nFeatures;
            
            if p > n
                warning('prt:prtClassFld:train:illconditioned','dataSet has n (%d) < p (%d); prtClassFld may not be stable',n,p);
            end
            if ~dataSet.isBinary
                error('prtClassFld:nonBinaryTraining','Input dataSet for prtClassFld.train must be binary');
            end
            
            
            dataH0 = dataSet.getObservationsByClassInd(1);
            dataH1 = dataSet.getObservationsByClassInd(2);
            
            mean0 = mean(dataH0,1);
            mean1 = mean(dataH1,1);
            
            cov0 = cov(dataH0);
            cov1 = cov(dataH1);
            covW = cov1 + cov0;
            
            self.w = covW\(mean1-mean0)'; %w = covW^-1 * (mean1-mean0)'; But better
            self.w = self.w./norm(self.w);
            
        end
        
        function dataSet = runAction(self,dataSet)
            dataSet = prtDataSetClass((self.w'*dataSet.getObservations()')');
        end
        
        function imageHandle = plotGriddedEvaledClassifier(self, DS, linGrid, gridSize, cMap)
            
            % Call the original plot function
            imageHandle = plotGriddedEvaledClassifier@prtClass(self, DS, linGrid, gridSize, cMap);
            
            W = self.w;
            limits = axis;
            nDims = length(W);
            
            if self.plotBasis
                hold on
                switch nDims
                    case 1
                        % Nothing
                    case 2
                        distances = zeros(4,1);
                        distances(1) = sqrt(sum([limits(2); limits(4)].^2));
                        distances(2) = sqrt(sum([limits(1); limits(3)].^2));
                        distances(3) = sqrt(sum([limits(2); limits(3)].^2));
                        distances(4) = sqrt(sum([limits(1); limits(4)].^2));
                
                        highPoint =  max(distances).*W;
                        lowPoint =  -max(distances).*W;
                
                        h = plot([lowPoint(1),highPoint(1)],[lowPoint(2),highPoint(2)],'k');
                        set(h,'linewidth',3);
                    case 3
                        distances = zeros(8,1);
                        distances(1) = sqrt(sum([limits(1); limits(3); limits(5)].^2));
                        distances(2) = sqrt(sum([limits(1); limits(3); limits(6)].^2));
                        distances(3) = sqrt(sum([limits(1); limits(4); limits(5)].^2));
                        distances(4) = sqrt(sum([limits(1); limits(4); limits(6)].^2));
                        distances(5) = sqrt(sum([limits(2); limits(3); limits(5)].^2));
                        distances(6) = sqrt(sum([limits(2); limits(3); limits(6)].^2));
                        distances(7) = sqrt(sum([limits(2); limits(4); limits(5)].^2));
                        distances(8) = sqrt(sum([limits(2); limits(4); limits(6)].^2));
                
                        highPoint =  max(distances).*W;
                        lowPoint =  -max(distances).*W;
                
                        h = plot3([lowPoint(1),highPoint(1)],[lowPoint(2),highPoint(2)],[lowPoint(3), highPoint(3)],'k');
                        set(h,'linewidth',3);
                    otherwise
                        error('prt:prtClassFld:tooManyDimensions','Too many dimensions for plotting.')
                end
            end

            if self.plotProjections && ~isempty(self.dataSet)
                OutputDataSet = run(self, self.dataSet);
                hold on;
                switch nDims
                    case 2
                        for i = 1:double(self.plotProjections):self.dataSet.nObservations
                            cX = self.dataSet.getObservations(i,:);
                            cYout = OutputDataSet.getObservations(i,:);
                            plot([cX(1),cYout*W(1)],[cX(2),cYout*W(2)],'k');
                        end
                    case 3
                        for i = 1:double(self.plotProjections):self.dataSet.nObservations
                            cX = self.dataSet.getObservations(i,:);
                            cYout = OutputDataSet.getObservations(i,:);
                            plot3([cX(1),cYout*W(1)],[cX(2),cYout*W(2)],[cX(3),cYout*W(3)],'k');
                        end
                end
                axis(limits);
            end
            hold off;
        end
        
    end
    
end
