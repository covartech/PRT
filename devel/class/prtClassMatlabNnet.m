classdef prtClassMatlabNnet < prtClass
    % prtClassMatlabNnet  Support vector machine classifier using the
    % MATLAB neural network toolbox (requires NNET toolbox)
    %
    %   CLASSIFIER = prtClassMatlabNnet returns a neural network classifier
    %   using the MATLAB NNET toolbox (additonal product, not included)
    %
    %  A prtClassMatlabNnet object inherits all properties from the
    %  abstract class prtClass. In addition is has the following
    %  properties; complete documentation for these properties can be found
    %  in the help for the newpr.m function in the MATLAB NNET toolbox.
    %
    %   Si, TFi, BTF, BLF, PF, IPF, OPF, DDF
    %
    % % Example usage:
    %
    %   TestDataSet = prtDataGenBimodal;       % Create some test and
    %   TrainingDataSet = prtDataGenBimodal;   % training data
    %   classifier = prtClassMatlabNnet;           % Create a classifier
    %   classifier = classifier.train(TrainingDataSet);    % Train
    %   classified = run(classifier, TestDataSet);         % Test
    %   subplot(2,1,1);
    %   classifier.plot;
    %   subplot(2,1,2);
    %   [pf,pd] = prtScoreRoc(classified,TestDataSet);
    %   h = plot(pf,pd,'linewidth',3);
    %   title('ROC'); xlabel('Pf'); ylabel('Pd');
    %   
    
    properties (SetAccess=private)
        name = 'MATLAB Neural Network' % Fisher Linear Discriminant
        nameAbbreviation = 'MLNN'            % FLD
        isNativeMary = true;  % False
    end
    
    properties 
        % w is a DataSet.nDimensions x 1 vector of projection weights
        % learned during Fld.train(DataSet)
        nnet 
        
    end
    properties 
        Si = 20;  %number of layers in hidden element; or, number of elements per hidden layer (vector)
        %these are all bizzare; see the help for newpr for help with these
        TFi = [];
        BTF = [];
        BLF = [];
        PF = [];
        IPF = [];
        OPF = [];
        DDF = [];
    end

    methods 
               % Allow for string, value pairs
        function Obj = prtClassMatlabNnet(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.Si(Obj,val)
            assert(isvector(val) && isnumeric(val) && all(val == round(val)) && all(val > 0),'prt:prtClassMatlabNnet:Si','Si must be a numeric vector of int-valued doubles greater than 0, but value provided was %s',mat2str(val));
            Obj.Si = val;
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            
            paramNames = {'Obj.TFi','Obj.BTF','Obj.BLF','Obj.PF','Obj.IPF','Obj.OPF','Obj.DDF'};
            cellParams = {Obj.TFi,Obj.BTF,Obj.BLF,Obj.PF,Obj.IPF,Obj.OPF,Obj.DDF};
            nParams = 0;
            
            for i = length(cellParams):-1:1
                if ~isempty(cellParams{i}) && any(cellfun(@isempty,cellParams(1:i-1)))
                    val = cellfun(@isempty,cellParams(1:i-1));
                    error('prt:prtClassMatlabNnet','Parameter %s is set, but required parameter %s is not set',paramNames{i},paramNames{val});
                end
                if ~isempty(cellParams{i})
                    nParams = i;
                end
            end
            Obj.nnet = newpr(DataSet.getObservations',DataSet.getTargetsAsBinaryMatrix',Obj.Si,cellParams{1:nParams});
            
            Obj.nnet = train(Obj.nnet,DataSet.getObservations',DataSet.getTargetsAsBinaryMatrix');
        end
        
        function DataSet = runAction(Obj,DataSet)
            yOut = sim(Obj.nnet,DataSet.getObservations');
            DataSet = prtDataSetClass(yOut');
        end
        
    end
end