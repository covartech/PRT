classdef prtBrvDpMixture < prtBrvMixture
    % ds = prtDataGenOldFaithful; x = ds.getX;
    %
    % mm = prtBrvDpMixture('components',repmat(prtBrvMvn,25,1));
    % mm.vbConvergenceThreshold = 1e-6;
    % mm.vbVerboseText = true;
    % mm.vbVerbosePlot = true;
    % mm.vbVerboseMovie = true;
    % [mmLearned, training] = mm.vb(x);





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
