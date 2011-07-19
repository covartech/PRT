classdef prtBrvDpMm < prtBrvMm
    properties
        mixingProportions
        components
    end
    properties (Dependent, SetAccess='private')
        nComponents
    end
    methods
        
        function obj = prtBrvDpMm(varargin)
            if nargin < 1
                return
            end
            
            obj.components = varargin{1}(:);
            obj.mixingProportions = prtBrvDiscreteStickBreaking(obj.nComponents);
        end
        
    end
end
        