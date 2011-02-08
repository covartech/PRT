classdef prtBlock < handle
    
    properties  %general purpose
        nInputs
        inputNames
        inputTypes
        
        nOutputs
        outputNames
        outputTypes
    end
    
    properties %for parameters specified in GUI
        parameterCell
        nParameters
        parameterTypes
    end
    
    methods (Abstract)
        varargout = train(varargin)
        varargout = run(varargin)
        
        varargout = drawBlock(varargin)
    end 
end