classdef prtClassMaryEmulateOneVsAll < prtClass
    
    properties (SetAccess=private)
        % Required by prtAction
        name = 'M-Ary Emaulation One vs. All'
        nameAbbreviation = 'OVA'
        isSupervised = true;
        
        % Required by prtClass
        isNativeMary = true;
    end
    
    properties
        % General Classifier Properties
        Classifiers = prtClassFld; % will be repmated as needed
    end
    
    methods
        
        function Obj = prtClassMaryEmulateOneVsAll(varargin)
            if nargin == 0
                % Nothing to do
            end
        end
    end
    
    methods (Access = protected)
        
        function Obj = trainAction(Obj,DataSet)
            % Repmat the Classifier objects to get one for each class
            Obj.Classifiers = repmat(Obj.Classifiers(:), (DataSet.nClasses - length(Obj.Classifiers)+1),1);
            Obj.Classifiers = Obj.Classifiers(1:DataSet.nClasses);
            
            for iY = 1:DataSet.nClasses
                % Replace the targets with binary targets for this class
                cDataSet = DataSet.setTargets(DataSet.getTargetsAsBinaryMatrix(:,iY));
                
                % We need the classifier to act like a binary and we dont 
                % want a bunch of DataSets lying around
                Obj.Classifiers(iY).verboseStorage = false;
                Obj.Classifiers(iY).twoClassParadigm = 'binary';
                
                % Train this Classifier
                Obj.Classifiers(iY) = train(Obj.Classifiers(iY), cDataSet);
            end
        end

        function DataSetOut = runAction(Obj,DataSet)
            DataSetOut = prtDataSet(zeros(DataSet.nObservations, length(Obj.Classifiers)));
            
            for iY = 1:length(Obj.Classifiers)
                cOutput = run(Obj.Classifiers(iY), DataSet);
                
                % This is wacky looking because of the colon.
                % setObservations() lets you set all rows or columns using :
                DataSetOut = DataSetOut.setObservations(cOutput.getObservations(),:,iY);
            end
        end
        
    end
    
end