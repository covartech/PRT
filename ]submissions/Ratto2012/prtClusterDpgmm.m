classdef prtClusterDpgmm < prtCluster
    % prtClusterDpgmm   Dirichlet process Gaussian mixture model clustering object
    %
    %    CLUSTER = prtClusterGmm returns a GMM clustering object.
    %
    %    CLUSTER = prtClusterGmm(PROPERTY1, VALUE1, ...) constructs a
    %    prtClassFld object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtClusterGmm object inherits all properties from the abstract
    %    class prtCluster. In addition is has the following properties:
    %
    %    nClusters          - Number of cluster centers to learn
    %
    %    A prtClusterGmm clustering algorithm trains a prtRvGmm random
    %    variable on training data, and at run time, the clustering
    %    algorithm outputs the posterior probability of any particular
    %    point being drawn from one of the nClusters Guassian components.
    %
    %    A prtClusterGmm object inherits the TRAIN, RUN, CROSSVALIDATE and
    %    KFOLDS methods from prtAction. It also inherits the PLOT method from
    %    prtCluster.
    %
    %   Example:
    %
    %   ds = prtDataGenUnimodal         % Load a data set
    %   clusterAlgo = prtClusterGmm;    % Create a clustering object
    %   clusterAlgo.nClusters = 2;      % Set the number of clusters
    %
    %   % Set the internal decision rule to be MAP. Not required for
    %   % clustering, but necessary to plot the results.
    %   clusterAlgo.internalDecider = prtDecisionMap;
    %
    %   clusterAlgo = clusterAlgo.train(ds);  % Train
    %   plot(clusterAlgo);                    % Plot the trained object
    %
    %   See Also: prtCluster, prtClusterKmeans

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
        name = 'DPGMM Clustering' % GMM Clustering
        nameAbbreviation = 'DPGMMCluster' % GMMCluster
    end
    
    properties
        nClusters = 20; % The number of clusters
        maxIterations = 100;
        pruningThreshold = 0.05;
        convergenceThreshold = 1e-3;
        verboseText = true;
        plotDiagnostics = true;
        pruneClusters = true;
        prior = struct('s1',1,'s2',1,'lambda',1,'beta',1);
    end
    
    properties (SetAccess = protected)
        clusterParams = struct('mu',[],'covariance',[],'dof',[]);
    end
    
    methods
        
        function Obj = set.nClusters(Obj,value)
            if ~prtUtilIsPositiveScalarInteger(value)
                error('prt:prtClusterGmm:nClusters','value (%s) must be a positive scalar integer',mat2str(value));
            end
            Obj.nClusters = value;
        end
        
        % Allow for string, value pairs
        % Allow for string, value pairs
        function Obj = prtClusterDpgmm(varargin)
            
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            
            X = DataSet.X;
            N = DataSet.nObservations;
            d = size(X,2);
            
            Obj.prior.rho = mean(X);
            Obj.prior.Phi = d*eye(d);
            Obj.prior.nu = d;
            prior = Obj.prior;
            
            maxIterations = Obj.maxIterations;
            plotDiagnostics = Obj.plotDiagnostics;
            threshold = Obj.convergenceThreshold;
            verbose = Obj.verboseText;
            T = Obj.nClusters;
            
            
            
            %% Run VB 'EM' Algorithm
            converged = false;
            iteration = 1;
            while ~converged
                if iteration == 1
                    s1 = prior.s1;
                    s2 = prior.s2;
                    kmeansOptions = statset('kmeans');
                    kmeansOptions.MaXIter = 1000;
                    [counts.idX,means,~,D] = kmeans(X,T,'EmptyAction','drop','replicates',10,'options',kmeansOptions,'maxiter',1000);
                    D(D==0) = eps;
                    phi = 1./D;
                    phi = bsxfun(@rdivide,phi,sum(phi,2));
                end
                phiCount = sum(phi);
                if any(any(isnan(phiCount)))
                    keyboard
                end                
                % Sort sticks
                [phiCountSorted,sortIndsPhi] = sort(phiCount,'descend');
                [~,unsortIndsPhi] = sort(sortIndsPhi,'ascend');
                
                % Update stick-breaking              
                alpha = s1./s2;      
                stickParams = zeros(T,2);
                stickSizes = zeros(T,2);

               piTildeSorted = zeros(1,T);
                for i = 1:T
                    stickParams(i,1) = 1 + phiCountSorted(i);
                    stickParams(i,2) = alpha + sum(phiCountSorted(i+1:T));
                    
                    stickSizes(i,1) = psi(stickParams(i,1)) - psi(sum(stickParams(i,:))); % <ln V_i>
                    stickSizes(i,2) = psi(stickParams(i,2)) - psi(sum(stickParams(i,:))); % <ln (1-V_i)>
                    
                    if i ==1
                        piTildeSorted(i) = stickSizes(i,1);
                    elseif i == T
                        piTildeSorted(i) = sum(stickSizes(1:i-1,2));
                    else
                        piTildeSorted(i) = stickSizes(i,1) +  sum(stickSizes(1:i-1,2));
                    end
                    piTildeSorted(i) = exp(piTildeSorted(i));
                end
                if any(piTildeSorted == 0)
                    piTildeSorted(piTildeSorted==0) = eps;
                end
                s1 = prior.s1 + T - 1;
                s2 = prior.s2 - sum(stickSizes(1:T-1,2));
                piTilde = piTildeSorted(unsortIndsPhi);
                piTilde(piTilde == 0) = eps;
                
                % Update mixture components
                for t = 1:T
                    Nbar = phiCount(t);
                    rho0 = prior.rho;
                    nu0 = prior.nu;
                    beta0 = prior.beta;
                    Phi0 = prior.Phi;
                    
                    if Nbar == 0
                        muBar = rho0;
                    else
                        muBar = 1/Nbar*sum(X.*repmat(phi(:,t),1,d));
                    end
                    
                    SigmaBar(:,:,t) = zeros(d);
                    xMinusMuBar = bsxfun(@minus,X,muBar);
                    xMinusMuBarTrans = xMinusMuBar';
                    for n = 1:N
                        C = xMinusMuBarTrans(:,n)*xMinusMuBar(n,:);
                        SigmaBar(:,:,t) = SigmaBar(:,:,t) + (1./Nbar)*phi(n,t)*C;
                    end
                    
                    beta(t) = Nbar + beta0;
                    nu(t) = Nbar + nu0;
                    rho(t,:) = (Nbar*muBar + beta0*rho0)/(Nbar + beta0);
                    Phi(:,:,t) = Nbar*SigmaBar(:,:,t) + (Nbar*beta0*(muBar-rho0)'*(muBar-rho0)/(Nbar + beta0)) + Phi0;
                    
                    logPiTilde = log(piTilde(t));
                    dimInds = 1:d;
                    goodNus = (nu(t) + 1 - dimInds) > 0;
                    psiTerm = zeros(d,1);
                    psiTerm(goodNus) = psi((nu(t) + 1 - dimInds(goodNus))/2);
                    logGammaTilde = sum(psiTerm) - prtUtilLogDet(Phi(:,:,t)) + d*log(2); % Is there a sign typo in Bishop 10.65?
                    GammaBar = nu(t)*inv(Phi(:,:,t));
                    if isnan(rcond(Phi(:,:,t)))
                        error('Bad covariance...exiting.\n')
                    end
                    xMinusMean = bsxfun(@minus,X,rho(t,:));
                    xMinusMeanTrans = xMinusMean';
                    expTerm = zeros(N,1);
                    for n = 1:N
                        expTerm(n,:) = .5*xMinusMean(n,:)*GammaBar*xMinusMeanTrans(:,n);
                    end
                    
                    phiLog(:,t) = logPiTilde + .5*logGammaTilde - expTerm - .5*d/beta(t);
                    %phiLog(isinf(phiLog(:,t)),t) = 1;
                end
                
                phi = exp(bsxfun(@minus,phiLog,prtUtilSumExp(phiLog')'));
                if any(any(isnan(phi)))
                    keyboard
                end
                [~,phiSortInds] = sort(sum(phi),'descend');
                phiSorted = phi(:,phiSortInds);
                
                % Calc NFE
                gamma1 = stickParams(:,1);
                gamma2 = stickParams(:,2);
                
                EqLogV = stickSizes(:,1);
                EqLog1minusV = stickSizes(:,2);
                traceTerm = zeros(1,T);
                newLogGammaTilde = zeros(1,T);
                dimInds = 1:d;
                for t = 1:T
                    goodNus = (nu(t) + 1 - (1:d)) > 0;
                    psiTerm = zeros(d,1);
                    psiTerm(goodNus) = psi((nu(t) + 1 - dimInds(goodNus))/2);
                    GammaBar(:,:,t) = nu(t)*inv(Phi(:,:,t));
                    newLogGammaTilde(t) = sum(psiTerm) - prtUtilLogDet(Phi(:,:,t)) + d*log(2);
                    traceTerm(t) = trace(GammaBar(:,:,t)*SigmaBar(:,:,t));
                end
                ElogPXgivenZ  = sum(Nbar/2.*(-d*log(2*pi) + newLogGammaTilde - traceTerm - d./beta));
                
                ElogPZgivenVt = zeros(N,T);
                EqLogV = psi(gamma1) - psi(gamma1 + gamma2);
                EqLog1minusV = psi(gamma2) - psi(gamma1 + gamma2);
                for t = 1:T
                    for n = 1:N
                        ElogPZgivenVt(n,t) = sum(phiSorted(n,t+1:T))*EqLog1minusV(t) + phiSorted(n,t)*EqLogV(t);
                    end
                end
                ElogPZgivenV = sum(ElogPZgivenVt(:));
                
                ElogQZt = phi.*log(phi);
                ElogQZt(phi==0) = 0;
                ElogQZ = sum(ElogQZt(:));
                
                KLDvT = zeros(1,T);
                KLDrhoGammaT = zeros(1,T);
                for t = 1:T
                    KLDvT(t) = prtRvUtilDirichletKld([gamma1(t),gamma2(t)],[1,prior.s1/prior.s2]);
                    KLDrhoGammaT(t) = prtRvUtilMvnWishartKld(1/beta(t),nu(t),rho(t,:),Phi(:,:,t),1/beta0,nu0,rho0,Phi0);
                end
                KLDv = sum(KLDvT);
                KLDrhoGamma = sum(KLDrhoGammaT);
                
                KLDalphaT = zeros(1,T);
                for t = 1:T-1
                    KLDalphaT(t) = prtRvUtilGammaKld(s1,s2,prior.s1,prior.s2);
                end
                KLDalpha = sum(KLDalphaT);
                
                NFE(iteration) = ElogPXgivenZ + ElogPZgivenV - ElogQZ - KLDv - KLDrhoGamma - KLDalpha;
              
                if iteration > 1
                    Lpct = 100*(NFE(iteration-1) - NFE(iteration))/NFE(iteration-1);
                else
                    Lpct = nan;
                end
                
                if plotDiagnostics
                    verboseIterationPlot(Obj,DataSet,phi,rho,Phi,nu,beta,piTilde,NFE)
                end
                
                %% Progress mssages, check convergence
                if verbose
                    fprintf(['Iteration #',num2str(iteration),': Negative Free Energy = ',num2str(NFE(iteration)),' (',num2str(Lpct),'%%)\n'])
                end
                
                if iteration > 1
                    if abs(Lpct) <= threshold;
                        converged = true;
                        if verbose
                            fprintf('NFE Converged! Congratulation.')
                        end
                    elseif iteration == maxIterations;
                        converged = true;
                        if verbose
                            fprintf('Max iterations reached. Get out of here!\n')
                        end
                    end
                end
                
                iteration = iteration + 1;
            end
            
            % Prune frivolous clusters
            if Obj.pruneClusters
                Nbar = sum(phi);
                N = size(phi,1);
                keepInds = find(Nbar./N >= Obj.pruningThreshold);
                Obj.nClusters = length(keepInds);
            else
                keepInds = 1:T;
                Obj.nClusters = T;
            end
            nu = nu(keepInds);
            beta = beta(keepInds);
            Phi = Phi(:,:,keepInds);
            rho = rho(keepInds,:);
            
            % Create Student-t variables for each cluster
            for t = 1:Obj.nClusters;
                Obj.clusterParams.dof(t) = nu(t) + 1 - size(X,2);
                Obj.clusterParams.covariance(:,:,t) = ((beta(t) + 1)/(beta(t)*Obj.clusterParams.dof(t)))*Phi(:,:,t);
                Obj.clusterParams.mu(t,:) = rho(t,:);
            end
        end
        
        
        function DataSet = runAction(Obj,DataSet)
            x = DataSet.X;
            Yout = zeros(size(x,1),Obj.nClusters);
            for t = 1:Obj.nClusters
                Yout(:,t) = prtRvUtilStudentTPdf(x,Obj.clusterParams.mu(t,:),Obj.clusterParams.covariance(:,:,t),Obj.clusterParams.dof(t));
            end
            Yout = bsxfun(@rdivide,Yout,sum(Yout,2));
            
            DataSet = prtDataSetClass(Yout,DataSet.Y);
        end
        
        function verboseIterationPlot(Obj,DataSet,phi,rho,Phi,nu,beta,piTilde,NFE)
            T = Obj.nClusters;
            x = DataSet.X;
            N = size(x,1);
            d = size(x,2);
            
            logPiTilde = log(piTilde);
            
            rho0 = Obj.prior.rho;
            nu0 = Obj.prior.nu;
            beta0 = Obj.prior.beta;
            Phi0 = Obj.prior.Phi;
            
            if d <= 2
                % Evaluation Grid
                nXY = 50;
                xTest = linspace(min(x(:,1)),max(x(:,1)),nXY);
                yTest = linspace(min(x(:,2)),max(x(:,2)),nXY);
                if d == 3
                    zTest = linspace(min(x(:,3)),max(x(:,3)),nXY);
                    [xx,yy,zz] = meshgrid(xTest,yTest,zTest);
                    grid = [xx(:),yy(:),zz(:)];
                else
                    [xx,yy] = meshgrid(xTest,yTest);
                    grid = [xx(:),yy(:)];
                end
                Ngrid = size(grid,1);
                
                omega = nu + 1 - d;
                Lambda = zeros(size(Phi));
                likelihood = zeros(Ngrid,T);
                predictive = zeros(Ngrid,1);
                for t = 1:T
                    Lambda(:,:,t) = ((beta(t) + 1)/(beta(t)*omega(t)))*squeeze(Phi(:,:,t)); % Component covariance
                    likelihood(:,t) = prtRvUtilStudentTPdf(grid,rho(t,:),Lambda(:,:,t),omega(t));
                    predictive = predictive + exp(logPiTilde(t))*likelihood(:,t);
                end
                predictiveOut = reshape(predictive,[nXY,nXY]);
            end
            
            
            figure(666)
            pos = [134 177 1102 588];
            set(gcf,'Position',pos)
            if d <= 2
                subplot(2,2,2),imagesc(xx(1,:),yy(:,1),log(predictiveOut)),axis xy,title('Predictive Density')
                subplot(2,2,1),plot(DataSet),title('Training Data')
                subplot(2,2,3),imagesc(phi,[0,1]),title('Responsibilities')
                subplot(2,2,4),plot(NFE),title('Negative Free Energy')
            else
                subplot(2,1,1),imagesc(phi,[0,1]),title('Responsibilities')
                subplot(2,1,2),plot(NFE),title('Negative Free Energy')
            end
            pause(0.0005)
        end
    end
end
