% PRTBRV - PRT Bayesian Random Variable Class
%   Abstract Methods:
%       nDimensions

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


classdef prtBrv < prtAction
    methods (Abstract)
        self = estimateParameters(self, priorSelf, x)
        y = predictivePdf(self, x)
        y = predictiveLogPdf(self, x)
        
        d = getNumDimensions(self)
        
        self = initialize(self, x)
    end
    
    methods
        % Optional methods that would be nice to have
        % You don't have to implement these but you are welcome to some
        % types of processing for example VB with 
        % calculateNegativeFreeEnergy = true, might require some of these
        function kld = conjugateKld(self, prior) %#ok<INUSD,STOUT>
            missingMethodError(self,'conjugateKld')
        end
        function x = posteriorMeanDraw(self, n, varargin) %#ok<INUSD,STOUT>
            missingMethodError(self,'posteriorMeanDraw')
        end 
        function s = posteriorMeanStruct(self) %#ok<STOUT>
            missingMethodError(self,'posteriorMeanStruct')
        end
        function plotCollection(selfVec,colors) %#ok<INUSD>
           missingMethodError(selfVec(1),'plotCollection') 
        end
        function val = plotLimits(self) %#ok<STOUT>
           missingMethodError(self,'plotLimits') 
        end
        %function plot(self)
        %    plotCollection(self);
        %end
    end
    
    
    % All prtBrv's get the property nDimensions
    % For a particular subclass getNumDimensions must be implemented
    properties (Dependent)
        nDimensions
    end
    methods 
        function val = get.nDimensions(self)
            val = zeros(size(self));
            for iRv = 1:numel(self)
                val(iRv) = self(iRv).getNumDimensions();
            end
        end
    end
   
    % Because we are a prtAction we also must implement something like this
    
    %%% properties (SetAccess=private)
    %%%     name = 'Maximum a Posteriori'   % Maximum a Posteriori
    %%%     nameAbbreviation = 'MAP'        % MAP
    %%%     isNativeMary = true;            % True
    %%% end
    
    % For prtAction, we also must implement trainAction() and runAction()
    methods (Access = protected, Hidden = true)
        function self = trainAction(self, ds)
            self = estimateParameters(self, ds); 
        end
        
        function ds = runAction(self, ds)
            ds = ds.setObservations(self.predictiveLogPdf(ds.getObservations));
        end
    end
    
    methods (Access = 'protected', Hidden = true)
        function missingMethodError(self,methodName) %#ok<MANU>
            error('The method %s is not defined for this prtBrv object',methodName);
        end
        
        function self = constructorInputParse(self,varargin)
            
            nIn = length(varargin);

            % Quick Exit for the zero input constructor
            if nIn == 0
                return
            elseif mod(nIn,2)
                error('prt:prtBrv:constructorInputParse','Inputs must be supplied by as string/value pairs');
            end
            
            self = prtUtilAssignStringValuePairs(self, varargin{:});

        end
    end
end
