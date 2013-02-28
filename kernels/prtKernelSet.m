classdef prtKernelSet < prtKernel
    % prtKernelSet  A set of prtKernel Object
    %
    %   KC = prtKernelSet(KERNOBJ) creates a prtKernelSet object consisting
    %   of one prtKenrel KERNOBJ.
    %
    %   KC = KERNOBJ1 & KERNOBJ2 creates a prtKernelSet object consisting of
    %   the prtKernel objects KERNOBJ1, and KERNOBJ2. Additional prtKernel
    %   object can be included by appending more objects using the AND(&)
    %   operator.
    %
    %   When the TRAIN method is called on a prtKernetSet object, the
    %   train method of all member prtKernel objects is invoked. 
    %
    %   When the RUN method is called on a prtKernelSet object is called,
    %   the RUN method of all member prtKernel objects is invoked, and the
    %   output is the concatenation of the results.
    %
    %   % Example:
    %
    %   ds = prtDataGenBimodal;       % Generate a dataset
    %   k1 = prtKernelRbf;            % Create a prtKernel object with 
    %                                 % default value of sigma 
    %   k2 = prtKernelRbf('sigma',2); % Create a prtKernel object with
    %                                 % specified value of sigma
    %       
    %   kSet = k1&k2;                 % Create a prtKernel object using the
    %                                 % AND operator 
    %   kSet =  kSet.train(ds);       % Train
    %      
    %   g = kSet.run(ds);             % Evaluate
    % 
    %   imagesc(g.getObservations);   %Plot the results
    %
    %   See also: prtKernel,prtKernelSet, prtKernelDc, prtKernelDirect,
    %   prtKernelHyperbolicTangent, prtKernelPolynomial,
    %   prtKernelRbfNdimensionScale

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


    properties (SetAccess = private)
        name = 'Kernel Set'; % Kernel Set
        nameAbbreviation = 'KernelSet'; % KernelSet
    end
    
    properties 
        kernelCell % The cell array of prtKenrel objects
    end
    
    methods (Access = protected, Hidden = true)
        
        function Obj = trainAction(Obj,ds)
            for i = 1:length(Obj.kernelCell)
                Obj.kernelCell{i} = Obj.kernelCell{i}.train(ds);
            end
            Obj.isTrained = true;
        end
        
        function dsOut = runAction(Obj,ds)
            
            for i = 1:length(Obj.kernelCell)
                if i == 1
                    dsOut = Obj.kernelCell{i}.run(ds);
                else
                    %Note: use getObservations here to make sure that
                    %there's no confusion when cat'ing features from
                    %prtDataSetClass and prtDataSetRegress'es
                    dsOut = dsOut.catFeatures(getObservations(Obj.kernelCell{i}.run(ds)));
                end
            end
        end
    end
    methods
        function Obj = prtKernelSet(varargin)
            %Obj = prtKernelSet(varargin)
            %   prtKernelSet(kernel1,kernel2,...)
            
            if nargin == 0
                error('prt:prtKernelSet:tooFewInputs','prtKernelSet requires at least one prtKernel object as input');
            end
            c = 1;
            tempKernelCell = {};
            for i = 1:length(varargin)
                if isa(varargin{i},'prtKernelSet')
                    tempCell = varargin{i}.getKernelCell;
                    tempKernelCell(c:c+length(tempCell)-1) = tempCell;
                    c = c + length(tempCell);
                elseif isa(varargin{i},'prtKernel')
                    tempKernelCell{c} = varargin{i}; %#ok<AGROW>  Impossible to tell how big this will get...
                    c = c + 1;
                end
            end
            Obj.kernelCell = tempKernelCell;
        end
        
        function Obj = set.kernelCell(Obj,aCell)
           
            %Check is cell:
            if ~isa(aCell,'cell')
                error('prtKernel:kernelCell','prtKernel''s kernelCell must be a cell array');
            end
            %Check right size:
            if ~isvector(aCell)
                error('prtKernel:kernelCell','prtKernel''s kernelCell must be a vector cell array');
            end
            %             if length(aCell) ~= size(Obj.connectivityMatrix,1)-2
            %                 error('prtKernel:kernelCell','Attempt to change a prtKernel''s kernelCell''s size.  kernelCell must be a vector cell array of length(size(Obj.connectivityMatrix,1)-2)');
            %             end
            
            %Check all are prtKernels:
            if ~all(cellfun(@(c)isa(c,'prtKernel'),aCell))
                error('prtKernel:kernelCell','kernelCell must be a vector cell array of prtKernels')
            end
            
            %Set the internal action cell correctly
            Obj.kernelCell = aCell;
        end
        
    end
    
    methods (Hidden = true)
        function [nDimensions,nDimensionsArray] = nDimensions(Obj)
            
            nDimensionsArray = nan(length(Obj.kernelCell),1);
            for i = 1:length(Obj.kernelCell)
                nDimensionsArray(i) = Obj.kernelCell{i}.nDimensions;
            end
            nDimensions = sum(nDimensionsArray);
        end
        
        function Obj = retainKernelDimensions(Obj,keepLogical)
            
            if ~islogical(keepLogical)
                temp = false(1,Obj.nDimensions);
                temp(keepLogical) = true;
                keepLogical = temp;
            end
            
            start = 1;
            for i = 1:length(Obj.kernelCell)
                nDimensions = Obj.kernelCell{i}.nDimensions;
                Obj.kernelCell{i} = Obj.kernelCell{i}.retainKernelDimensions(keepLogical(start:start+nDimensions-1));
                start = start+nDimensions;
            end
        end
        
    end
    
    methods (Hidden = true)
        function h = plot(Obj)
            %Plot each kernel:
            h = zeros(length(Obj.kernelCell),1);
            for i = 1:length(Obj.kernelCell)
                hT = Obj.kernelCell{i}.plot;
                if ~isempty(hT)
                    h(i) = hT;
                end
            end
        end
    end
    
    methods (Hidden = true)
        function kernelCell = getKernelCell(Obj)
            kernelCell = Obj.kernelCell;
        end
    end
end
