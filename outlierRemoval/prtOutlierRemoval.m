classdef prtOutlierRemoval < prtAction
    % prtOutlierRemoval Base class for prt Outlier Removal objects
    %
    %   prtOutlierRemoval is an abstract class and cannot be instantiated.
    %
    %   All prtOutlierRemoval objects inherit all properities and methods
    %   from the prtAction object. prtOutlierRemoval objects have the
    %   following additional properties:
    %
    %   runMode - Specify how the outlier removal processing behaves when
    %   run on a data set.  runMode specifies how the action behaves during
    %   typical calls to RUN. Valid strings are as follows:
    %
    %       'noAction' - When running the outlier removal action, do
    %       nothing.  This ensures that the outlier removal action outputs
    %       data sets of the same size as the input data set.
    %
    %       'replaceWithNan' - When running the outlier removal action
    %       replace outlier values with nans.  This ensures that the
    %       outlier removal action outputs data sets of the same size as
    %       the input data set.
    %
    %       'removeObservation' - When running the outlier removal action,
    %       remove observations where any feature value is flagged as an
    %       outlier.  Note: This can change the size of the data set during
    %       running and can result in invalid cross-validation folds.
    %
    %       'removeFeature'  - When running the outlier removal action,
    %       remove features where any observation contains an outlier.
    %       
    %   runOnTrainingMode - A string specifying how the outlier removal
    %   method should behave when being run during the training of a
    %   prtAlgorithm.  See above for a more detailed description, and a
    %   list of valid runOnTrainingMode string values.  Default value is
    %   'removeObservation'.
    %
    %
    %   See Also: prtPreProc, prtOutlierRemovalNstd,
    %   prtOutlierRemovalMissingData, prtPreProcPca, prtPreProcPls,
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


    %   Internal help info:
    %   prtClass objects have the following Abstract methods:
    %
    %   runOnTrainingMode -  specifies how the action should
    %   behave when the outlier removal object is embedded in a
    %   prtAlgorithm.  The distinction between runOnTrainingMode and
    %   runMode enables outlier removal during training to modify how
    %   prtActions down-stream of the outlier removal object are trained,
    %   while maintaining valid cross-validation folds during RUN.
    %   runOnTrainingMode can be set to same set of values as runMode.
    %
    %   A prtOutlierRemoval object inherits the TRAIN, RUN, CROSSVALIDATE
    %   and KFOLDS functions from the prtAction class.
    %
    %   See Also:  prtOutlierRemoval, prtOutlierRemovalMissingData
    %   prtOutlierRemovalNonFinite,prtOutlierRemovalNstd
    
    %
    %   prtOutlierRemoval objects have the following Abstract methods:
    %
    %   calculateOutlierIndices - An abstract method that all concrete
    %   sub-classes define.  calculateOutlierIndices takes the form:
    %
    %       indices = calculateOutlierIndices(Obj,DataSet)
    %
    %   where indices is a logical matrix of size DataSet.nObservations x
    %   DataSet.nFeatures.  The (i,j) element of indices specifies whether
    %   that element of DataSet is an outlier.
    
    methods (Abstract, Access = protected, Hidden = true)
        indices = calculateOutlierIndices(Obj,DataSet)
    end
    
    properties
        runOnTrainingMode = 'removeObservation';  %Operation taken during TRAIN
        runMode = 'noAction';                     %Operation taken during RUN
        replaceValue = nan;
    end
    properties (Constant = true)
        validModes = {'noAction','replaceWithNan','removeObservation','removeFeature','replaceWithValue'};
    end
    properties (SetAccess = protected)
        isSupervised = false; % False
        isCrossValidateValid = true; % False
    end
    
    methods
        function indices = getOutlierIndices(Obj,DataSet)
            indices = Obj.calculateOutlierIndices(DataSet);
        end
        function obj = prtOutlierRemoval()
            % As an action subclass we must set the properties to reflect
            % our dataset requirements
            obj.classTrain = 'prtDataSetStandard';
            obj.classRun = 'prtDataSetStandard';
            obj.classRunRetained = true;
        end
        
        function Obj = set.runOnTrainingMode(Obj,string)
            if ~any(strcmpi(string,Obj.validModes))
                error('prtOutlierRemoval:runOnTrainingMode','runOnTrainingMode must be one of the follwing strings: {%s}',sprintf('%s ',Obj.validModes{:}));
            end
            Obj.runOnTrainingMode = string;
        end
        
        function Obj = set.runMode(Obj,string)
            if ~any(strcmpi(string,Obj.validModes))
                error('prtOutlierRemoval:runOnTrainingMode','runOnTrainingMode must be one of the follwing strings: {%s}',sprintf('%s ',Obj.validModes{:}));
            end
            Obj.runMode = string;
            if strcmpi(Obj.runMode,'removeObservation')
                Obj.isCrossValidateValid = false;
            end
        end
    end
    
    methods (Access = protected, Hidden = true)
        
        function [DataSet,inds] = runAction(Obj,DataSet)
            [DataSet,inds] = outlierRemovalRun(Obj,DataSet,Obj.runMode);
        end
        
        function [DataSet,inds] = runActionOnTrainingData(Obj,DataSet)
            [DataSet,inds] = outlierRemovalRun(Obj,DataSet,Obj.runOnTrainingMode);
        end
        
        function [DataSet,ind] = outlierRemovalRun(Obj,DataSet,mode)
            ind = [];
            switch mode
                case 'noAction'
                    return;
                case 'removeObservation'
                    ind = Obj.calculateOutlierIndices(DataSet);
                    if ~islogical(ind)
                        error('prtOutlierRemoval:invalidCalculateOutlierIndices','prtOutlierRemoval objects calculateOutlierIndices method must output a logical array of size dataSet.nObservations x dataSet.nFeatures');
                    end
                    removeInd = any(ind,2);
                    DataSet = DataSet.removeObservations(removeInd);
                case 'removeFeature'
                    ind = Obj.calculateOutlierIndices(DataSet);
                    removeInd = any(ind,1);
                    DataSet = DataSet.removeFeatures(removeInd);
                case 'replaceWithNan'
                    ind = Obj.calculateOutlierIndices(DataSet);
                    x = DataSet.getObservations;
                    x(ind) = nan;
                    DataSet = DataSet.setObservations(x);
                case 'replaceWithValue'
                    ind = Obj.calculateOutlierIndices(DataSet);
                    x = DataSet.getObservations;
                    x(ind) = Obj.replaceValue;
                    DataSet = DataSet.setObservations(x);
                otherwise 
                    error('invalid string');
            end
        end
        
        %Overloads prtAction/postRunProcessing
        function DataSetOut = postRunProcessing(ClassObj, twiddle, DataSetOut, twiddle2) %#ok<MANU>
            %
            
            %It's not necessary to do anything; but we can't rely on
            %prtAction's postRunProcessing to not try something overly
            %clever here.
        end
        
    end
end
