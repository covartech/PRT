classdef prtDataSetClassReshape < prtDataSetClass & prtDataInterfaceReshape
    % An helper class that interfaces from prtDataSetClass and prtDataInterfaceReshape
    % 
    % There are no additional methods. This just combines prtDataSetClass and the
    % mixin prtDataInterfaceReshape 
    %
    %  Example:
    %     ds = prtDataSetClassReshape(randn(20,100), [], 'observationSize',[10 10]);
    %
    %     size(ds.getObservations(1))
    %     size(ds.getObservations)
    %     size(ds.getObservationsAsMat(1))
    %     size(ds.getObservationsAsMat)
    %     size(ds.getObservationsAsMat([1 3]))
    %     size(ds.getObservationsAsCell([1 3]))
    %     size(ds.getObservationsAsCell())
    %     cell2mat(cellfun(@size,ds.getObservationsAsCell([1 3]),'uniformOutput',false))
    methods
        function self = prtDataSetClassReshape(varargin)
            self = self@prtDataSetClass(varargin{:});
        end
    end
end
