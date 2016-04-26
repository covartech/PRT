classdef prtActionBig
    % prtActionBig is a mixin that can be inherited from by prtActions to
    % declare that they know how to deal with prtDataSetBig objects.
    % Most importantly they must have a trainActionBig method

% Copyright (c) 2014 CoVar Applied Technologies
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


    methods (Abstract,Access=protected,Hidden=true)
        self = trainActionBig(self,ds)
    end
    
    properties (Hidden = true, SetAccess=protected, GetAccess=protected) % These attributes are to match those of classTrain etc.
        classTrainBig = ''; % We could specify restrictions here
    end
        
    methods
        function self = trainBig(self, ds)
            % TRAINBIG  Train a prtAction object using training a
            % prtDataSet big data object
            %
            %
            %   self = self.trainBig(ds) trains the prtAction object using
            %   the prtDataSet ds.
            
            if ~isscalar(self)
                error('prt:prtAction:NonScalarAction','trainBig method expects scalar prtAction objects, prtAction provided was of size %s',mat2str(size(self)));
            end
            
            inputClassType = class(ds);
            if ~isempty(self.classTrainBig) && ~prtUtilDataSetClassCheck(inputClassType,self.classTrainBig)
                error('prt:prtAction:incompatible','%s.trainBig() requires datasets of type %s but the input is of type %s, which is not a subclass of %s', class(self), self.classTrainBig, inputClassType, self.classTrainBig);
            end
            
            ds = ds.summaryBuild();
            
            summary = summarize(ds);
            self = self.setDataSetSummary(summary); 
            if self.verboseStorage
                self = self.setDataSet(ds);
            end
            
            %             if self.isSupervised && ~ds.isLabeled
            %                 error('prt:prtAction:noLabels','%s is a supervised action and therefore requires that the training dataset is labeled',class(self));
            %             end
            
            self = preTrainBigProcessing(self,ds);

            self = trainActionBig(self, ds);
            self = setIsTrained(self, true);
            
            self = postTrainBigProcessing(self,ds);
        end
        
        function self = preTrainBigProcessing(self, ds) %#ok<INUSD>
            % preTrainBigProcessing - Processing done prior to trainAction()
            %   Called by trainBig(). Can be overloaded by prtActions to
            %   store specific information about the DataSet or Classifier
            %   prior to training.
            %
            %   ActionObj = preTrainBigProcessing(ActionObj,DataSet)
        end
        
        function self = postTrainBigProcessing(self, ds) %#ok<INUSD>
            % postTrainBigProcessing - Processing done after trainAction()
            %   Called by trainBig(). Can be overloaded by prtActions to
            %   store specific information about the DataSet or Classifier
            %   after training.
            %
            %   ActionObj = postTrainBigProcessing(ActionObj,DataSet)
        end
        
        function ds = runBig(self, ds)
            % RUNBIG  Run a prtAction object on a prtDataSet object.
            %
            %   dsOut = OBJ.run(ds) runs the prtAction object using
            %   the prtDataSet DataSet. OUTPUT will be a prtDataSet object.
           
            % RunBig is different in that runBig doesn't actually run the
            % actions. It instead adds the trained actions to the set of
            % actions contained in ds.action
            
            if isempty(ds.action)
                % You curently don't have an action
                ds.action = self;
            else
                ds.action = ds.action + self;
            end
            ds = ds.summaryClear;
        end
        
    end
    
    methods
        function self = set.classTrainBig(self,val)
            assert(ischar(val),'prt:prtAction:classTrainBig','classTrainBig must be a string.');
            self.classTrainBig = val;
        end
    end
    
end
