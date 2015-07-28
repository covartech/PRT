classdef prtDataInterfaceReshape
    % A mixin to allow other prtDataSetStandard's to specify that each observation (row of X)
    % is intended to be reshaped.
    %
    % This adds a few helper methods such as getObservationsAsMat and getObservationsAsCell
    % and most importantly it adds the property observationSize that specifies how to reshape
    % 
    % Inheriting from this class is a requirement for using prtImageFeatureExtractor* actions
    %
    % See prtDataSetClassReshape for example usage
    
    properties
        observationSize
    end
    methods
        function self = prtDataInterfaceReshape(varargin)
            self = prtUtilAssignStringValuePairs(self, varargin{:});
        end
        function X = getObservationsAsMat(self,varargin)
            X = self.getObservations(varargin{:});
            try
                X = reshape(X.', [self.observationSize size(X,1)]);
            catch ME
                error('prt:prtDataInterfaceReshape:getObservationsAsMat','Invalid indexing for dataSet size and observationSize. Check dimensionalities.');
            end
        end
        function out = getObservationsAsCell(self,varargin)
            X = self.getObservations(varargin{:});
            try
                nObs = size(X,1);
                out = cell(nObs,1);
                for iX = 1:nObs
                    out{iX} = reshape(X(iX,:), self.observationSize);
                end
            catch ME
                error('prt:prtDataInterfaceReshape:getObservationsAsCell','Invalid indexing for dataSet size and observationSize. Check dimensionalities.');
            end
        end
    end
end