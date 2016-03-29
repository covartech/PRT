classdef prtPreProcDataFromObservationInfo < prtPreProc
    % prtPreProcCatFeaturesFromObservationInfo
    %   Generate a prtDataSetClass from another data set using the
    %   specified field(s) of observationInfo.
    %
    %       fields {} - A cell array of fields of the observationInfo
    %       structure to use for generating new features.
    %
    %       catFeaturs (false) - Whether to append the new features at the
    %       end (right-most side) of the input data set (true), or replace
    %       all the features in the original data set with the new features
    %       (false).
    %
    %   

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



    properties (SetAccess=private)
        name = 'FromObsInfo'  % Zero Mean Unit Variance
        nameAbbreviation = 'FromObsInfo'  % ZMUV
    end
    
    properties
        fields = {};
        catFeatures = false;
    end
    
    methods
        function Obj = prtPreProcDataFromObservationInfo(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected,Hidden=true)
        
        function self = trainAction(self,ds)
            % nothing to do
        end
        
        
        function ds = runAction(self,ds)
            % Remove the means and normalize the variance
            X = [];
            if ~isa(self.fields,'cell')
                self.fields = {self.fields};
            end
            for i = 1:length(self.fields);
                X = cat(2,X,cat(1,ds.observationInfo.(self.fields{i})));
            end
            if self.catFeatures
                ds = catFeatures(ds,X); %#ok<CPROP>
            else
                ds.X = X;
                ds.featureNames = self.fields;
            end
        end
        
    end
    
    methods (Hidden)
        
        function str = exportSimpleText(self) %#ok<MANU>
            str = '';
            error('Not implemented');
            %             titleText = sprintf('%% prtPreProcZmuv\n');
            %             zmuvMeansText = prtUtilMatrixToText(self.means,'varName','means');
            %             zmuvVarsText = prtUtilMatrixToText(self.stds,'varName','std');
            %             str = sprintf('%s%s%s',titleText,zmuvMeansText,zmuvVarsText);
        end
    end
end
