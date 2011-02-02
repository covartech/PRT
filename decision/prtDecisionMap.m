classdef prtDecisionMap < prtDecision
    % prtDecisionMap Maximum a-posteriori decision making
    %
    % prtDec = prtDecisionMap creates a prtDecisionBinaryMap
    % object, which can be used to perform Maximu a-posteriori decions.
    %
    % prtDecision objects are intended to be used either as members of
    % prtAlgorithm or prtClass objects.
    %
    % Example 1:
    %
    % ds = prtDataGenMary;                    % Load a data set
    % classifier = prtClassKnn;            % Create a clasifier
    % classifier = classifier.train(ds);   % Train the classifier
    % yOutClassifier = classifier.run(ds); % Run the classifier
    %
    % % Construct a prtAlgorithm object consisting of a prtClass object and
    % % a prtDecision object
    % algo = prtClassKnn + prtDecisionMap; 
    %
    % algo = algo.train(ds);        % Train the algorithm    
    % yOutAlgorithm = algo.run(ds); % Run the algorithm
    % 
    % % Plot and compare the results
    % subplot(2,1,1); stem(yOutClassifier.getObservations); title('KNN Output');
    % subplot(2,1,2); stem(yOutAlgorithm.getObservations); title('KNN + Decision Output');
    %
    % Example 2:
    %
    % ds = prtDataGenMary;              % Load a data set
    % classifier = prtClassKnn;            % Create a clasifier
    % classifier = classifier.train(ds);   % Train the classifier
    %
    % % Plot the trained classifier
    % subplot(2,1,1); plot(classifier); title('KNN');
    %
    % % Set the classifiers internealDecider to be a prtDecsion object
    % classifier.internalDecider = prtDecisionMap;
    %
    % classifier = classifier.train(ds); % Train the classifier
    % subplot(2,1,2); plot(classifier); title('KNN + Decision');
    %    	
    % See also: prtDecisionBinary, prtDecisionBinarySpecifiedPd,
    % ptDecisionBinarySpecifiedPf, prtDecisionMap

    % See also: prtDecisionBinaryMinPe, prtDecisionBinarySpecifiedPd,
    % ptDecisionBinarySpecifiedPf, prtDecisionMap

     properties (SetAccess = private)
        name = 'MAP'
        nameAbbreviation = 'MAP';
    end
    
    methods
        function Obj = prtDecisionMap(varargin)
            Obj = prtUtilAssignStringValuePairs(Obj,varargin{:});
        end
    end
    methods (Access=protected,Hidden=true)
        
        function Obj = trainAction(Obj, DS)
            Obj.classList = DS.uniqueClasses;
        end
        function DS = runAction(Obj,DS)
            yOut = DS.getObservations;
            if size(yOut,2) > 1
                [~,index] = max(yOut,[],2);
            else
                error('prt:prtDecisionMap','Cannot run prtDecisionMap on algorithms with single-column output; use prtDecisionBinaryMinPe instead');
            end
            classList = Obj.classList(index);
            classList = classList(:);
            DS = DS.setObservations(classList);
        end
    end
end