classdef prtRegressPiecewiseLinear < prtRegress
    %prtRegresPiecewiseLinear  Piecewise linear regression object
    %
    %   REGRESS = prtRegressPiecewiseLinear returns a prtRegressLslr object
    %
    %   REGRESS = prtRegressPiecewiseLinear(PROPERTY1, VALUE1, ...) constructs a
    %   prtRegressGP object REGRESS with properties as specified by
    %   PROPERTY/VALUE pairs.
    % 
    %
    %   See also prtRegressLslr, prtRegressRvm, prtRegressGP

% Copyright (c) 2014 Patrick Wang
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
        name = 'Piecewise Linear Regression' % Piecewise Linear Regression
        nameAbbreviation = 'pLin'                % LSLR
	end
    
    methods
        
        % Allow for string, value pairs
        function Obj = prtRegressPiecewiseLinear(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            Obj.dataSet = DataSet;
        end
        
        function RegressionResults = runAction(Obj,DataSet)
			if Obj.dataSet.nFeatures<2
				X = interp1(Obj.dataSet.X,...
					Obj.dataSet.Y,...
					DataSet.X,'linear','extrap');
			else
				X = griddatan(Obj.dataSet.X,...
					Obj.dataSet.Y,...
					DataSet.X);
			end
			RegressionResults = DataSet.setObservations(X);
        end
        
    end
    
end
