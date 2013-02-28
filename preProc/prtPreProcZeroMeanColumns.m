classdef prtPreProcZeroMeanColumns < prtPreProc
    % prtPreProcZeroMeanColumns   Zero mean feature (columns)
    %
    %   ZMC = prtPreProcZeroMeanColumns creates an object that removes the
    %   mean from each column (feature) of a data set.
    %
    %   prtPreProcZeroMeanColumns has no user settable properties.
    %
    %   A prtPreProcZeroMeanColumns object also inherits all properties and
    %   functions from the prtAction class.
    %
    %   Example:
    %
    %   dataSet = prtDataGenIris;             % Load a data set and
    %   dataSet = dataSet.retainFeatures(1:2);% Retain the first 2 features
    %   zmc = prtPreProcZeroMeanColumns;      % Create a
    %                                         % prtPreProcZeroMeanColumns object
    %
    %   zmc = zmc.train(dataSet);             % Train
    %   dataSetNew = zmc.run(dataSet);        % Run
    %
    %   % Plot
    %   subplot(2,1,1); plot(dataSet);
    %   title(sprintf('Mean: %s',mat2str(mean(dataSet.getObservations),2)))
    %   subplot(2,1,2); plot(dataSetNew);
    %   title(sprintf('Mean: %s',mat2str(mean(dataSetNew.getObservations),2)))
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
        name = 'Zero-Mean Columns' % Zero-Mean Columns
        nameAbbreviation = 'ZMC' % ZMC
    end
    
    properties
        %no properties
    end
    properties (SetAccess=private)
        % General Classifier Properties
        meanVector = [];           % The vector of the means
    end
    
    methods
        
        % Allow for string, value pairs
        function Obj = prtPreProcZeroMeanColumns(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            Obj.meanVector = prtUtilNanMean(DataSet.getObservations(),1);
        end
        
        function DataSet = runAction(Obj,DataSet)
            DataSet = DataSet.setObservations(bsxfun(@minus,DataSet.getObservations,Obj.meanVector));
        end
        
    end
    
end
