classdef prtClassNnet < prtClass
    %prtClassNnet 3-Layer Neural Network Classifier
    %
    %    nnet = prtClassNnet; returns a neural network classifier with 3
    %    layers (input, hidden, output).
    %
    %    nnet = prtClassNnet(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassNnet object with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClassNnet object inherits all properties from the abstract class
    %    prtClass. In addition is has the following properties:
    %
    %    nHiddenUnits (30)  - Number of hidden units to use
    %    minIters  (10000)  - Minimum number of iterations to run before
    %                         checking for convergence
    %    maxIters (100000)  - Maximum number of iterations to run
    %    
    %    relativeErrorChangeThreshold (1e-4) - Relative change in error to
    %                       determine convergence
    %
    %    initStdev (0.1)   - Standard deviation to use for intial weights
    %    stepSize  (0.1)   - Learning stepsize
    %    fwdFn (sigmoid)   - Activation function for nodes; see prtUtilNnetBackProp
    %    fwdFnDeriv        - Activation function derivative defaults to
    %                         derivative of sigmoid; see prtUtilNnetBackProp
    %
    %    plotOnIter (0)    - Scalar integer specifying how often to
    %                         visualize results and convergence
    % Example:
    %    dsTrain = prtDataGenXor;
    %    dsTest = prtDataGenXor;
    %    nnet = prtClassNnet('nHiddenUnits',10,'plotOnIter',1000,'relativeErrorChangeThreshold',1e-4);
    %    nnet = nnet.train(dsTrain);
    %    yOut = nnet.run(dsTest);
    %    close all;
    %    prtScoreRoc(yOut);
    %
    % Notes:
    %   Currently, prtClassNnet implements a simple back-propagation
    %   algorithm as described in Duda, Hart, Stork, "Pattern
    %   Classification", 2nd Ed., Pages 291-293.  More complicated
    %   algorithms are also possible.  
    %
    %   To do: add stochastic backprop; fields: stochasticLearning (true),
    %   nBoostrapSamples (100), and momentum; then for every iteration,
    %   train on a bootstrap sample, and evaluate on the whole data set.
    %
    %   The current code is only suitable for binary classification
    %   problems. M-ary modifications are possible and on our to-do-list.
    %    
    
    properties (SetAccess=private)
        name = 'NNET'
        nameAbbreviation = 'NNET' 
        isNativeMary = false; 
    end
    
    properties (SetAccess = protected)
        
    end
    
    properties
        nHiddenUnits = 30;
        
        minIters = 10000;
        maxIters = 100000;
        relativeErrorChangeThreshold = 1e-4;
        
        initStdev = 0.1;
        stepSize = 0.1;
        fwdFn = [];
        fwdFnDeriv = [];
        
        plotOnIter = false;
        
        initWeights = true;
        weightCell = {};
    end
    
    methods
     
               % Allow for string, value pairs
        function self = prtClassNnet(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,dataSet)
            
            nFeaturesOrig = dataSet.nFeatures;
            %Add bias:
            dataSet.X = cat(2,ones(dataSet.nObservations,1),dataSet.X);
            if self.initWeights
                wCell = {randn(dataSet.nFeatures,self.nHiddenUnits).*self.initStdev,randn(self.nHiddenUnits+1,1).*self.initStdev};
            else
                %Use the weights from last-time. Note: this will error if
                %you're not careful
                wCell = self.weightCell;
                if isempty(wCell)
                    error('prt:prtClassNnet:initWeights','nnet.initWeights is false, but previous weightCell is empty.');
                end
            end
            
            meanError = nan(1,self.maxIters);
            converged = false;
            
            for iter = 1:self.maxIters;
                
                [wCell,out] = prtUtilNnetBackProp(dataSet,wCell,self.stepSize,self.fwdFn,self.fwdFnDeriv);
                meanError(iter) = mean((out - dataSet.targets).^2);
                
                % Force there to be at least minIters, then check
                % convergence
                if iter > self.minIters
                    percentChange = abs((meanError(iter)-meanError(iter-1))./(meanError(iter-1)));
                    converged = percentChange < self.relativeErrorChangeThreshold;
                end
                if converged
                    break;
                end
                
                
                % Plotting:
                if ~mod(iter,self.plotOnIter);
                    if nFeaturesOrig < 4
                        subplot(2,2,1);
                        self.isTrained = true;
                        self.weightCell = wCell;
                        plot(self);
                        title('NNET Contour');
                        subplot(2,2,2);
                        h = plot(1:length(out),out,1:length(out),dataSet.targets);
                        set(h,'linewidth',3);
                        title('Targets (Green) and Target Estimates (Blue)');
                        subplot(2,1,2);
                        plot(log10(meanError));
                        title(sprintf('Log-10 Average Error vs. Training Epoch'));
                        drawnow;
                    else
                        subplot(2,1,2);
                        h = plot(1:length(out),dataSet.targets,'g',1:length(out),out,'b');
                        set(h(1),'linewidth',3);
                        title('Targets (Green) and Target Estimates (Blue)');
                        subplot(2,1,1);
                        plot(log10(meanError));
                        title(sprintf('Log-10 Average Error vs. Training Epoch'));
                        drawnow;
                    end
                end
            end
            self.weightCell = wCell;
        end
        
        function dataSet = runAction(self,dataSet)
            % dataSet = runAction(self,dataSet)
            
            %Add bias:
            dataSet.X = cat(2,ones(dataSet.nObservations,1),dataSet.X);
            [~,out] = prtUtilNnetBackProp(dataSet,self.weightCell,self.stepSize,self.fwdFn,self.fwdFnDeriv);
            dataSet.X = out;
        end
        
    end
    
end
