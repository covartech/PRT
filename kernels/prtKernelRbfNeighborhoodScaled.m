classdef prtKernelRbfNeighborhoodScaled < prtKernel
    % prtKernelRbfNeighborhoodScaled  Radial basis function kernel where
    % each entry is scaled according to the distance to neighbors in the
    % training set.
    %
    %  KERNOBJ = prtKernelRbfNeighborhoodScaled Generates a kernel object
    %  implementing a radial basis function.  Kernel objects are widely
    %  used in several prt classifiers, such as prtClassRvm and
    %  prtClassSvm.  RBF kernels implement the following function for 1 x N
    %  vectors x1 and x2:
    %
    %   k(x1,x2) = exp(-sum((x1-x2).^2)./sigma1.^2);
    %
    %  sigma1 is learned based on the neighboord of the data in
    %  feature space.
    % 
    %  KERNOBJ = prtKernelRbfNeighborhoodScaled(PROPERTY1, VALUE1, ...) constructs a
    %  prtKernelRbfNeighborhoodScaled object KERNOBJ with properties as specified by
    %  PROPERTY/VALUE pairs. prtKernelRbfNeighborhoodScaled objects have the following
    %  user-settable properties:
    %
    %   neighborhoodPercentile - Quantile distance that is used to define
    %       the neighboorhood. THis is a value between 1 and 100. Smaller
    %       values will make more local kernels. (Default value is 5)
    %
    %   prtKernelRbf objects inherit the TRAIN and RUN methods from prtKernel.
    %
    %   % Example
    %   ds = prtDataGenMoon;                     % Generate a dataset
    %   k1 = prtKernelRbfNeighborhoodScaled;    % Create a prtKernel object with 
    %                                            % default value of neighborhoodPercentile
    %   k2 = prtKernelRbfNeighborhoodScaled('neighborhoodPercentile',2); % Create a prtKernel object with
    %                                                                     % the specified value of neighborhoodPercentile
    %   
    %   k1 = k1.train(ds); % Train
    %   g1 = k1.run(ds); % Evaluate
    %
    %   k2 = k2.train(ds); % Train
    %   g2 = k2.run(ds); % Evaluate
    %
    %   subplot(2,1,1); imagesc(g1.getObservations);  %Plot the results
    %   subplot(2,1,2); imagesc(g2.getObservations);
    %
    %   See also: prtKernel,prtKernelSet, prtKernelDc, prtKernelRbf, prtKernelDirect,
    %   prtKernelHyperbolicTangent, prtKernelPolynomial,
    %   prtKernelRbfNdimensionScale, 

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


    properties (SetAccess = private)
        name = 'RBF Kernel Scaled'; % RBF Kernel Scaled
        nameAbbreviation = 'RBF'; % RBF
    end
    
    properties
        neighborhoodPercentile = 5;
        sigmas = []; % The inverse kernel width for each dimension
    end 
    
    methods (Access = protected, Hidden = true)
        function Obj = trainAction(Obj,ds)
            Obj.internalDataSet = ds;
            
            D = prtDistanceEuclidean(ds,ds);
            D = sort(D,'ascend');
            
            nPointsAway = min(max(round(size(D,1)*Obj.neighborhoodPercentile/100),1),size(D,1));
            
            Obj.sigmas = sqrt(D(nPointsAway,:))';
            Obj.sigmas(Obj.sigmas<=0) = 1; % Put weird values to 1
            
            Obj.isTrained = true;
        end
        
        function dsOut = runAction(Obj,ds)
            if ~Obj.isTrained
                error('prtKernelRbfNeighboorhoodScaled:run','Attempt to run an untrained kernel; use kernel.train(ds) to train');
            end
            if Obj.internalDataSet.nObservations == 0
                dsOut = prtDataSetClass;
            else
                gram = prtKernelRbfNeighborhoodScaled.kernelFn(ds.getObservations,Obj.internalDataSet.getObservations,Obj.sigmas);
                dsOut = ds.setObservations(gram);
            end
        end
    end
    
    methods
        function Obj = prtKernelRbfNeighborhoodScaled(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods(Hidden = true)
        function Obj = retainKernelDimensions(Obj,keepLogical)
            Obj.sigmas = Obj.sigmas(keepLogical);
            Obj = retainKernelDimensions@prtKernel(Obj,keepLogical);
        end
         
        function varargout = plot(obj)
            x = obj.internalDataSet.getObservations;
            
            if size(x,2) <= 3
                if size(x,2) == 1 && obj.internalDataSet.isLabeled
                    xy = cat(2,x,obj.internalDataSet.getTargets);
                    h = prtPlotUtilScatter(xy, {}, obj.plotOptions.symbol, obj.plotOptions.markerFaceColor, obj.plotOptions.color, obj.plotOptions.symbolLineWidth, obj.plotOptions.symbolSize);
                else
                    h = prtPlotUtilScatter(x, {}, obj.plotOptions.symbol, obj.plotOptions.markerFaceColor, obj.plotOptions.color, obj.plotOptions.symbolLineWidth, obj.plotOptions.symbolSize);
                end
            else
                h = nan;
            end
            
            varargout = {};
            if nargout
                varargout = {h};
            end
        end
    end
    
    methods (Static, Hidden = true)
        function gram = kernelFn(x,y,sigmas)
            [n1, d] = size(x);
            [n2, nin] = size(y);
            if d ~= nin
                error('size(x,2) must equal size(y,2)');
            end
            
            %dist2 = prtDistanceLNorm(x,y,2); 
            dist2 = repmat(sum((x.^2), 2), [1 n2]) + repmat(sum((y.^2),2), [1 n1]).' - 2*x*(y.');
            
            if numel(sigmas) == 1
                gram = exp(-dist2/(sigmas.^2));
            else
                gram = exp(-bsxfun(@rdivide,dist2,(sigmas.^2)'));
            end
        end
    end
end
