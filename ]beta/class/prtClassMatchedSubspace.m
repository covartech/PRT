classdef prtClassMatchedSubspace < prtClass

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


    properties (SetAccess=private)
       
        name = 'Matched Subspace'   
        nameAbbreviation = 'MatchedSubspace'
        isNativeMary = true;
        
    end
    
    properties
        inferH1subspace = true;
        inferH0subspace = false;
        
        nH1components = 2;
        nH0components = 2;
        
        proj1
        proj0
    end
    
    methods
        function self = prtClassKnn(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
            self.verboseStorage = true;
        end
    end
    
    methods (Access=protected, Hidden = true)

        function self = trainAction(self,ds)
            
            if self.inferH1subspace
                ds1 = ds.retainClassesByInd(2);
                x = ds1.X;
                [u,s] = svds(x',self.nH1components);
                p = u*(u'*u)^(-1/2)*u';
            else
                p = eye(ds.nFeatures);
            end
            self.proj1 = p;
            
            if self.inferH0subspace
                ds0 = ds.retainClassesByInd(1);
                x = ds0.X;
                [u,s] = svds(x,self.nH0components);
                p = u*(u'*u)^(-1/2)*u';
            else
                p = eye(ds.nFeatures);
            end
            self.proj0 = p;
            
        end
        
        function yOut = runAction(self,ds)
            
            x = ds.X;
            h1 = diag(x*self.proj1*x');
            h0 = diag(x*self.proj0*x');
            yOut = ds;
            %             yOut.X = log(h1)-log(h0);
            h1 = abs(h1);
            h0 = abs(h0);
            yOut.X = h1./h0;
            
        end
    end
end
