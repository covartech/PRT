classdef prtFeatSelStatic < prtFeatSel %
    % prtFeatSelStatic  Static feature selection object.
    %
    %  FEATSEL = prtFeatSelStatic creates a static feature selection
    %  object. 
    %  
    %  FEATSEL = prtFeatSelStatic('selectedFeatures', FEATURES) creates a
    %  static feature selection object with the selectedFeatures parameter
    %  set to FEATURES.
    % 
    %  A static feature selction object selects the features specified by
    %  the selectedFeatures parameter.
    %
    %   Example:
    %   
    %   dataSet = prtDataGenIris;            % Load a data set with 4 features
    %   StaticFeatSel = prtFeatSelStatic; % Create a static feature
    %                                     % selection object.
    %   StaticFeatSel.selectedFeatures = [1 3];   % Choose the first and
    %                                             % third feature
    %   % Training is not necessary for a static feature selection object,
    %   % the following command has no effect.
    %   StaticFeatSel = StaticFeatSel.train(dataSet);  
    %   
    %   dataSetReduced = StaticFeatSel.run(dataSet);   %Run the feature
    %                                                  %selection
    %   explore(dataSetReduced);

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
        
        name = 'Static Feature Selection'   % Static Feature Selection
        nameAbbreviation = 'StaticFeatSel' % StaticFeatSel
    end 
    
    properties 

        selectedFeatures = nan   % The selected features
    end
    
    methods 
        function Obj = prtFeatSelStatic(varargin) 
            %
            
            %pt, 2011.06.09 - why was this false?
            %Obj.isCrossValidateValid = false;
            Obj.isCrossValidateValid = true;
            
            Obj.isTrained = true;
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.selectedFeatures(Obj,val)
            if isnan(val)
                return
            end
            assert(isvector(val) && prtUtilIsPositiveInteger(val),'prt:prtFeatSelStatic:selectedFeatures','selectedFeatures must be vector of positive integers');
            
            uVals = unique(val);
            if numel(val) ~= numel(uVals)
                warning('prt:prtFeatSelStatic:selectedFeatures','selectedFeatures was set with repeated values. The redundant values have been ignored.')
            end
            
            Obj.selectedFeatures = uVals(:)';
        end
    end
    methods (Access=protected,Hidden=true)
        
        function Obj = trainAction(Obj,twiddle)
            if isnan(Obj.selectedFeatures)
                error('Manually set selectedFeatures field of prtFeatSelStatic to succesfully train and run');
            end
        end
        
        function DataSet = runAction(Obj,DataSet)
            if isnan(Obj.selectedFeatures)
                error('prt:prtFeatSelStatic','Manually set selectedFeatures field of prtFeatSelStatic to succesfully train and run');
            end
            DataSet = DataSet.retainFeatures(Obj.selectedFeatures);
		end
		
		function xOut = runActionFast(Obj,xIn,ds)
			xOut = xIn(:,Obj.selectedFeatures);
		end
    end
end
