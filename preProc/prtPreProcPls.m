classdef prtPreProcPls < prtPreProc
    % prtPreProcPls   Partial least squares
    %
    %   PLS = prtPreProcPls creates a partial least-squares pre-processing
    %   object.
    %
    %   PLS = prtPreProcPls('nComponents',N) constructs a
    %   prtPreProcPLS object PLS with nComponents set to the value N.
    %
    %   A prtPreProcPls object has the following properites:
    % 
    %    nComponents    - The number of principle componenets
    %
    %   A prtPreProcPls object also inherits all properties and functions from
    %   the prtAction class
    %
    %   Example:
    %
    %   dataSet = prtDataGenFeatureSelection;  % Load a data set
    %   pls = prtPreProcPls;                   % Create a prtPreProcPls Object
    %                        
    %   pls = pls.train(dataSet);              % Train
    %   dataSetNew = pls.run(dataSet);         % Run
    %
    %   % Plot 
    %   plot(dataSetNew);
    %   title('PLS Projected Data');
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
        name = 'Partial Least Squares' % Partial Least Squares
        nameAbbreviation = 'PLS' % PLS
    end
    
    properties
        nComponents = 2;   % The number of Pls components
    end
    properties (SetAccess=private)
    
        projectionMatrix = [];  % Projection Matrix
        xMeanVector = [];  % X means
        yMeanVector = [];  % Y means
    end
    
    methods
        
          % Allow for string, value pairs
        function Obj = prtPreProcPls(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods
        function Obj = set.nComponents(Obj,nComp)
            if ~prtUtilIsPositiveScalarInteger(nComp);
                error('prt:prtPreProcPls','nComponents must be a positive scalar integer.');
            end
            Obj.nComponents = nComp;
        end
	end
    
	methods (Hidden = true)
        function featureNameModificationFunction = getFeatureNameModificationFunction(obj) %#ok<MANU>
            featureNameModificationFunction = prtUtilFeatureNameModificationFunctionHandleCreator('PLS Score #index#');
        end
	end
	
    methods (Access=protected,Hidden=true)
        
        function Obj = trainAction(Obj,DataSet)
            DataSet = DataSet.retainLabeled;
            
            X = DataSet.getObservations;
%             if DataSet.nClasses > 2
%                 Y = DataSet.getTargetsAsBinaryMatrix;
%             else
%                 Y = DataSet.getTargetsAsBinaryMatrix;
%                 Y = Y(:,2); %0's and 1's for H1
%             end
            %           

            Y = DataSet.getY;
            maxComps = min(size(X));
            if Obj.nComponents > maxComps;
                warning('prt:prtPreProcPls','nComponents (%d) > maximum components for the data set (%d); setting nComponents = %d',Obj.nComponents,maxComps,maxComps);
                Obj.nComponents = maxComps;
            end
            
            Obj.xMeanVector = mean(X,1);
            Obj.yMeanVector = mean(Y,1);
            X = bsxfun(@minus, X, Obj.xMeanVector);
            Y = bsxfun(@minus, Y, Obj.yMeanVector);
            
            [garbage,garbage, P] = prtUtilSimpls(X,Y,Obj.nComponents);
            
            Obj.projectionMatrix = pinv(P');
            Obj.projectionMatrix = bsxfun(@rdivide,Obj.projectionMatrix,sqrt(sum(Obj.projectionMatrix.^2,1)));
        end
        
        function DataSet = runAction(Obj,DataSet)
            X = DataSet.getObservations;
            X = bsxfun(@minus,X,Obj.xMeanVector);
            DataSet = DataSet.setObservations(X*Obj.projectionMatrix);
        end
    end
end
