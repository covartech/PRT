classdef prtBrvVbMembershipModel < prtBrvMembershipModel





    methods (Abstract)

        y = conjugateVariationalAverageLogLikelihood(self, x)
    end
end     
