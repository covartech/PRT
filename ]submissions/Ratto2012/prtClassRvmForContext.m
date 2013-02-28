classdef prtClassRvmForContext < prtClass
    % prtClassRvmForContext  Relevance vector machine classifier for
    % context-dependent applications

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
        name = 'Relevance Vector Machine'  % Relevance Vector Machine
        nameAbbreviation = 'RVM'           % RVM
        isNativeMary = false;  % False
        useForContext = true;
    end
    
    properties
        kernels = prtKernelDc & prtKernelDirect;  % The kernels to be used
        
        verboseText = true;  % Whether or not to display text during training
        verbosePlot = false;  % Whether or not to plot during training
        
        maxIterations = 1000;       % The maximum number of iterations
        convergenceThreshold = .01;  % Learning tolerance; 
        
        prior = struct('a',1e-6,'b',1e-6','c',1e-6,'d',1e-6);
        weights = [];
      
    end
    

    
    
    methods
        
        function Obj = prtClassRvm(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.maxIterations(Obj,val)
            if ~prtUtilIsPositiveInteger(val)
                error('prt:prtClassRvm:maxIterations','maxIterations must be a positive integer');
            end
            Obj.learningMaxIterations = val;
        end
        
        function Obj = set.convergenceThreshold(Obj,val)
            if ~prtUtilIsPositiveScalar(val)
                error('prt:prtClassRvm:convergenceThreshold','convergenceThreshold must be a positive scalar');
            end
            Obj.learningConvergedTolerance = val;
        end
        
        
        function Obj = set.kernels(Obj,val)
            assert(numel(val)==1 &&  isa(val,'prtKernel'),'prt:prtClassRvm:kernels','kernels must be a prtKernel');
            
            Obj.kernels = val;
        end
        
        function Obj = set.verbosePlot(Obj,val)
            assert(isscalar(val) && (islogical(val) || prtUtilIsPositiveInteger(val)),'prt:prtClassRvm:verbosePlot','verbosePlot must be a logical value or a positive integer');
            Obj.verbosePlot = val;
        end
        
        function Obj = set.verboseText(Obj,val)
            assert(isscalar(val) && islogical(val),'prt:prtClassRvm:verboseText','verboseText must be a logical value, but value provided is a %s',class(val));
            Obj.verboseText = val;
        end
        
        function varargout = plot(Obj)
            % plot - Plot output confidence of the prtClassRvm object
            %
            %   CLASS.plot plots the output confidence of the prtClassRvm
            %   object. The dimensionality of the dataset must be 3 or
            %   less, and verboseStorage must be true.
            
            HandleStructure = plot@prtClass(Obj);
            
            holdState = get(gca,'nextPlot');
            hold on;
            Obj.sparseKernels.plot;
            set(gca, 'nextPlot', holdState);
            
            varargout = {};
            if nargout > 0
                varargout = {HandleStructure};
            end
        end
        
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            %Note: do not assume that getTargets returns a double array or
            %values "0" and "1", instead use this:
            Y = Obj.getMinusOneOneTargets(DataSet);
            Y(Y==-1) = 0;
            
            Obj.kernels = Obj.kernels.train(DataSet);
            GRAMM = Obj.kernels.run_OutputDoubleArray(DataSet);
            
            prior = Obj.prior;
            prior.A = diag(repmat(prior.a,1,size(GRAMM,2)));
            prior.S = eye(size(GRAMM,2));
            prior.m = zeros(size(GRAMM,2),1);
            
            if isfield(DataSet.observationInfo,'contextPosterior')
                for i = 1:DataSet.nObservations
                    pCgivenX(i,:) = DataSet.observationInfo(i).contextPosterior;
                end
            else
                pCgivenX = ones(DataSet.nObservations,1);
            end
            pCgivenXmat = repmat(pCgivenX',size(GRAMM,2),1);

            % Run VB
            iter = 0;
            finished = false;
            while ~finished
                iter = iter + 1;
                
                phi = GRAMM';
                N = size(phi,2);              % Number of samples
                D = size(phi,1);              % Dimensionality
                t = Y;
                    
                if iter == 1 %% Initialization
                    a = repmat(prior.a,1,D);
                    b = repmat(prior.b,1,D);
                    S = prior.S;
                    m = prior.m;
                end
                
                xi = sqrt(diag(phi'*(S+m*m')*phi));
                lambda = (1./(4*xi)).*tanh(xi./2);
                
                A = diag(a./b);
                S = inv(A + 2*pCgivenXmat.*phi*diag(lambda)*phi');
                
                m = .5*S*sum(pCgivenXmat.*repmat(2*t'-1,D,1).*phi,2);
                
                a = repmat(prior.a,D,1) + .5;
                b = diag(diag(repmat(prior.b,1,D)) + .5*(diag(m.^2) + diag(diag(S))));
                
                % Calculate Negative Free Energy (Convergence Criterion)
                sig = (1 + exp(-xi)).^-1;
                logF = sum(pCgivenX.*(log(sig) + .5*(2*t-1).*(phi'*m) - .5*xi - lambda.*((diag(phi'*(S+m*m')*phi)) - xi.^2)));
                
                KLDalpha = 0;
                for d = 1:D
                    KLDalpha = KLDalpha + prtRvUtilGammaKld(a(d),b(d),prior.a,prior.b);
                end
                if det(S) ~= 0
                    KLDw  = .5*(-sum(log(diag(A))) -log(det(S)) + trace(A.*S)' + sum(diag(A).*m.^2) - N);
                else
                    KLDw  = .5*(-sum(log(diag(A))) -log(realmin) + trace(A.*S)' + sum(diag(A).*m.^2) - N);
                end
                
                NFE(iter) = logF - KLDalpha - KLDw;
                if Obj.verbosePlot
                    figure(666),plot(NFE)
                end
                
                if iter > 1
                    if NFE(iter) > 0
                        Lpct = 100*(NFE(iter) - NFE(iter-1))/NFE(iter-1);
                    else
                        Lpct = 100*(NFE(iter-1) - NFE(iter))/NFE(iter-1);
                    end
                else
                    Lpct = nan;
                end
                
                %% Progress mssages, check convergence
                if Obj.verboseText
                    fprintf(['Iteration #',num2str(iter),': Negative Free Energy = ',num2str(NFE(iter)),' (',num2str(Lpct),'%%)\n'])
                end
                
                if iter > 1
                    if abs(Lpct) <= Obj.convergenceThreshold;
                        finished = true;
                        Obj.weights = m;
                        if Obj.verboseText
                            fprintf('NFE Converged! Congratulation.\n')
                        end
                    elseif iter == Obj.maxIterations;
                        finished = true;
                        Obj.weights = m;
                        if Obj.verboseText
                            fprintf('Max iterations reached. Get out of here!\n')
                        end
                    elseif isinf(Lpct)
                        finished = true;
                        Obj.weights = m;
                        if Obj.verboseText
                            fprintf('Inf found...exiting\n')
                        end
                    end
                end
            end
            
        end
        
        function DataSetOut = runAction(Obj,DataSet)
            
            GRAMM = Obj.kernels.run_OutputDoubleArray(DataSet);
            x = DataSet.X;
            w = Obj.weights;
            for n = 1:size(x,1);
                y(n,:) = w'*GRAMM(n,:)';
            end
            Yout = (1 + exp(-y)).^(-1);
            

            DataSetOut = prtDataSetClass(Yout,DataSet.Y);
            if isa(DataSet,'prtDataSetClassContext')
                DataSetOut = prtDataSetClassContext(DataSetOut,prtDataSetClass);
            end
        end
    end

    methods (Access=protected, Hidden = true)
 
        function y = getMinusOneOneTargets(Obj, DataSet) %#ok<MANU>
            yMat = double(DataSet.getTargetsAsBinaryMatrix());
            y = nan(size(yMat,1),1);
            y(yMat(:,1) == 1) = -1;
            y(yMat(:,2) == 1) = 1;
        end
        
        function G = regularizeGramInnerProduct(Obj, gram)
            nBasis = size(gram,2);
            
            sigmaSquared = 1e-6;
            
            %Check to make sure the problem is well-posed.  This can be fixed either
            %with changes to kernels, or by regularization
            G = gram'*gram;
            while rcond(G) < 1e-6
                if sigmaSquared == eps && Obj.verboseText
                    %warning('prt:prtClassRvm:illConditionedG','RVM initial G matrix ill-conditioned; regularizing diagonal of G to resolve; this can be modified by changing kernel parameters\n');
                    fprintf('\n\tRegularizing Gram matrix...\n');
                end
                G = (sigmaSquared*eye(nBasis) + gram'*gram);
                sigmaSquared = sigmaSquared*2;
            end
            
        end
        
        function verboseIterationPlot(Obj,DataSet,relevantIndices)
            DsSummary = DataSet.summarize;
            
            [linGrid, gridSize,xx,yy] = prtPlotUtilGenerateGrid(DsSummary.lowerBounds, DsSummary.upperBounds, Obj.plotOptions); %#ok<ASGLU>
            
            localKernels = Obj.kernels.train(DataSet);
            cKernels = localKernels.retainKernelDimensions(relevantIndices);
            cPhiDataSet = cKernels.run(prtDataSetClass([xx(:),yy(:)]));
            cPhi = cPhiDataSet.getObservations;
            
            confMap = reshape(prtRvUtilNormCdf(cPhi*Obj.beta(relevantIndices)),gridSize);
            imagesc(xx(1,:),yy(:,1),confMap,[0,1])
            colormap(Obj.plotOptions.twoClassColorMapFunction());
            axis xy
            hold on
            plot(DataSet);
            cKernels.plot();
            hold off;
            
            set(gcf,'color',[1 1 1]);
            drawnow;
        end
    end
end
