classdef prtClassPlsda < prtClass
    % prtClassPlsda  Partial least squares discriminant classifier
    %
    %    CLASSIFIER = prtClassPlsda returns a Partial least squares
    %    discriminant classifier
    %
    %    CLASSIFIER = prtClassPlsda(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassMAP object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClassPlsda object inherits all properties from the abstract
    %    class prtClass. In addition is has the following properties:
    %
    %    nComponents  -  The number of components
    %    Bpls         -  The regression weights, estimated during training
    %    xMeans       -  The xMeans, estimated during training
    %    yMeans       -  The yMeana, estimated during training
    %
    %    trainingTechnique - Either 'simpls' or 'pls2' - the training
    %       technique to utilize.  See prtUtilSimpls and prtUtilPls2.
    %
    %    For information on the partial least squares discriminant
    %    algorithm, please refer to the following URL:
    %
    %    http://en.wikipedia.org/wiki/Partial_least_squares_regression
    %
    %    A prtClassPlsda object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT method
    %    from prtClass.
    %
    %    Example:
    %
    %   TestDataSet = prtDataGenUnimodal;      % Create some test and
    %   TrainingDataSet = prtDataGenUnimodal;  % training data
    %   classifier = prtClassPlsda;           % Create a classifier
    %   classifier = classifier.train(TrainingDataSet);    % Train
    %   classified = run(classifier, TestDataSet);         % Test
    %   subplot(2,1,1);
    %   classifier.plot;
    %   subplot(2,1,2);
    %   [pf,pd] = prtScoreRoc(classified,TestDataSet);
    %   h = plot(pf,pd,'linewidth',3);
    %   title('ROC'); xlabel('Pf'); ylabel('Pd');
    %
    %    See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
    %    prtClassMap, prtClassCap, prtClassBinaryToMaryOneVsAll, prtClassDlrt,
    %    prtClassKnn, prtClassFld, prtClassRvm, prtClassGlrt,  prtClass
    
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
        name = 'Partial Least Squares Discriminant' % Partial Least Squares Discriminant
        nameAbbreviation = 'PLSDA' % PLSDA
        isNativeMary = true;  % True
    end
    
    properties
        % w is a DataSet.nDimensions x 1 vector of projection weights
        % learned during Fld.train(DataSet)
        nComponents = 2;
    end
    
    properties (SetAccess=protected)
        Bpls     % The prediction weights
        xScores % T
        yScores % U
        xVectors% P
        yVectors% Q
        
        yMeansFactor % Factor to be added into regression output (accounts for X means and yMeans);
        vipXY   % VIP scores including variations in X
        vipY    % VIP scores including only variations in Y
    end
    
    properties (Hidden)
        trainingTechnique = 'simpls'; %{'Simpls','pls2'};
        %         xMeans % Used for PLS2 (vs. SIMPLS)
    end
    
    methods
        
        function self = prtClassPlsda(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
        function self = set.trainingTechnique(self,val)
            if ~any(strcmpi(val,{'pls2','simpls'}))
                error('prtClassPlsda:trainingTechnique','trainingTechnique must be one of {''pls2'',''simpls''}; string provided was: %s',val);
            end
            self.trainingTechnique = val;
        end
        function self = set.nComponents(self,val)
            if ~prtUtilIsPositiveInteger(val)
                error('prt:prtClassPlsda:nComponents','nComponents must be a positive integer');
            end
            self.nComponents = val;
        end
        
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,DataSet)
            
            X = DataSet.getObservations;
            
            Y = DataSet.getTargetsAsBinaryMatrix;
            
            maxComps = min(size(X));
            if self.nComponents > maxComps;
                self.nComponents = maxComps;
            end
            
            xMeans = mean(X,1);
            yMeans = mean(Y,1);
            X = bsxfun(@minus, X, xMeans);
            Y = bsxfun(@minus, Y, yMeans);
            switch self.trainingTechnique
                case 'simpls'
                    [self.Bpls, R, self.xVectors, self.yVectors, self.xScores, self.yScores] = prtUtilSimpls(X,Y,self.nComponents);
                    
                    
                case 'pls2'
                    [self.Bpls, W, P, Q, T, U, B] = prtUtilPls2(X,Y,self.nComponents);
                    
                    self.yVectors = Q;
                    self.xVectors = P;
                    self.yScores = T*B;
                    self.xScores = T;
                    
                otherwise
                    error('prtClassPlsda:trainingTechnique','Invalid trainingTechnique specified');
            end
            self.yMeansFactor = yMeans - xMeans*self.Bpls;
            
            ssT = diag(self.xScores'*self.yScores);
            ssT = ssT./sum(ssT(:));
            
            self.vipXY = sqrt(size(X,2)) * sum(bsxfun(@times, bsxfun(@rdivide,self.xVectors,sqrt(sum(self.xVectors.^2,2))).^2, ssT'),2);
            
            ssT = diag(self.yScores'*self.yScores);
            ssT = ssT./sum(ssT(:));
            
            self.vipY = sqrt(size(X,2)) * sum(bsxfun(@times, bsxfun(@rdivide,self.xVectors,sqrt(sum(self.xVectors.^2,2))).^2, ssT'),2);
        end
        
        function DataSet = runAction(self,DataSet)
            yOut = bsxfun(@plus,DataSet.getObservations*self.Bpls, self.yMeansFactor);
            DataSet = DataSet.setObservations(yOut);
        end
        
        function xOut = runActionFast(self,xIn,ds) %#ok<INUSD>
            xOut = bsxfun(@plus,xIn*self.Bpls, self.yMeansFactor);
        end
    end
    
    methods (Hidden)
        function str = exportSimpleText(self) %#ok<MANU>
            titleText = sprintf('%% prtClassPlsda\n');
            plsdBText = prtUtilMatrixToText(full(self.Bpls),'varName','plsdaWeights');
            plsdYText = prtUtilMatrixToText(full(self.yMeansFactor),'varName','yMeansFactor');
            str = sprintf('%s%s%s',titleText,plsdBText,plsdYText);
        end
    end
end
