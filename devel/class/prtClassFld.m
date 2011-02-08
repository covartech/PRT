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
 %    TestDataSet = prtDataGenUniModal;       % Create some test and
 %    TrainingDataSet = prtDataGenUniModal;   % training data
 %    classifier = prtClassFld;           % Create a classifier
 %    classifier = classifier.train(TrainingDataSet);    % Train
 %    classified = run(classifier, TestDataSet);         % Test
 %    subplot(2,1,1);
 %    classifier.plot;
 %    subplot(2,1,2);
 %    [pf,pd] = prtScoreRoc(classified,TestDataSet);
 %    h = plot(pf,pd,'linewidth',3);
 %    title('ROC'); xlabel('Pf'); ylabel('Pd');
 %  
 %   See also prtClass, prtClassLogisticDiscriminant, prtClassBagging,
 %   prtClassMap, prtClassCap, prtClassBinaryToMaryOneVsAll, prtClassDlrt,
 %   prtClassPlsda, prtClassKnn, prtClassRvm, prtClassGlrt,  prtClassSvm,
 %   prtClassTreeBaggingCap, prtClassKmsd, prtClassKnn

 

    properties (SetAccess=private)
        
        name = 'Fisher Linear Discriminant' % Fisher Linear Discriminant
        nameAbbreviation = 'FLD'            % FLD
        isNativeMary = false;  % False
    end
    
    properties (SetAccess = protected)
        % w is a DataSet.nDimensions x 1 vector of projection weights
        % learned during Fld.train(DataSet)
        
        w = []; % The vector of weights, learned during training
        
        % plotting options
        plotBasis = false; % Flag indicating whether or not to plot the basis
        plotProjections = false; % Flag indicating whether or not to plot the projections
    end
    
    methods
     
               % Allow for string, value pairs
        function Obj = prtClassFld(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.plotProjections(Obj,value)
            if islogical(value) || (isnumeric(value) && (value == 1 || value == 0))
                Obj.plotProjections = value;
            else
                error('prt:prtClassFld:plotProjections','plotProjections can only take true or false (boolean or 0/1) values; user speficied value %d',value);
            end
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            
            n = DataSet.nObservations;
            p = DataSet.nFeatures;
            
            if p > n
                warning('prt:prtClassFld:train:illconditioned','DataSet has n (%d) < p (%d); prtClassFld may not be stable',n,p);
            end
            
            dataH0 = DataSet.getObservationsByClassInd(1);
            dataH1 = DataSet.getObservationsByClassInd(2);
            
            M0 = mean(dataH0,1);
            M1 = mean(dataH1,1);
            
            s0 = cov(dataH0);
            s1 = cov(dataH1);
            
            Sw = s1 + s0;
            
            Obj.w = Sw\(M1-M0)'; %w = Sw^-1 * (M1-M0)'; % But better
            
            Obj.w = Obj.w./norm(Obj.w);
            
        end
        
        function DataSet = runAction(Obj,DataSet)
            DataSet = prtDataSetClass((Obj.w'*DataSet.getObservations()')');
        end
        
        function imageHandle = plotGriddedEvaledClassifier(Obj, DS, linGrid, gridSize, cMap)
            
            % Call the original plot function
            imageHandle = plotGriddedEvaledClassifier@prtClass(Obj, DS, linGrid, gridSize, cMap);
            
            W = Obj.w;
            limits = axis;
            nDims = length(W);
            
            if Obj.plotBasis
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

            if Obj.plotProjections && ~isempty(Obj.DataSet)
                OutputDataSet = run(Obj, Obj.DataSet);
                hold on;
                switch nDims
                    case 2
                        for i = 1:double(Obj.plotProjections):Obj.DataSet.nObservations
                            cX = Obj.DataSet.getObservations(i,:);
                            cYout = OutputDataSet.getObservations(i,:);
                            plot([cX(1),cYout*W(1)],[cX(2),cYout*W(2)],'k');
                        end
                    case 3
                        for i = 1:double(Obj.plotProjections):Obj.DataSet.nObservations
                            cX = Obj.DataSet.getObservations(i,:);
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