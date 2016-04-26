classdef prtRvMemebershipModel





    methods (Abstract=true)

        self = weightedMle(self, x, weights)
    end
    methods
        function [Rs,initMembershipMat] = initializeMixtureMembership(Rs,X)
            
            learningInitialMembershipFactor = 0.9;
            
            [classMeans,kmMembership] = prtUtilKmeans(X,length(Rs),'handleEmptyClusters','random'); %#ok<ASGLU>
            
            initMembershipMat = zeros(size(X,1),length(Rs));
            for iComp = 1:length(Rs)
                initMembershipMat(kmMembership == iComp, iComp) = learningInitialMembershipFactor;
            end
            initMembershipMat(initMembershipMat==0) = (1-learningInitialMembershipFactor)./(length(Rs)-1);
            
            % We should normalize this just in case the
            % learningInitialMembershipFactor was set poorly
            initMembershipMat = bsxfun(@rdivide,initMembershipMat,sum(initMembershipMat,2));
        end
    end
end
