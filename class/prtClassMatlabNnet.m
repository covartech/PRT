classdef prtClassMatlabNnet < prtClass
    % prtClassMatlabNnet  Support vector machine classifier using the MATLAB neural network toolbox (requires NNET toolbox)
    %
    %   CLASSIFIER = prtClassMatlabNnet returns a neural network classifier
    %   using the MATLAB NNET toolbox (additonal product, not included)
    %
    %  A prtClassMatlabNnet object inherits all properties from the
    %  abstract class prtClass. In addition is has the following
    %  properties; complete documentation for these properties can be found
    %  in the help for the newpr.m function in the MATLAB NNET toolbox.
    %
    %   Si, TFi, BTF, BLF, PF, IPF, OPF, DDF
    %
    % % Example usage:
    %
    %   TestDataSet = prtDataGenBimodal;       % Create some test and
    %   TrainingDataSet = prtDataGenBimodal;   % training data
    %   classifier = prtClassMatlabNnet;           % Create a classifier
    %   classifier = classifier.train(TrainingDataSet);    % Train
    %   classified = run(classifier, TestDataSet);         % Test
    %   subplot(2,1,1);
    %   classifier.plot;
    %   subplot(2,1,2);
    %   [pf,pd] = prtScoreRoc(classified,TestDataSet);
    %   h = plot(pf,pd,'linewidth',3);
    %   title('ROC'); xlabel('Pf'); ylabel('Pd');
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
        name = 'MATLAB Neural Network' % MATLAB Neural Network
        nameAbbreviation = 'MLNN'            % MLNN
        isNativeMary = true;  % True
    end
    
    properties 
        nnet % The base neural network
        
    end
    properties 
        Si = 20;  %Number of layers in hidden element
        TFi = []; % See help for newpr
        BTF = [];% See help for newpr
        BLF = [];% See help for newpr
        PF = [];% See help for newpr
        IPF = [];% See help for newpr
        OPF = [];% See help for newpr
        DDF = [];% See help for newpr
    end

    methods 
               % Allow for string, value pairs
        function Obj = prtClassMatlabNnet(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
        
        function Obj = set.Si(Obj,val)
            assert(isvector(val) && isnumeric(val) && all(val == round(val)) && all(val > 0),'prt:prtClassMatlabNnet:Si','Si must be a numeric vector of int-valued doubles greater than 0, but value provided was %s',mat2str(val));
            Obj.Si = val;
        end
    end
    
    methods (Access=protected, Hidden = true)
        
        function Obj = trainAction(Obj,DataSet)
            
            paramNames = {'Obj.TFi','Obj.BTF','Obj.BLF','Obj.PF','Obj.IPF','Obj.OPF','Obj.DDF'};
            cellParams = {Obj.TFi,Obj.BTF,Obj.BLF,Obj.PF,Obj.IPF,Obj.OPF,Obj.DDF};
            nParams = 0;
            
            for i = length(cellParams):-1:1
                if ~isempty(cellParams{i}) && any(cellfun(@isempty,cellParams(1:i-1)))
                    val = cellfun(@isempty,cellParams(1:i-1));
                    error('prt:prtClassMatlabNnet','Parameter %s is set, but required parameter %s is not set',paramNames{i},paramNames{val});
                end
                if ~isempty(cellParams{i})
                    nParams = i;
                end
            end
            Obj.nnet = newpr(DataSet.getObservations',DataSet.getTargetsAsBinaryMatrix',Obj.Si,cellParams{1:nParams});
            
            Obj.nnet = train(Obj.nnet,DataSet.getObservations',DataSet.getTargetsAsBinaryMatrix');
        end
        
        function DataSet = runAction(Obj,DataSet)
            yOut = sim(Obj.nnet,DataSet.getObservations');
            DataSet = prtDataSetClass(yOut');
        end
        
    end
end
