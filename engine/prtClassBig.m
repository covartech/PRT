classdef prtClassBig < prtActionBig
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