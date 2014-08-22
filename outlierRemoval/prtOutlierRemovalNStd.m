classdef prtOutlierRemovalNStd < prtOutlierRemoval
    % prtOutlierRemovalNStd  Removes outliers from a prtDataSet
    %
    %   NSTDOUT = prtOutlierRemovalNStd creates a pre-processing
    %   object that flags as outliers data where any of the feature values is
    %   more then nStd standard deviations from the mean of that feature.
    % 
    %   prtOutlierRemovalNStd has the following properties:
    %
    %       nStd - The number of standard deviations at which to flag an
    %              observation as an outlier an observation (default = 3)
    %
    %   A prtOutlierRemovalNStd object also inherits all properties and
    %   functions from the prtOutlierRemoval class.  For more information
    %   on how to control the behaviour of outlier removal objects, see the
    %   help for prtOutlierRemoval.
    %
    %   Example:
    %
    %   dataSet = prtDataGenUnimodal;               % Load a data Set
    %   outlier = prtDataSetClass([-10 -10],1);     % Create and insert
    %   dataSet = catObservations(dataSet,outlier); % an outlier
    %
    %   % Create the prtOutlierRemoval object
    %   nStdRemove = prtOutlierRemovalNStd('runMode','removeObservation');
    %
    %   nStdRemove = nStdRemove.train(dataSet);    % Train and run    
    %   dataSetNew = nStdRemove.run(dataSet);  
    % 
    %   % Plot the results
    %   subplot(2,1,1); plot(dataSet);
    %   title('Original Data');
    %   subplot(2,1,2); plot(dataSetNew);
    %   title('NstdOutlierRemove Data');
    %
    %   See Also:  prtOutlierRemoval,
    %   prtOutlierRemovalNonFinite,prtOutlierRemovalMissingData

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
        name = 'Standard Deviation Based Outlier Removal'; % Standard Deviation Based Outlier Removal
        nameAbbreviation = 'nStd' % nStd
    end
    
    properties
        nStd = 3;   % The number of standard deviations beyond which to remove data
    end
    
   % General Classifier Properties
    properties (SetAccess=private)
        stdVector = [];  % The standard deviation vector
        meanVector = [];  % The mean vector
    end
    
    methods
        
          % Allow for string, value pairs
        function Obj = prtOutlierRemovalNStd(varargin)
            Obj.isCrossValidateValid = false;  %can't cross validate because nStd changes the size of datasets
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods
        function Obj = set.nStd(Obj,value)
            if ~prtUtilIsPositiveScalarInteger(value)
                error('prt:prtOutlierRemovalNStd','value (%s) must be a positive scalar integer',mat2str(value));
            end
            Obj.nStd = value;
        end
    end
        
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            Obj.meanVector = mean(DataSet.getObservations(),1);
            Obj.stdVector = std(DataSet.getObservations(),1);
        end
        
        function outlierIndices = calculateOutlierIndices(Obj,DataSet)
            x = DataSet.getObservations;
            x = bsxfun(@minus,x,Obj.meanVector);
            x = bsxfun(@rdivide,x,Obj.stdVector);
            outlierIndices = abs(x) > Obj.nStd;
        end
        
    end
    
end
