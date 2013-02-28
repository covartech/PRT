classdef prtPreProcHistEqKde < prtPreProc
    % prtPreProcHistEqKde   Histogram equalization processing
    %
    %   HISTEQ = prtPreProcHistEqKde creates a histogram equalization pre
    %   processing object. A prtPreProcHistEqKde object processes the input
    %   data so that the distribution of each feature is approximately
    %   uniform in [0,1]. preProcHistEqKde uses a smoothed density estimate
    %   to approximate the necessary statistics for histogram equalization.
    % 
    %   prtPreProcHistEqKde has the following properties:
    %
    %   prtRvKdeObj - A prtRvKde object that is use to approximate the
    %                 density of the input data.
    %
    %   A prtPreProcHistEqKde object also inherits all properties and
    %   functions from the prtAction class
    %
    %   Example:
    %
    %   dataSet = prtDataGenIris;     
    %   dataSet = dataSet.retainFeatures(1:2);
    %   histEq = prtPreProcHistEqKde;        
    %                        
    %   histEq = histEq.train(dataSet); 
    %   dataSetNew = histEq.run(dataSet); 
    % 
    %   subplot(2,1,1); plot(dataSet);
    %   title('Original Data');
    %   subplot(2,1,2); plot(dataSetNew);
    %   title('HistEq Data');
    %

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
        name = 'Histogram Equalization KDE'
        nameAbbreviation = 'HistEqKde'
    end
    
    properties
        prtRvKdeObj = prtRvKde;
    end
    
    properties (SetAccess='protected');
        prtRvKdePerDim = {};
    end
        
    
    methods
        function Obj = prtPreProcHistEqKde(varargin)
            % Allow for string, value pairs
            % There are no user settable options though.
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected,Hidden=true)
        
        function Obj = trainAction(Obj,DataSet)
            for iDim = 1:DataSet.nFeatures
                Obj.prtRvKdePerDim{iDim} = Obj.prtRvKdeObj.mle(DataSet.getObservations(:,iDim));
            end
        end
        
        function DataSet = runAction(Obj,DataSet)
            X = nan(DataSet.nObservations,DataSet.nFeatures);
            for iDim = 1:DataSet.nFeatures
                X(:,iDim) = Obj.prtRvKdePerDim{iDim}.cdf(DataSet.getObservations(:,iDim));
            end
            if any(~isfinite(DataSet.getObservations()))
                X(DataSet.getObservations() > 0 & isinf(DataSet.getObservations())) = 1;
                X(DataSet.getObservations() < 0 & isinf(DataSet.getObservations())) = 0;
            end
            
            DataSet = DataSet.setObservations(X);
        end
    end
    
end
