classdef prtBrvDiscreteStickBreaking < prtBrv & prtBrvVbOnline

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


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties required by prtAction
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties (SetAccess = private)
        name = 'Discrete Stick Breaking Bayesian Random Variable';
        nameAbbreviation = 'BRVSB';
    end
    
    properties (SetAccess = protected)
        isSupervised = false;
        isCrossValidateValid = true;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for prtBrv
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    methods
          
        function self = estimateParameters(self, x)
            self = conjugateUpdate(self, self, x);
        end
        
        function y = predictivePdf(self, x)
            y = exp(predictiveLogPdf(self, x));
        end
        
        function y = predictiveLogPdf(self, x)
            %%%% FIXME
            % The true predictive here is a product of beta-binomials
            % Since that isn't implemented yet we use the average
            % variational loglikelihood
            
            y = conjugateVariationalAverageLogLikelihood(self, x);
        end
        
        function val = getNumDimensions(self)
            val = size(self.model.beta,1);
        end
    
        function self = initialize(self, x)
            x = self.parseInputData(x);
            if ~self.model.isValid
                self.model = self.model.defaultParameters(size(x,2));
            end
        end
        
        % Optional methods
        %------------------------------------------------------------------
        function kld = conjugateKld(obj, priorObj)
            kld = obj.model.kld(priorObj.model);
        end
        
        function s = posteriorMeanStruct(obj)
            s.probabilities = exp(obj.model.expectedValueLogProbabilities);
        end
        
        function val = plotLimits(self)
            val = [0 length(self(1).model.lambda)+1 0 length(self(1).model.lambda)+1];
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for prtBrvVb
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    methods
        function [self, training] = vbBatch(self,x)
            % Since we are purely conjugate we actually don't need vbBatch
            % However we must implement it.
            self = conjugateUpdate(self,x);
            training = struct([]);
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for prtBrvVbOnline
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    methods
        function self = vbOnlineInitialize(self, x) %#ok<INUSD>
            randDraw = rand(1,self.nDimensions);
            randDraw = randDraw./sum(randDraw);
            
            self = self.conjugateUpdate(self, randDraw);
        end
        
        function [self, training] = vbOnlineUpdate(self, priorSelf, x, training, prevSelf, learningRate, D) %#ok<INUSL>
            x = self.parseInputData(x);
            
            [self.model, training] = self.model.vbOnlineWeightedUpdate(priorObj.model, sum(x,1), [], lambda, D, prevObj.model);
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for prtBrvMembershipModel
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    methods
        % Don't actually inherit from prtBrvMembershipModel but these two
        % methods are abstracted there
        function self = conjugateUpdate(self, prior, x)
            x = parseInputData(self,x); 
            self.model = self.model.conjugateUpdate(prior.model,x);
        end
        
        function obj = weightedConjugateUpdate(obj, priorObj, x, weights)
            x = parseInputData(self,x); 
            obj.model = obj.model.conjugateUpdate(priorObj.model,bsxfun(@times,x,weights));
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for prtBrvVbOnlineMembershipModel
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
    methods
        function [obj, training] = vbOnlineWeightedUpdate(obj, priorObj, x, weights, lambda, D, prevObj)
            x = obj.parseInputData(x);
            if ~isempty(weights)
                x = bsxfun(@times,x,weights);
            end
            
            [obj.model, training] = obj.model.vbOnlineWeightedUpdate(priorObj.model, sum(x,1), [], lambda, D, prevObj.model);
        end
    end
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties for prtBrvDiscreteStickBreaking use
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        model = prtBrvDiscreteStickBreakingHierarchy;
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Methods for prtBrvDiscreteStickBreaking use
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods
        function obj = prtBrvDiscreteStickBreaking(varargin)
            if nargin < 1
                return
            end
            obj = obj.constructorInputParse(varargin{:});
        end
        
        function val = expectedLogMean(obj)
            val = obj.model.expectedValueLogProbabilities(:)';
        end
        
        function model = modelDraw(obj)
            model.probabilities = draw(obj.model);
        end
    end
    
    methods (Hidden)
        function x = parseInputData(self,x) %#ok<MANU>
            if isnumeric(x)
                return
            elseif prtUtilIsSubClass(class(x),'prtDataSetBase')
                x = x.getObservations();
            else 
                error('prt:prtBrvDiscreteStickBreaking:parseInputData','prtBrvDiscreteStickBreaking requires a prtDataSet or a numeric 2-D matrix');
            end
        end
    end
end
