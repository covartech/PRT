classdef prtRvMemebershipModel

% Copyright (c) 2013 New Folder Consulting
%
% Permission is hereby granted, free of charge, to any person obtaining a
% copy of this software and associated documentation files (the
% "Software"), to deal in the Software without restriction, including
% without limitation the rights to use, copy, modify, merge, publish,
% distribute, sublicense, and/or sell copies of the Software, and to permit
% persons to whom the Software is furnished to do so, subject to the
% following conditions:
%
% The above copyright notice and this permission notice shall be included
% in all copies or substantial portions of the Software.
%
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
% OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
% MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
% NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
% DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
% USE OR OTHER DEALINGS IN THE SOFTWARE.
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
