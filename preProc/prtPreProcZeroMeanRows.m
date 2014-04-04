classdef prtPreProcZeroMeanRows < prtPreProc
    % prtPreProcZeroMeanRows  Zero mean observations (rows)
    %
    %   ZM = prtPreProcZeroMeanRows creates an object that removes the
    %   mean from each row (observation) of a data set.
    %
    %   prtPreProcZeroMeanRows has no user settable properties.
    %
    %   A prtPreProcZeroMeanRows object also inherits all properties and
    %   functions from the prtAction class.
    %
    %   Example:
    %
    %   dataSet = prtDataGenIris;              % Load a data set
    %   dataSet = dataSet.retainFeatures(1:3); % Use only the first 3 features
    %   zmr = prtPreProcZeroMeanRows;          % Create a
    %                                          %  prtPreProcZeroMeanRows object
    %   zmr = zmr.train(dataSet);              % Train
    %   dataSetNew = zmr.run(dataSet);         % Run
    %
    %   % Plot
    %   subplot(2,1,1); plot(dataSet);
    %   subplot(2,1,2); plot(dataSetNew);
    %
    %   See Also: prtPreProc, prtPreProcPca, prtPreProcPls,
    %   prtPreProcHistEq, prtPreProcZeroMeanColumns, prtPreProcLda,
    %   prtPreProcZeroMeanRows, prtPreProcLogDisc, prtPreProcZmuv,
    %   prtPreProcMinMaxRows        

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
        name = 'Zero-Mean Rows' % Zero-Mean Rows
        nameAbbreviation = 'ZMR' % ZMR
    end
    
    properties
        %no properties
    end
    
    methods
        
        % Allow for string, value pairs
        function Obj = prtPreProcZeroMeanRows(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet) %#ok<INUSD>
            %do nothing
        end
        
        function DataSet = runAction(Obj,DataSet) %#ok<MANU>
            DataSet = DataSet.setObservations(bsxfun(@minus,DataSet.getObservations,mean(DataSet.getObservations,2)));
        end
        
        function xOut = runActionFast(Obj,xIn,ds) %#ok<INUSD>
            xOut = bsxfun(@minus,xIn,mean(xIn,2));
        end
    end
    
    
    methods (Hidden)
        function str = exportSimpleText(self)
            titleText = sprintf('%% prtPreProcZeroMeanRows (No Parameters)\n');
            str = sprintf('%s',titleText); % No parameters 
        end
    end
end
