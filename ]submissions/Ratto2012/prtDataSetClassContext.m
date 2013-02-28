classdef prtDataSetClassContext  < prtDataSetClass

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


    
    properties
        contextFeatIndicator
        contextLabels
    end

    
    % Ease of use properties and methods, perhaps these should be
    % moved to prtDataSetStandardClass
    methods
        function obj = set.contextFeatIndicator(obj,val)
            obj.contextFeatIndicator = val;
        end
        function obj = set.contextLabels(obj,val)
            obj.contextLabels = val;
        end
        function contextFeats = getContextFeats(obj)
            xAll = obj.X;
            contextFeats = xAll(:,obj.contextFeatIndicator);
        end
        function targetFeats = getTargetFeats(obj)
            xAll = obj.X;
            targetFeats = xAll(:,~obj.contextFeatIndicator);
        end
        function dsContext = getContextDataSet(obj)
            xContext = obj.getContextFeats;
            if isfield(obj.observationInfo,'contextLabel')
                c = obj.C;
            	dsContext = prtDataSetClass(xContext,c);
            else
                dsContext = prtDataSetClass(xContext);
            end
        end
        function dsClass = getTargetDataSet(obj)
            xClass = obj.getTargetFeats;
            y = obj.Y;
            dsClass = prtDataSetClass(xClass,y);
        end
        function c = C(obj)
            c = cat(1,[],obj.observationInfo.contextLabel);
        end       
        
        function obj = prtDataSetClassContext(varargin)
            if nargin == 0
                obj.X = [];
                obj.contextFeatIndicator = [];
                obj.Y = [];
            else
                if nargin == 1
                    ds = varargin{1};
                    xClass = ds.getTargetFeats;
                    xContext = ds.getContextFeats;
                    y = ds.Y;
                    c = ds.C;
                elseif nargin == 2
                    dsTarget = varargin{1};
                    dsContext = varargin{2};
                    xClass = dsTarget.X;
                    xContext = dsContext.X;
                    y = dsTarget.Y;
                    c = dsContext.Y;
                end
                
                obj.X = [xClass,xContext];
                obj.contextFeatIndicator = [false(1,size(xClass,2)),true(1,size(xContext,2))];
                obj.Y = y;
                obj.observationInfo = repmat(struct('contextLabel',[]),obj.nObservations,1);
                if ~isempty(c)
                    for i = 1:obj.nObservations
                        obj.observationInfo(i).contextLabel = c(i);
                    end
                else
                    for i = 1:obj.nObservations
                        obj.observationInfo(i).contextLabel = [];
                    end
                end
            end
        end
    end
    
end
