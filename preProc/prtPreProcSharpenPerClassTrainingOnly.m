classdef prtPreProcSharpenPerClassTrainingOnly < prtPreProc
    %

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
        % Required by prtAction
        name = 'Sharpening'
        nameAbbreviation = 'SHARP'
    end
    
    properties
        k = 1;
        distanceFunction = @(x1,x2)prtDistanceEuclidean(x1,x2);
    end
    
    methods
        
        function self = prtPreProcSharpenPerClassTrainingOnly(varargin)
            % Allow for string, value pairs
            % There are no user settable options though.
            self.isCrossValidateValid = false; %changes data size
            self = prtUtilAssignStringValuePairs(self,varargin{:});
            self.verboseStorage = true;
        end
    end
    
    methods (Access=protected,Hidden=true)
        function self = preTrainProcessing(self,ds)
            if ~self.verboseStorage
                warning('prtClassSharpen:verboseStorage:false','prtPreProcSharpenPerClassTrainingOnly requires verboseStorage to be true; overriding manual settings');
            end
            self.verboseStorage = true;
        end
        
        function self = trainAction(self,ds)
            % Nothing to do.
        end
        
        function ds = runActionOnTrainingData(self,ds)
            
            yMat = logical(ds.getTargetsAsBinaryMatrix);
            X = ds.X;
            newX = X;
            for iClass = 1:ds.nClasses
                obsInds = find(yMat(:,iClass));
                
                cX = X(obsInds,:);
                
                distanceMat = feval(self.distanceFunction, cX, cX);
                
                [~,I] = sort(distanceMat,1,'ascend');
                nearestNeighborInds = I(self.k+1,:); %+1 to remove self-reference

                newX(obsInds,:) = cX(nearestNeighborInds,:);

            end

            ds = ds.setX(newX);

        end
        
        function ds = runAction(self,ds)
            % Nothing
        end
    end
end
