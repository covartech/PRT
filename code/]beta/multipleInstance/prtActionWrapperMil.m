classdef prtActionWrapperMil < prtAction

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
