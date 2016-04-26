classdef prtActionWrapperMil < prtAction







    properties (SetAccess = private)
        % Descriptive name of prtAction object.
        name = 'MIL Wrapper';
        
        % Shortened name for the prtAction object.
        nameAbbreviation = 'MILWrap';
    end
    
    properties (SetAccess = protected)
        % Specifies if the prtAction requires a labeled dataSet
        isSupervised
        
        % Indicates whether or not cross-validation is a valid operation
        isCrossValidateValid
    end
    
    properties (Dependent)
        theAction; % a prtActionObject
    end
    properties (SetAccess = private,Hidden)
        theAction_ = prtPreProcPca;
    end
    
    methods
        function self = prtActionWrapperMil(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
            self.isSupervised = self.theAction.isSupervised;
            self.isCrossValidateValid = self.theAction.isCrossValidateValid;
        end
        
        function val = get.theAction(self)
            val = self.theAction_;
        end
        
        function self = set.theAction(self,action)
            
            if isa(action,'prtAction');
                self.theAction_ = action;
                
                self.isSupervised = self.theAction.isSupervised;
                self.isCrossValidateValid = self.theAction.isCrossValidateValid;
                
            else
                error('prt:prtActionWrapperMil','theAction must be a subclass of prtAction, provided action was a %s',class(action));
            end
        end
    end
    
    methods (Access = protected, Hidden = true)
        % prtAction.trainAction() - Primary method for training a prtAction
        %   self = prtAction.trainAction(self,DataSet)
        function self = trainAction(self, dsMil)
            
            ds = prtDataSetClass(dsMil.expandedData,dsMil.expandedTargets);
            self.theAction = self.theAction.train(ds);
            
        end
        % prtAction.runAction() - Primary method for evaluating a prtAction
        %   DataSet = runAction(self, DataSet)
        function dsMil = runAction(self, dsMil)
            
            ds = prtDataSetClass(dsMil.expandedData,dsMil.expandedTargets);
            dsOut = self.theAction.run(ds);
            dsMil = dsMil.fromPrtDataSetClassData(dsOut);
            
        end
    end
end
