classdef prtClassRfKm < prtClass
    % prtClassRfKm - Random Feature Kernel Machine
    
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
        name = 'Random Feature Kernel Machine' % Random Feature Kernel Machine
        nameAbbreviation = 'RFKM'            % RFKM
        isNativeMary = false;  % False
    end
    
    properties
        nRandomRbfSamples = 100;
        kernelRbfSigma = 1;
    end
    
    properties
        w = []; % The vector of random weights, learned during training
        alpha  = [];
        
        linearClassifierLearningMethod = 'leastsquares';
        
        leastSquaresRegularization = 0.1;
        
        pegasosLearningRate = 1e-4;
        pegasosNMaxIterations = 1e4; % T
        pegasosNObservationsPerSubGradient = 100; %k
        pegasosWeightChangeConvergenceTolerance = 1e-6;
        
    end
    
    methods
     
        % Allow for string, value pairs
        function self = prtClassRfKm(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,ds)
            
            self.w = randn(ds.nFeatures,self.nRandomRbfSamples*length(self.kernelRbfSigma));
            if length(self.kernelRbfSigma) > 1
                self.w = bsxfun(@rdivide,self.w,kron(self.kernelRbfSigma(:)',ones(1,self.nRandomRbfSamples)));
            else
                self.w = self.w./self.kernelRbfSigma;
            end
            
            % get y as -1,1
            y = ds.getTargetsAsBinaryMatrix;
            y = y(:,2);
            y(y==0) = -1;
            
            z = exp(1j*ds.X*self.w)./sqrt(self.nRandomRbfSamples); % Half of the FFT of K()
            % calculate random bin features and cat with z
            
            switch lower(self.linearClassifierLearningMethod)
                case 'leastsquares'
                    self.alpha = (eye(size(z,2))*self.leastSquaresRegularization + z'*z)\(z'*y); % The equation in the slides is wrong
                    
                case 'pegasos'
                    % use pegasos here instead of regularized least squares
                    % This can help when you have big data
                    % It gets a little werid though
                    % Not sure it totally works for complex data.
                    % Be careful.
                    
                    self.alpha = randn(1,size(z,2));
                    self.alpha = self.alpha./norm(self.alpha,1)/sqrt(self.leastSquaresRegularization);
                    
                    inverseSqrtLambda = 1./sqrt(self.pegasosLearningRate);
                    
                    nObservations = size(z,1);
                    for t = 2:self.pegasosNMaxIterations
                        oldW = self.alpha;
                        etaT = 1/(self.pegasosLearningRate*t);
                        
                        cInds = prtRvUtilRandomSample(nObservations, self.pegasosNObservationsPerSubGradient);
                        
                        At = z(cInds,:);
                        yt = y(cInds);
                        
                        AtPlusInds = (yt.*(At*self.alpha'))<1;
                        
                        AtPlus = At(AtPlusInds,:);
                        ytPlus = yt(AtPlusInds);
                        
                        wtPlusOneHalf = (1-1/t)*self.alpha + etaT./self.pegasosNObservationsPerSubGradient*(ytPlus'*AtPlus);
                        
                        cScale = min(1,inverseSqrtLambda./norm(wtPlusOneHalf));
                        self.alpha = cScale*wtPlusOneHalf;
                        
                        if (norm(self.alpha-oldW)/size(z,2)) < self.pegasosWeightChangeConvergenceTolerance
                            break
                        end
                        
                    end
                    self.alpha = self.alpha(:);
                otherwise
                    error('unknown linearClassifierLearningMethod, only leastSquares or pegasos or rvm are allowed');
            end
            
            
            
        end
        
        function ds = runAction(self,ds)
            ds.X = runActionFast(self, ds.X);
        end
        function x = runActionFast(self, x)
            x = real(exp(1j*x*self.w)*self.alpha);
        end
    end
end
