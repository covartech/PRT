classdef prtBrvDpMixture < prtBrvMixture
    methods
        function obj = prtBrvDpMixture(varargin)
            obj.mixing = prtBrvDiscreteStickBreaking;
            
            if nargin < 1
                return
            end
            obj = constructorInputParse(obj,varargin{:});
        end
    end
end