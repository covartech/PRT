classdef prtClassMatlabNnet < prtClass
    % xxx NEED HELP xxx
    %DS = prtDataGenBimodal;
    %Nn = prtClassMatlabNnet; 
    %Nn = Nn.train(DS);
    %Nn.plot; 
    %yOut = Nn.run(prtDataGenBimodal);
    
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