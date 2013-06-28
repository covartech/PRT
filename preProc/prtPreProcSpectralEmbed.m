classdef prtPreProcSpectralEmbed < prtPreProc
    % prtPreProcSpectralEmbed  Spectral Embedding
    %
    %   SpectralEmbed = prtPreProcSpectralEmbed creates a Spectral Embed object.
    %
    %   spectralEmbed = prtPreProcSpectralEmbed(PROPERTY1, VALUE1, ...) constructs a
    %    prtPreProcSpectralEmbed object CLASSIFIER with properties as specified by
    %    PROPERTY/VALUE pairs.
    %
    %    A prtpreProcSpectralEmbed object inherits all properties from the abstract
    %    class prtPreProc. In addition is has the following properties:
    %
    %          nEigs - Number of EigenVectors (columns in Spectral Space)
    %
    %          sigma - RBF Kernel Parameter
    %
    %   Example:
    %
    %   dataSet = prtDataGenMoon;                           % Load a data set
    %   spectralEmbed = prtPreProcSpectralEmbed;            % Create a prtPreProcSpectralEmbed object
    %   zmuv=prtPreProcZmuv;                                % Create a prtPreProcZmuv object
    %   algo=zmuv+spectralEmbed;                            % Combine prtPreProcSpectralEmbed and prtPreProcZmuv objects
    %
    %
    %   algo = algo.train(dataSet);       % Train the prtPreProcPca object
    %   dataSetNew = algo.run(dataSet);   % Run
    %
    %   % Plot
    %   plot(dataSet);              % Plot Original Data
    %   title('Original Data');
    %   figure;
    %   plot(dataSetNew);           % Plot Spectral Embed Data
    %   title('Spectral Embedded Data');
    %
    %   See Also: prtPreProc, prtPreProcPca, prtPreProcPls,
    %   prtPreProcHistEq, prtPreProcZeroMeanColumns, prtPreProcLda,
    %   prtPreProcZeroMeanRows, prtPreProcLogDisc, prtPreProcZmuv,
    %   prtPreProcMinMaxRows
    
    
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
        name = 'Spectral Embed'  % Spectral
        nameAbbreviation = 'Spectral'  % Spectral
    end
    
    properties
        
        nEigs = 2;
        sigma =.2;
        
    end
    
    properties (SetAccess=private)
        % General Classifier Properties
        Gram=[]; %Gram Matrix
        D=[];   %Diagonal (Sum of each row)
        L=[];   %D^(-1/2)*Gram.X*D^(-1/2);
        X=[];   %Stacked Eigenvectors
        eigValues=[];
        eigVectors=[];
        
        
    end
    
    methods
        function Obj = prtPreProcSpectralEmbed(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    
    methods (Access=protected,Hidden=true)
        
        function Obj = trainAction(Obj,DataSet)
            
            [Obj.eigValues, Obj.eigVectors] = prtUtilSpectralDimensionalityReduction(DataSet.X, Obj.nEigs,'sigma',Obj.sigma);          %Spectral dimensionality reduction
            
        end
        
        function DataSet = runAction(Obj,DataSet)
            
            DataSet.X=prtUtilSpectralOutOfSampleExtension(Obj.dataSet.X,DataSet.X,Obj.eigVectors,Obj.eigValues,Obj.sigma);
    
        end
    end
end
