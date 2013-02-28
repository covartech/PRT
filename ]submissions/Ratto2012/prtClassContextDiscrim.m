classdef prtClassContextDiscrim < prtClass
    % prtClassContextDiscrim Discriminative context-dependent
    % classification
    %
    %   CLASSIFIER = prtClassContextDiscrim returns a discriminative
    %   context-dependent classifier
    %
    %   CLASSIFIER = prtClassContextDiscrim(PROPERTY1, VALUE1, ...) constructs a
    %   prtClassContextDiscrim object CLASSIFIER with properties as specified by
    %   PROPERTY/VALUE pairs.
    %
    %   A prtClassContextDiscrim object inherits all properties from the abstract class
    %   prtClass. In addition is has the following properties:
    %
    %
    %   A prtClassContextDiscrim also has the following read-only properties:
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


    properties (SetAccess=private)
        name = 'Context-Dependent Classification (Discriminative)'
        nameAbbreviation = 'CDC';
        isNativeMary = false;
    end
    
    properties
        maxIterations = 500;       % The maximum number of iterations
        convergenceThreshold = 1e-4;  % Learning tolerance;
        pruningThreshold = 0.01; % Pruning threshold
        verbose = true;
        plotDiagnostics = false;
        pruneClusters = true;
        nMaxComponents = 20;
        
        prior = struct();
        clusterRVs = struct();
        weights = [];
    end
    
    
    methods
        
        function Obj = prtClassContextDiscrim(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
            priorStruct.tau1 = 1;
            priorStruct.tau2 = 1;
            priorStruct.gamma = 1;
            priorStruct.a = 1;
            priorStruct.b = 1;
            priorStruct.u = 1;
            Obj.prior = priorStruct;
        end
        
        function Obj = set.maxIterations(Obj,val)
            if ~prtUtilIsPositiveInteger(val)
                error('prt:prtClassContextDiscrim:maxIterations','maxIterations must be a positive integer');
            end
            Obj.maxIterations = val;
        end
        
        function Obj = set.convergenceThreshold(Obj,val)
            if ~prtUtilIsPositiveScalar(val)
                error('prt:prtClassContextDiscrim:convergenceThreshold','convergenceThredhold must be a positive scalar');
            end
            Obj.convergenceThreshold = val;
        end
        
        function Obj = set.pruningThreshold(Obj,val)
            if ~prtUtilIsPositiveScalar(val)
                error('prt:prtClassContextDiscrim:pruningThreshold','pruningThreshold must be a positive scalar');
            end
            Obj.pruningThreshold = val;
        end
        
        function Obj = set.verbose(Obj,val)
            assert(isscalar(val) && (islogical(val) || prtUtilIsPositiveInteger(val)),'prt:prtClassContextDiscrim:verbose','verbose must be a logical value or a positive integer');
            Obj.verbosePlot = val;
        end
        
        function Obj = set.plotDiagnostics(Obj,val)
            assert(isscalar(val) && (islogical(val) || prtUtilIsPositiveInteger(val)),'prt:prtClassContextDiscrim:plotDiagnostics','plotDiagnostics must be a logical value or a positive integer');
            Obj.plotDiagnostics = val;
        end
        
        function Obj = set.pruneClusters(Obj,val)
            assert(isscalar(val) && (islogical(val) || prtUtilIsPositiveInteger(val)),'prt:prtClassContextDiscrim:pruneClusters','pruneClusters must be a logical value or a positive integer');
            Obj.verbosePlot = val;
        end
        
        function Obj = set.nMaxComponents(Obj,val)
            if ~prtUtilIsPositiveInteger(val)
                error('prt:prtClassContextDiscrim:nMaxComponents','nMaxComponents must be a positive integer');
            end
            Obj.nMaxComponents = val;
        end
        
        function Obj = set.prior(Obj,val)
            assert(isstruct(val),'prt:prtClassContextDiscrim:prior','prior must be a struct with fields tau1, tau2, gamma, a, b, u');
            Obj.prior = val;
        end
        %
        %         function Obj = set.params(Obj,val)
        %             assert(isstruct(val),'prt:prtClassContextDiscrim:params','params must be a struct');
        %             params = val;
        %         end
        
        function Obj = set.clusterRVs(Obj,val)
            Obj.clusterRVs = val;
        end
        
        function Obj = set.weights(Obj,val)
            Obj.weights = val;
        end
        
        function varargout = plot(Obj)
            %             % plot - Plot output confidence of the prtClassContextDiscrim object
            %             %
            %             %   CLASS.plot plots the output confidence of the prtClassContextDiscrim
            %             %   object. The dimensionality of the dataset must be 3 or
            %             %   less, and verboseStorage must be true.
            %
            %             HandleStructure = plot@prtClass(Obj);
            %
            %             holdState = get(gca,'nextPlot');
            %             hold on;
            %             Obj.sparseKernels.plot;
            %             set(gca, 'nextPlot', holdState);
            %
            %             varargout = {};
            %             if nargout > 0
            %                 varargout = {HandleStructure};
            %             end
        end
        
    end
    
    
    methods (Access=protected, Hidden = true)
        
        %% Training
        function Obj = trainAction(Obj,dataSetContext)
            
            xContext = dataSetContext.getContextFeats;
            Pcontext = size(xContext,2);
            
            xClass = dataSetContext.getTargetFeats;
            xClass = [ones(size(xClass,1),1),xClass];
            Pclass = size(xClass,2);
            
            y = dataSetContext.Y;
            
            maxIterations = Obj.maxIterations;
            threshold = Obj.convergenceThreshold;
            verbose = Obj.verbose;
            
            N = Obj.nMaxComponents;
            n = length(y);
            
            % Variational Bayes
            converged = false;
            iteration = 1;
            while ~converged
                if iteration == 1
                    Obj.prior.nu = size(xContext,2);
                    Obj.prior.m = mean(xContext);
                    Obj.prior.B = size(xContext,2)*eye(size(xContext,2));
                    Obj.prior.Sigma = repmat(eye(size(xClass,2)),[1,1,Obj.nMaxComponents]);
                    
                    Obj.prior.stickHyperparams = [Obj.prior.tau1,Obj.prior.tau2];
                    
                    kmeansOptions = statset('kmeans');
                    kmeansOptions.MaXIter = 1000;
                    [idX,means,~,D] = kmeans(xContext,N,'EmptyAction','drop','replicates',10,'options',kmeansOptions);
                    D(D==0) = eps;
                    
                    dsClass = prtDataSetClass(xClass(:,2:end),y);
                    LogDisc = prtClassLogisticDiscriminant;
                    LogDisc = LogDisc.train(dsClass);
                    Obj.prior.mW = repmat(LogDisc.w',Obj.nMaxComponents,1);
                    
                    params = Obj.prior;
                    params.a = repmat(Obj.prior.a,size(xClass,2),N);
                    params.b = repmat(Obj.prior.b,size(xClass,2),N);
                    params.rho = 1./D;
                    params.rho = bsxfun(@rdivide,params.rho,sum(params.rho,2));
                end
                
                % update parameters
                params = Obj.conjugateUpdate(dataSetContext,params);
                
                % calc NFE
                [L(iteration),EqLogLike(iteration),KLD(iteration)] = Obj.calcLowerBound(dataSetContext,params);
                if iteration > 1
                    Lpct = 100*(L(iteration-1) - L(iteration))/L(iteration-1);
                else
                    Lpct = nan;
                end
                
                % plot diagnostics
                if Obj.plotDiagnostics
                    Obj.plot;
                end
                
                % Progress mssages, check convergence
                if Obj.verbose
                    fprintf(['Iteration #',num2str(iteration),': Negative Free Energy = ',num2str(L(iteration)),' (',num2str(Lpct),'%%)\n'])
                end
                if iteration > 1
                    if abs(Lpct) <= Obj.convergenceThreshold;
                        converged = true;
                        if Obj.verbose
                            fprintf('NFE Converged! Congratulation.\n')
                        end
                    elseif iteration == Obj.maxIterations;
                        converged = true;
                        if Obj.verbose
                            fprintf('Max iterations reached. Get out of here!\n')
                        end
                    end
                end
                
                iteration = iteration + 1;
                
                if Obj.plotDiagnostics
                    Nh = sum(params.rho);
                    keepInds = find(Nh./n >= Obj.pruningThreshold);
                    muWkeep = params.mW(keepInds,:);
                    
                    figure(666),set(gcf,'OuterPosition',[74,210,1228,561])
                    subplot(2,2,1),imagesc(params.rho),title('Component Responsibilities'),xlabel('Component #'),ylabel('Sample #')
                    subplot(2,2,2),plot(L,'LineWidth',2),grid on,title('Negative Free Energy'),xlabel('Iteration'),ylabel('NFE')
                    subplot(2,1,2)
                    stem(muWkeep','LineWidth',2)
                    %                     colors = prtClassColors(length(keepInds));
                    %                     symbols = dprtClassSymbols(length(keepInds));
                    %                     for i = 1:length(keepInds)
                    %                         stem(muWkeep(i,:),'Color',colors(i,:),'Marker',symbols(i),'MarkerFaceColor',colors(i,:),'MarkerEdgeColor',colors(i,:)),hold on
                    %                         lineNames{i} = ['Comp. ',num2str(keepInds(i))];
                    %                     end
                    grid on
                    title('Discriminant Weights')
                    %legend(lineNames)
                    xlabel('Feature'),ylabel('Weight'),hold off
                    drawnow
                end
                
            end
            
            %% Prune frivolous clusters
            if Obj.pruneClusters
                Nh = sum(params.rho);
                keepInds = find(Nh./n >= Obj.pruningThreshold);
            else
                keepInds = 1:size(params.rho,2);
            end
            
            params.rho = params.rho(:,keepInds);
            params.nu = params.nu(keepInds);
            params.u = params.u(keepInds);
            params.mMu = params.mMu(keepInds,:);
            params.B = params.B(:,:,keepInds);
            params.Sigma = params.Sigma(:,:,keepInds);
            params.mW = params.mW(keepInds,:);
            
            %% Create Student-t variables for each cluster
            nComponents = numel(keepInds);
            for t = 1:nComponents;
                nu = params.nu(t);
                u = params.u(t);
                B = params.B(:,:,t);
                mMu = params.mMu(t,:);
                
                dof = nu + 1 - Pcontext;
                covariance = ((u + 1)/(u*dof))*inv(B);
                
                Obj.clusterRVs(t).mu = mMu;
                Obj.clusterRVs(t).covariance = covariance;
                Obj.clusterRVs(t).dof = dof;
                Obj.weights(t,:) = params.mW(t,:);
            end
            Obj.isTrained = true;
            
        end
        
        
        function dataSetOut = runAction(Obj,dataSetContext)
            
            xContext = dataSetContext.getContextFeats;
            xClass = dataSetContext.getTargetFeats;
            xClass = [ones(size(xClass,1),1),xClass];
            
            y = dataSetContext.Y;
            N = length(Obj.clusterRVs);
            
            w = Obj.weights;
            for h = 1:N
                dsClass(:,h) = w(h,:)*xClass';
                dsComponent(:,h) = prtRvUtilStudentTPdf(xContext,Obj.clusterRVs(h).mu,Obj.clusterRVs(h).covariance,Obj.clusterRVs(h).dof);
            end
            if any(sum(dsComponent,2)==0)
                outlierInds = find(sum(dsComponent,2)==0);
                dsComponent(outlierInds,:) = repmat(ones(N,1)/N,length(outlierInds),1);
            end
            
            dsClass = (1 + exp(-dsClass)).^(-1);
            dsComponent = bsxfun(@rdivide,dsComponent,sum(dsComponent,2));
            
            yOut = sum(dsClass.*dsComponent,2);
            dataSetOut1 = prtDataSetClass(yOut,y);
            dataSetOut2 = prtDataSetClass;
            dataSetOut = prtDataSetClassContext(dataSetOut1,dataSetOut2);
        end
    end
    
    methods (Access=protected, Hidden = true)
        function params = conjugateUpdate(Obj,dataSetContext,params)
            
            xContext = dataSetContext.getContextFeats;
            Pcontext = size(xContext,2);
            xClass = dataSetContext.getTargetFeats;
            xClass = [ones(size(xClass,1),1),xClass];
            Pclass = size(xClass,2);
            
            maxIterations = Obj.maxIterations;
            threshold = Obj.convergenceThreshold;
            verbose = Obj.verbose;
            N = Obj.nMaxComponents;
            Y = dataSetContext.Y;
            n = length(Y);
            
            %% count memberships
            rho = params.rho;
            rhoCount = sum(params.rho);
            
            %% Update stick-breaking
            [rhoCountSorted,sortIndsRho] = sort(rhoCount,'descend');
            [~,unsortIndsRho] = sort(sortIndsRho,'ascend');
            
            [stickSizes,stickParams,stickHyperparams,piTildeSorted] = Obj.stickBreakingUpdateDCDFS(rhoCountSorted,params);
            piTilde = piTildeSorted(unsortIndsRho);
            piTilde(piTilde == 0) = eps;
            
            %% Update Gaussian components
            m0 = Obj.prior.m;
            nu0 = Obj.prior.nu;
            u0 = Obj.prior.u;
            B0 = Obj.prior.B;
            mW = params.mW;
            Sigma = params.Sigma;
            a = params.a;
            b = params.b;
            
            u = zeros(1,N);
            mMu = zeros(N,Pcontext);
            M = zeros(Pcontext,Pcontext,N);
            nu = zeros(1,N);
            B = zeros(Pcontext,Pcontext,N);
            ElnDetLambda = zeros(1,N);
            EwSq = zeros(Pclass,Pclass,N);
            xi = zeros(n,Pclass);
            lambda = zeros(n,Pclass);
            
            ExMinusMuTimesLambda = zeros(n,N);
            for h = 1:N
                xSum = sum(xContext.*repmat(rho(:,h),1,Pcontext));
                
                u(h) = u0 + rhoCount(h);
                mMu(h,:) = (xSum + u0*m0)/u(h);
                M(:,:,h) = mMu(h,:)'*mMu(h,:);
                C = bsxfun(@times,xContext,rho(:,h))'*xContext;
                M0 = m0'*m0;
                
                nu(h) = nu0 + rhoCount(h);
                B(:,:,h) = (C - u(h)*M(:,:,h) + u0*M0 + B0^-1)^-1;
                
                ElnDetLambda(h) = sum(psi((nu(h)-(1:Pcontext)+1)/2)) + Pcontext*log(2) + prtUtilLogDet(B(:,:,h));
                xMinusMMu = bsxfun(@minus,xContext,mMu(h,:));
                for i = 1:n
                    ExMinusMuTimesLambda(i,h) = xMinusMMu(i,:)*nu(h)*B(:,:,h)*xMinusMMu(i,:)' + Pcontext/u(h);
                end
                
                % Update classifier parameters
                EwSq(:,:,h) = Sigma(:,:,h) + mW(h,:)'*mW(h,:);
                xi(:,h) = sqrt(diag(xClass*EwSq(:,:,h)*xClass'));
                
                lambda(:,h) = (1./(4*xi(:,h))).*tanh(xi(:,h)./2);
                
                A = diag(a(:,h)./b(:,h));
                Sigma(:,:,h) = inv(A + 2*bsxfun(@times,xClass,rho(:,h))'*diag(lambda(:,h))*xClass);
                
                mW(h,:) = .5*Sigma(:,:,h)*sum(bsxfun(@times,xClass,rho(:,h).*(2*Y-1)))';
                EwSq(:,:,h) = Sigma(:,:,h) + mW(h,:)'*mW(h,:);
                
                % Update classifier hyperparameters
                a(:,h) = repmat(Obj.prior.a,Pclass,1) + .5;
                b(:,h) = repmat(Obj.prior.b,Pclass,1) + .5*(diag(EwSq(:,:,h)));
            end
            
            % Update responsibilities
            rhoLog = nan(n,N);
            sig = (1 + exp(-xi)).^-1;
            for h = 1:N
                for i = 1:n
                    rhoLog(i,h) = log(sig(i,h)) + .5*(2*Y(i)-1).*(xClass(i,:)*mW(h,:)') - .5*xi(i,h) - lambda(i,h).*(xClass(i,:)*EwSq(:,:,h)*xClass(i,:)' - xi(i,h).^2) + .5*ElnDetLambda(h) - .5*ExMinusMuTimesLambda(i,h) + log(piTilde(h));
                end
            end
            params.rhoLog = rhoLog;
            rho = exp(bsxfun(@minus,rhoLog,prtUtilSumExp(rhoLog')'));
            
            % Save output structure
            params.stickSizes = stickSizes;
            params.stickParams = stickParams;
            params.stickHyperparams = stickHyperparams;
            params.rho = rho;
            params.nu = nu;
            params.u = u;
            params.mMu = mMu;
            params.B = B;
            params.C = C;
            params.ElnDetLambda = ElnDetLambda;
            params.ExMinusMuTimesLanbda = ExMinusMuTimesLambda;
            params.Sigma = Sigma;
            params.mW = mW;
            params.EwSq = EwSq;
            params.xi = xi;
            params.lambda = lambda;
            params.a = a;
            params.b = b;
            params.piTilde = piTilde;
            
        end
        
        function [stickSizes,stickParams,newHyperparams,p] = stickBreakingUpdateDCDFS(Obj,m,params)
            
            oldHyperparams = params.stickHyperparams;
            priorHyperparams = Obj.prior.stickHyperparams;
            N = length(m);
            alpha = oldHyperparams(:,1)./oldHyperparams(:,2); % Expected value of SB sparnseness parameter (Gamma distribution) Is this right???
            
            stickParams = zeros(N,2);
            stickSizes = zeros(N,2);
            expectedStickLengths = zeros(N,1);
            p = zeros(1,N);
            for h = 1:N
                stickParams(h,1) = 1 + m(h);
                stickParams(h,2) = alpha + sum(m(h+1:N));
                
                stickSizes(h,1) = psi(stickParams(h,1)) - psi(sum(stickParams(h,:))); % <ln V_i>
                stickSizes(h,2) = psi(stickParams(h,2)) - psi(sum(stickParams(h,:))); % <ln (1-V_i)>
                
                if h ==1
                    p(h) = stickSizes(h,1);
                elseif h == N
                    p(h) = sum(stickSizes(1:h-1,2));
                else
                    p(h) = stickSizes(h,1) +  sum(stickSizes(1:h-1,2));
                end
                if isnan(p(h))
                    p(h) = 0;
                else
                    p(h) = exp(p(h));
                end
            end
            if any(p == 0)
                p(p==0) = eps;
            end
            newHyperparams(:,1) = priorHyperparams(:,1) + N - 1;
            newHyperparams(:,2) = priorHyperparams(:,2) - sum(stickSizes(1:N-1,2));
            
        end
        
        function [L,EqLogLike,KLD] = calcLowerBound(Obj,dataSetContext,params)
            
            xContext = dataSetContext.getContextFeats;
            Pcontext = size(xContext,2);
            xClass = dataSetContext.getTargetFeats;
            xClass = [ones(size(xClass,1),1),xClass];
            Pclass = size(xClass,2);
            
            N = Obj.nMaxComponents;
            Y = dataSetContext.Y;
            n = length(Y);
            
            rho = params.rho;
            rhoCount = sum(rho);
            [NhSorted,sortIndsRho] = sort(rhoCount,'descend');
            rhoSorted = rho(:,sortIndsRho);
            
            %% Load Parameters
            stickSizes = params.stickSizes;
            stickParams = params.stickParams;
            stickHyperparams = params.stickHyperparams;
            rho = params.rho;
            nu = params.nu;
            u = params.u;
            mMu = params.mMu;
            B = params.B;
            ElnDetLambda = params.ElnDetLambda;
            ExMinusMuTimesLambda = params.ExMinusMuTimesLanbda;
            Sigma = params.Sigma;
            mW = params.mW;
            EwSq = params.EwSq;
            xi = params.xi;
            lambda = params.lambda;
            a = params.a;
            b = params.b;
            
            tau10 = Obj.prior.tau1;
            tau20 = Obj.prior.tau2;
            nu0 = Obj.prior.nu;
            B0 = Obj.prior.B;
            m0 = Obj.prior.m;
            u0 = Obj.prior.u;
            a0 = Obj.prior.a;
            b0 = Obj.prior.b;
            
            %% Calculate Expected LogLikelihood
            EqLogLikeRVMmat = zeros(1,N);
            %EqLogLikeGMMmat = zeros(1,N);
            EqLogLikeGMM = 0;
            sig = (1 + exp(-xi)).^-1;
            for h = 1:N
                EqLogLikeRVMmat(h) = sum(rho(:,h).*(log(sig(:,h)) + .5*(2*Y-1).*(xClass*mW(h,:)') - .5*xi(:,h) - lambda(:,h).*(diag(xClass*EwSq(:,:,h)*xClass') - xi(:,h).^2)));
            end
            EqLogLikeRVM = sum(EqLogLikeRVMmat);
            EqLogLikeGMM = sum(sum(rho.*bsxfun(@plus,(-Pcontext*log(2*pi) - .5*ExMinusMuTimesLambda),.5*ElnDetLambda)));
            EqLogLike = EqLogLikeRVM + EqLogLikeGMM;
            %% KLD of indicators
            ElogPZgivenVh = zeros(n,N);
            EqLogV = psi(stickParams(:,1)) - psi(sum(stickParams,2));
            EqLog1minusV = psi(stickParams(:,2)) - psi(sum(stickParams,2));
            for h = 1:N
                ElogPZgivenVh(:,h) = sum(rhoSorted(:,h+1:N),2)*EqLog1minusV(h) + rhoSorted(:,h)*EqLogV(h);
            end
            ElogPZgivenV = sum(ElogPZgivenVh(:));
            rho(rho==0) = eps;
            ElogQZh = rho.*log(rho);
            ElogQZ = sum(ElogQZh(:));
            KLDz = ElogQZ - ElogPZgivenV;
            
            %% Calculate KLDs for variational parameters
            KLDvH = zeros(1,N);
            KLDmuLambdaH = zeros(1,N);
            for h = 1:N
                KLDvH(h) = prtRvUtilDirichletKld(stickParams(h,:),[1,tau10/tau20]);
                KLDmuLambdaH(h) = prtRvUtilMvnWishartKld(1/u(h),nu(h),mMu(h,:),inv(B(:,:,h)),1/u0,nu0,m0,inv(B0));
            end
            KLDv = sum(KLDvH);
            KLDmuLambda = sum(KLDmuLambdaH);
            
            %% Calculate KLDs of hyperparameters
            KLDbeta = prtRvUtilGammaKld(stickHyperparams(1),stickHyperparams(2),tau10,tau20);
            
            %% KLD of RVMs
            KLDrvm = 0;
            for h = 1:N
                KLDrvm = KLDrvm + .5*Pclass + .5*prtUtilLogDet(Sigma(:,:,h));
                for p = 1:Pclass
                    KLDrvm = KLDrvm -.5*a(p,h)/b(p,h)*(Sigma(p,p,h)+mW(h,p)^2+2*b0)-(a0+.5)*log(b(p,h))+a0*log(b0)+a(p,h)-gammaln(a0)+gammaln(a(p,h));
                end
            end
            
            %% Calc NFE
            L = EqLogLikeRVM + KLDrvm + EqLogLikeGMM - KLDz - KLDv - KLDmuLambda - KLDbeta;
            
            KLD.z = KLDz;
            KLD.v = KLDvH;
            KLD.muLambda = KLDmuLambdaH;
            KLD.beta = KLDbeta;
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
                    %warning('prt:prtClassContextDiscrim:illConditionedG','RVM initial G matrix ill-conditioned; regularizing diagonal of G to resolve; this can be modified by changing kernel parameters\n');
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
