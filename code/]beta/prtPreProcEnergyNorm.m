classdef prtPreProcEnergyNorm < prtPreProc
    % prtPreProcEnergyNorm  Normalize the energy of all rows of the data
    %
    %   EnergyNorm = prtPreProcEnergyNorm creates an energy normalize rows
    %   pre processing object. A prtPreProcEnergyNorm object scales
    %   the input observations so that each row has unit energy.
    % 
    %   prtPreProcEnergyNorm has no user settable properties.
    %
    %   A prtPreProcEnergyNorm object also inherits all properties and
    %   functions from the prtAction class.
    %
    %
    %   Example:
    %
    %   dataSet = prtDataGenIris;       
    %   dataSet = dataSet.retainFeatures(1:3);
    %   energyNorm = prtPreProcEnergyNorm;  
    %                                  
    %   energyNorm = energyNorm.train(dataSet);  
    %   dataSetNew = energyNorm.run(dataSet); 
    % 
    %   subplot(2,1,1); plot(dataSet);
    %   title('Original Data');
    %   subplot(2,1,2); plot(dataSetNew);
    %   title('EnergyNorm Data');
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
        name = 'Energy Norm Rows'
        nameAbbreviation = 'ENR'
    end
    
    properties
        %no properties
    end
    properties (SetAccess=private)
        % General Classifier Properties
    end
    
    methods
        
          % Allow for string, value pairs
        function Obj = prtPreProcEnergyNorm(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected,Hidden=true)
        
        function Obj = trainAction(Obj,DataSet)
            %do nothing
        end
        
        function DataSet = runAction(Obj,DataSet)
            if DataSet.nFeatures < 2
                error('prt:prtPreProcMinMaxRows:tooFewFeatures','prtPreProcMinMaxRows requires a data set with at least 2 dimensions, but provided data set only has %d',DataSet.nFeatures);
            end
            
            theData = DataSet.getObservations;
            
            theData = bsxfun(@rdivide,theData,sqrt(sum(theData.^2,2)));
            DataSet = DataSet.setObservations(theData);
        end
        
    end
    
end
