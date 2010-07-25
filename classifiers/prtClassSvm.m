classdef prtClassSvm < prtClass
%     % prtClassFld Properties: 
%     %   name - Fisher Linear Discriminant
%     %   nameAbbreviation - FLD
%     %   isSupervised - true
%     %   isNativeMary - false
%     %   w - regression weights - estimated during training
%     %   plotBasis - logical, plot the basis
%     %   plotProjections - logical, plot projections of points to basis
%     %
%     % prtClassFld Methods:

    properties (SetAccess=private)
        % Required by prtAction
        name = 'Support Vector Machine'
        nameAbbreviation = 'SVM'
        isSupervised = true;
        
        % Required by prtClass
        isNativeMary = false;
    end
    
    properties
        
        c = 1;
        tol = 0.00001;
        alpha
        beta
        kernels = {prtKernelRbfNdimensionScale};
    end
    properties 
        trainedKernels
    end
    methods
        
        function Obj = prtClassSvm(varargin)
            % Allow for string, value pairs
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
    end
    
    methods (Access=protected)
        
        function Obj = trainAction(Obj,DataSet)
            
            % Train (center) the kernels at the trianing data (if
            % necessary)
            Obj.trainedKernels = cell(size(Obj.kernels));
            for iKernel = 1:length(Obj.kernels);
                Obj.trainedKernels{iKernel} = initializeKernelArray(Obj.kernels{iKernel},DataSet);
            end
            Obj.trainedKernels = cat(1,Obj.trainedKernels{:});
            gramm = prtKernelGrammMatrix(DataSet,Obj.trainedKernels);
            
            [Obj.alpha,Obj.beta] = prtUtilSmo(DataSet.getX,DataSet.getY,gramm,Obj.c,Obj.tol);
            
        end
        
        function DataSetOut = runAction(Obj,DataSet)
            
            memChunkSize = 1000; % Should this be moved somewhere?
            n = DataSet.nObservations;
            
            DataSetOut = prtDataSetClass(zeros(n,1));
            for i = 1:memChunkSize:n;
                cI = i:min(i+memChunkSize,n);
                cDataSet = prtDataSetClass(DataSet.getObservations(cI,:));
                gramm = prtKernelGrammMatrix(cDataSet,Obj.trainedKernels);
                
                y = gramm*Obj.alpha - Obj.beta;
                DataSetOut = DataSetOut.setObservations(y, cI);
            end
        end
        
    end
    methods
        function varargout = plot(Obj)
            % plot - Plot output confidence of prtClass object
            %   Works when dimensionality of dataset is 3 or less.
            %   Can produce both M-ary and Binary decision surfaces
            %   See also: Obj.plotDecision()
            
            HandleStructure = plot@prtClass(Obj);
            
            % Plot the kernels
            hold on
            for iKernel = 1:length(Obj.trainedKernels)
                if Obj.alpha(iKernel) ~= 0
                    Obj.trainedKernels{iKernel}.classifierPlot();
                end
            end
            hold off
            
            varargout = {};
            if nargout > 0
                varargout = {HandleStructure};
            end
        end
    end
    
end