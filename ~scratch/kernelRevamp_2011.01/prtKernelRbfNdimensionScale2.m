classdef prtKernelRbfNdimensionScale2 < prtKernelRbf2
    
    methods
        function dsOut = run(Obj,ds)
            if ~Obj.isTrained
                error('prtKernelRbf:run','Attempt to run an untrained kernel; use kernel.train(ds) to train');
            end
            
            if Obj.internalDataSet.nObservations == 0
                dsOut = prtDataSetClass;
            else
                scaledSigma = sqrt(Obj.sigma.^2*Obj.internalDataSet.nFeatures);
                gram = prtKernelRbf2.eval(ds.getObservations,Obj.internalDataSet.getObservations,scaledSigma);
                dsOut = ds.setObservations(gram);
            end
        end
    end
end