classdef prtClassBig < prtActionBig

% Copyright (c) 2014 CoVar Applied Technologies
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
    methods

        
        function self = postTrainBigProcessing(self,ds)
            if ~isempty(self.internalDecider)
                tempself = self;
                tempself.internalDecider = [];
                yOut = tempself.run(ds);
                self.internalDecider = self.internalDecider.trainBig(yOut);
            end
        end
        
        function self = preTrainBigProcessing(self, ds)
            % Overload preTrainProcessing() so that we can determine mary
            % output status
            self = self.setYieldsMaryOutput(determineMaryOutputBig(self,ds));
        end
        
        function produceMaryOutput = determineMaryOutputBig(self,ds)
            % Determine if an Mary output will be provided by the classifier
            % Determined by the ds the classifier capabilities and the            
            % twoClassParadigm switch
            
            produceMaryOutput = false; % Default answer only do mary in special conditions
            
            if isnan(self.isNativeMary)
                produceMaryOutput = [];
                return; %let it do it's thing.
            end
            if ds.isMary
                % You have Mary data so you want an Mary output
                if self.isNativeMary
                    % You have Mary data and an Mary Classifier
                    % so you want an Mary output
                    produceMaryOutput = true;
                else
                    % Binary only classifier with Mary Data
                    error('prt:prtClass:classifierDataSetMismatch','M-ary classification is not supported by this classifier. You will need to use prtClassBinaryToMaryOneVsAll() or an equivalent M-ary emulation classifier.');
                end
            elseif ds.isBinary && self.isNativeMary
                % You have binary data and an Mary Classifier
                % We must check twoClassParadigm to see what you want
                produceMaryOutput = ~strcmpi(self.twoClassParadigm, 'binary');
            end % Unary Data -> false
            
            if self.includesDecision
                produceMaryOutput = false;
            end
        end
    end
end
