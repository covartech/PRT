classdef prtFeatSelLlnn < prtFeatSel
    % http://www.computer.org/portal/web/csdl/doi/10.1109/TPAMI.2009.190
    %
    
    % Example
    %{
    DS = prtDataSpiral;
    
    nNoiseFeatures = 1000;
    DS = prtDataSetClass(cat(2,DS.getObservations,randn([DS.nObservations, nNoiseFeatures])), DS.getTargets);
    
    A = prtFeatSelLlnn('verbosePlot',true);
    
    A = A.train(DS);
    %}
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'Local Learning Nearest Neighbor'
        nameAbbreviation = 'LLNN'
        isSupervised = true;
    end
    
    properties
        
        kernelSigma = 1;
        sparsnessLambda = 2;
        
        vGradNMaxSteps = 100;
        vGradInitStepSize = 1;
        vGradChangeThreshold = 1e-4;
        vGradNMaxStepSizeChanges = 12;
        
        nMaxIterations = 25;
        weightChangeThreshold = 0.01;
        
        normalizedWeightCutOff = 0.05;
        
        % Learned 
        weights = []
        selectedFeatures = [];
        
        verbosePlot = false;
    end
    
    
    methods
        
        % Constructor %%
        
        function Obj = prtFeatSelLlnn(varargin)
            % Allow for string, value pairs
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
    end
    
    methods (Access = protected)
        
        % Train %%
        
        function Obj = trainAction(Obj,DS)
            
            % Remove stuff from data set (too many calls to getObservations)
            X = DS.getObservations();
            Y = DS.getTargetsClassInd();
            
            vExpDistanceFunction = @(v,zBar)exp(-zBar*(v.^2));
            
            vFitnessFunction = @(v,cExpDistance)sum(log(1+cExpDistance)) + Obj.sparsnessLambda*sum(v.^2);
            
            w = ones(DS.nFeatures,1);
            wOld = w;
            for iter = 1:Obj.nMaxIterations
                
                % Find zBar
                % Eq: 3-5
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                cSigma = Obj.kernelSigma*sqrt(sum((w./max(w))>Obj.normalizedWeightCutOff)); % Modify kernel to the "dimensionality" imposed by w
                
                zBar = zeros(DS.nObservations, DS.nFeatures);
                for iSamp = 1:DS.nObservations
                    
                    % Distance from this point in each dim
                    cD = abs(bsxfun(@minus,X(iSamp,:),X));
                    cD(iSamp,:) = inf;
                    
                    % Label of this point
                    cY = Y(iSamp);
                    
                    % Kernel mapped distance to this point
                    cK = exp(-sum(bsxfun(@times,cD,w(:)'),2)/cSigma); % Hard coded L1 Distance
                    
                    % Calculate the prob of nearest miss and nearst hit
                    % Eqs: 4, 5
                    cKMiss = cK;
                    cKMiss(Y==cY) = 0; % Cant be a miss if you are the same type
                    cKMiss(iSamp) = 0; % Cant be your own miss
                    cKMiss = cKMiss./sum(cKMiss);
                    
                    cKHit = cK;
                    cKHit(Y~=cY) = 0; % Cant be a hit if you are a different type
                    cKHit(iSamp) = 0; % Cant be your own hit
                    cKHit = cKHit./sum(cKHit);
                    
                    % Eq: 3
                    cD(iSamp,:) = 0; % inf*0 = nan
                    zBar(iSamp,:) = sum(bsxfun(@times,cD, cKMiss),1) - sum(bsxfun(@times,cD, cKHit),1);
                    
                end
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                % Optimize v
                % Eqs: 9, 10
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                v = sqrt(w);
                
                cExpDistance = vExpDistanceFunction(v,zBar);
                vScore = vFitnessFunction(v,cExpDistance); % Eq: 9
                
                vScoreOld = vScore;
                for iStep = 1:Obj.vGradNMaxSteps
                    cStepSize = Obj.vGradInitStepSize*2; % we multiply by 2 since we divide by 2 at every iteration (even the first)
                    
                    % Transform cExpDistance into necessary term for the
                    % gradient, we use the same name... just because
                    cExpDistance = cExpDistance./(1 + cExpDistance);
                    cExpDistance(isnan(cExpDistance)) = 0; % inf/(inf + 1)
                    
                    % Eq: 10
                    cChange = Obj.sparsnessLambda*ones(size(w)) - sum(bsxfun(@times,cExpDistance, zBar),1)';
                    
                    for iStepSize = 1:Obj.vGradNMaxStepSizeChanges
                        cStepSize = cStepSize / 2; % Lower the step size, we get here if 1) first iteration (we multiplied the step size by 2 or 2) step size was too big so we need to shrink it.
                        
                        vNew = v - cStepSize*cChange.*v; % Eq: 10
                        
                        cExpDistance = vExpDistanceFunction(vNew,zBar);
                        
                        vNewScore = vFitnessFunction(vNew,cExpDistance);
                        
                        if vNewScore < vScore
                            vScore = vNewScore;
                            v = vNew;
                            % Note that cExpDistance will be reused but
                            % immediately over written with its alter ego
                            % this saves a little mem I guess
                            break
                        else
                            % We increased the fitness (bad) so the step
                            % size must be too big.
                            % Continue in the loop decrease the step size
                            % by 1/2.
                        end
                    end
                    
                    if abs(vScore-vScoreOld)/mean([vScore vScoreOld]) < Obj.vGradChangeThreshold
                        break
                    else
                        vScoreOld = vScore;
                    end
                end     
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                w = v.^2;
                
                %cWChange = norm(abs(w-wOld))/sqrt(length(w));
                cWChange = norm(abs(w-wOld));
                
                
                if Obj.verbosePlot
                    subplot(2,1,1)
                    stem(w./max(w));
                    title('Feature Importance Weight ')
                
                    subplot(2,1,2)
                    wChanges(iter) = cWChange;
                    plot(wChanges,'b-')
                    hold on
                    plot(wChanges,'rx')
                    hold off
                    title('Weight Change From Last Iteration')
                    
                    drawnow;
                end
                
                if cWChange < Obj.weightChangeThreshold
                    break
                end
                wOld =w;
                
            end

            Obj.weights = w;
            Obj.selectedFeatures = find(w > Obj.normalizedWeightCutOff);
        end
        
        
        
        % Run %
        
        function DataSet = runAction(Obj,DataSet) %%
            DataSet = DataSet.retainFeatures(Obj.selectedFeatures);
        end
        
        
    end
    
    
end
