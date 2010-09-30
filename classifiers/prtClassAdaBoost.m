classdef prtClassAdaBoost < prtClass
               

    properties (SetAccess=private)
        % Required by prtAction
        name = 'AdaBoost'   % Maximum a Posteriori
        nameAbbreviation = 'AdaBoost'        % MAP
        isSupervised = true;            % True
        
        isNativeMary = false;           % True
    end
    
    properties
        baseClassifier = prtClassFLD;
        nBoosts = 30;
        classifierArray = [];
        alpha = [];
    end
    
    methods
        % Constructor
        function Obj = prtClassAdaBoost(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        % Set function
        function Obj = set.baseClassifier(Obj,val)
            if(~ isa(val, 'prtClass'))
                error('prtClassAdaBoost:baseClassifier','baseClassifier parameter must be a prtClass');
            else
                Obj.baseClassifier = val;
            end
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,dataSet)
            
            d = ones(dataSet.nObservations,1)./dataSet.nObservations;

            for t = 1:Obj.nBoosts
                if t == 1
                    dataSetBootstrap = dataSet;
                else
                    dataSetBootstrap = dataSet.bootstrap(dataSet.nObservations,d);
                end
                
                Obj.classifierArray{t} = train(Obj.baseClassifier + prtDecisionBinaryMinPe,dataSetBootstrap);
                yOut = run(Obj.classifierArray{t},dataSet);

                y = double(dataSet.getTargets);
                y(y == 0) = -1;
                h = double(yOut.getObservations);
                h(h == 0) = -1;
                pe = sum(double(y~=h).*d);
                
                Obj.alpha(t) = 1/2*log((1-pe)/pe);
                d = d.*exp(-Obj.alpha(t).*y.*h);
                d = d./sum(d);
                if sum(d) == 0
                    return;
                end
                
                if pe > .5
                    return;
                end
            end
        end
        
        function DataSetOut = runAction(Obj,DataSet)
            DataSetOut = prtDataSetClass(zeros(DataSet.nObservations,1));
            
            for t = 1:length(Obj.classifierArray)
                theObs = run(Obj.classifierArray{t},DataSet);
                currObs = Obj.alpha(t)*theObs.getObservations;
                DataSetOut = DataSetOut.setObservations(DataSetOut.getObservations + currObs);
            end

        end
        
    end
    
end