classdef prtFeatSelLlnn < prtFeatSel
    % prtFeatSelLLnn  Local Learning based feature selection
    %
    %   FEATSEL = prtFeatSelLlnn returns a local learning based feature selection
    %   object.
    %
    %    FEATSEL = prtFeatSelLlnn(PROPERTY1, VALUE1, ...) constructs a
    %    prttFeatSelExhaustive object FEATSEL with properties as specified by
    %    PROPERTY/VALUE pair
    %
    %    A prtFeatSelExhaustive object has the following properties:
    %
    %    selectedFeatures       - The indices of the features selected,
    %                             a read-only parameter, found by training.  
    %    verbosePlot            - Toggles plotting on/off during training
    %    nMaxIterations         - The maximum number of iterations
    %    normalizedWeightCutOff - The weight threshold for keeping a feature
    %
    %    The following features are settable, and are related to the
    %    training algorithm. Please see reference for further information.
    %
    %    kernelSigma
    %    sparsnessLambda
    %    vGradNMaxSteps
    %    vGradInitStepSize
    %    vGradChangeThreshold
    %    vGradNMaxStepSizeChanges
    %    weightChangeThreshold
    %
    %   Reference:
    %   http://www.computer.org/portal/web/csdl/doi/10.1109/TPAMI.2009.190
    %
    %   A prtFeatSelExhaustive object inherits the TRAIN and RUN methods
    %   from prtClass.
    %
    %   Example:
    %
    %   dataSet = prtDataGenSpiral;   % Create a 2 dimensional data set
    %   nNoiseFeatures = 100;      % Append 100 irrelevant features
    %   dataSet = prtDataSetClass(cat(2,dataSet.getObservations,randn([dataSet.nObservations, nNoiseFeatures])), dataSet.getTargets);
    %   featSel = prtFeatSelLlnn('verbosePlot',true);  % Create the feature
    %                                                  % selection object.
    %   featSel.nMaxIterations = 10;                   % Set the max # of
    %                                                  % iterations.
    %   featSel = featSel.train(dataSet);              % Train 
    %
    %   See Also:  prtFeatSelStatic, prtFeatSelSfs, prtFeatSelExhaustive

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
        % Required by prtAction
        name = 'Local Learning Nearest Neighbor'
        nameAbbreviation = 'LLNN'
    end
    
    properties
        
        kernelSigma = 1;
        sparsnessLambda = 2;
        vGradNMaxSteps = 100;
        vGradInitStepSize = 1;
        vGradChangeThreshold = 1e-4;
        vGradNMaxStepSizeChanges = 12;
        weightChangeThreshold = 0.01;
        nMaxIterations = 25;         % The maximum number of iterations
        normalizedWeightCutOff = 0.05;  % The weight threshold to include a feature.
        
        % Learned 
        weights = [] ;           % The weights of each feature
        selectedFeatures = [];   % The selected features
        
        verbosePlot = false;     % Toggles plotting on/off during training
    end
     
    methods
        
        % Constructor %%
        function Obj = prtFeatSelLlnn(varargin)
            
            % Allow for string, value pairs
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end   
    end
    
    methods (Access=protected,Hidden=true)
        
        % Train %%
        function Obj = trainAction(Obj,DS)
            
            % Remove stuff from data set, too many calls to getObservations
            X = DS.getObservations();
            Y = DS.getTargetsClassInd();
            
            vExpDistanceFunction = @(v,zBar)exp(-zBar*(v.^2));
            
            vFitnessFunction = @(v,cExpDistance)sum(log(1+cExpDistance)) + Obj.sparsnessLambda*sum(v.^2);
            
            w = ones(DS.nFeatures,1);
            wOld = w;
            wChanges = nan(Obj.nMaxIterations,1);
            for iter = 1:Obj.nMaxIterations
                
                % Find zBar
                % Eq: 3-5
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                cSigma = Obj.kernelSigma*sqrt(sum((w./max(w))>Obj.normalizedWeightCutOff)); % Modify kernel to the "dimensionality" imposed by w
                
                zBar = zeros(DS.nObservations, DS.nFeatures);
                for iSamp = 1:DS.nObservations
                    
                    % L1 Distance from this point in each dim
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
                        cStepSize = cStepSize / 2; % Lower the step size, we get here if 1) first iteration (we multiplied the step size by 2) or 2) step size was too big so we need to shrink it.
                        
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
                            % by 50%.
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
                
                cWChange = norm(abs(w-wOld));
                
                %%% Other ideas for exit criterion %%%
                % cWChange = norm(abs(w-wOld))/sqrt(length(w));
                % cWChange = mean(abs(w-wOld)./mean(cat(2,w,wOld),2)); % Average percent change
                % wNorm = w ./ max(w);
                % wOldNorm = wOld ./ max(wOld);
                % cWChange = mean(abs(wNorm-wOldNorm)./mean(cat(2,wNorm,wOldNorm),2)); % Normalized Average percent change
                % cWChange = mean(abs(wNorm-wOldNorm)); % Normalized Average change
                
                if Obj.verbosePlot
                    subplot(2,1,1)
                    stem(w./max(w));
                    title('Feature Importance','FontSize',14)
                    xlabel('Feature')
                    ylabel('Normalized Feature Weight');
                    xlim([1 length(w)]);
                    
                    subplot(2,1,2)
                    wChanges(iter) = cWChange;
                    plot(1:iter,wChanges(1:iter),'b-',1:iter,wChanges(1:iter),'rx')
                    title('Optimization Exit Criterion','FontSize',14)
                    xlabel('Iteration')
                    ylabel('Weight Change From Last Iteration')
                    xlim([0.5 iter+0.5]);
                    set(gca,'XTick',1:iter);
                    
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
        function DataSet = runAction(Obj,DataSet)
            DataSet = DataSet.retainFeatures(Obj.selectedFeatures);
        end       
    end 
end
