classdef prtClassPerTurbo < prtClass
    % See: "Perturbo: a new classi?cation algorithm based on the spectrum
    % perturbations of the laplace-beltrami operator."
    %
    % Notes: 
    % 1) Very very sensitive to the kernel sigma parameter; should/must
    % optimize over \sigma
    %
    % 2) Very memory intensive.  Consider bootstrapping data and/or bagging
    % this classifier to reduce computational load (memory ~ O(nObs^2) )
    %
    % % try this:
    % ds = prtDataGenMarysSimpleSixClass;
    % pt = prtClassPerTurbo;
    % pt.kernel = prtKernelRbf('sigma',.7);
    % pt = pt.train(ds);
    % plot(pt)
    %
    % 
    % ds = prtDataGenMarySimple;
    % pt = prtClassPerTurbo;
    % pt.kernel = prtKernelRbf('sigma',.7);
    % pt = pt.train(ds);
    % plot(pt)
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
        name = 'PerTurbo'  % Bumping
        nameAbbreviation = 'PerTurbo'  % 
        isNativeMary = true;         % 
    end
    
    properties
        kernel = prtKernelRbfNdimensionScale;
    end
    properties (SetAccess=protected)
        trainedKernels
        K
        Kinv
        uClasses
    end
    
    methods
        
        function self = set.kernel(self,val)
            assert(numel(val)==1 &&  isa(val,'prtKernel'),'prt:prtClassRvm:kernel','kernel must be a prtKernel');
            self.kernel = val;
        end
        
        function self = prtClassPerTurbo(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
    end
    
    methods (Access=protected, Hidden = true)
        
        function self = trainAction(self,dataSet)
            self.uClasses = dataSet.uniqueClasses;
            y = dataSet.getTargets;
            x = dataSet.getObservations;
            for i = 1:length(self.uClasses)
                cInd = y == self.uClasses(i);
                cx = x(cInd,:);
                
                tempDs = prtDataSetClass(cx);
                self.trainedKernels{i} = self.kernel.train(tempDs);
                self.K{i} =  self.trainedKernels{i}.run_OutputDoubleArray(tempDs);
                self.Kinv{i} = inv(self.K{i});
            end
        end
        
        function yOut = runAction(self,dataSet)
            
            x = nan(dataSet.nObservations,length(self.uClasses));
            for samples = 1:1000:dataSet.nObservations
                retainObs = samples:min([samples+999,dataSet.nObservations]);
                currSet = dataSet.retainObservations(retainObs);
                for i = 1:length(self.uClasses)
                    
                    k = self.trainedKernels{i}.run_OutputDoubleArray(currSet);
                    x(retainObs,i) = 1-diag(k*self.Kinv{i}*k');
                end
            end
            
            yOut = dataSet;
            yOut.X = -x;
            %binary; note - output mixture for binary classification
            if length(self.uClasses) == 2 
                yOut.X = -x(:,2)+x(:,1);
            end
        end
        
    end
end
