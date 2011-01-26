classdef prtKernel2 
    %should we inherit from prtAction?
    % would simplify a ton of stuff
    
    methods (Abstract)
        Obj = train(Obj,dsTrain)
        dsOut = run(Obj,dsTest)
        nDimensions = getNumDimensions(Obj)
        Obj = retainKernelDimensions(Obj,keepLogical)
    end
    
    
    properties (SetAccess = protected)
        % Specifies if prtAction object has been trained.
        isTrained = false;  
    end
    
    methods
        
        function Obj3 = and(Obj1,Obj2)
            if isa(Obj1,'prtKernelSet')
                kernelCell1 = Obj1.getKernelCell;
            elseif isa(Obj1,'prtKernel2')
                kernelCell1 = {Obj1};
            else
                error('prt:prtKernel','Invalid input to prtKernel\and, both arguments must be of type prtKernel');
            end
            
            if isa(Obj2,'prtKernelSet')
                kernelCell2 = Obj2.getKernelCell;
            elseif isa(Obj2,'prtKernel2')
                kernelCell2 = {Obj2};
            else
                error('prt:prtKernel','Invalid input to prtKernel\and, both arguments must be of type prtKernel');
            end
            Obj3 = prtKernelSet(kernelCell1{:},kernelCell2{:});
        end
        
    end
end