classdef prtBrvDpMm < prtBrvMm
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
        