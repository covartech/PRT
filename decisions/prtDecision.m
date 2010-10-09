classdef prtDecision < prtAction
    % Decisions take the ooutputs of classifiers or clusterers and turn
    % them into class labels (or cluster labels).  The output of a decider
    % object's run function is always a nObservations x 1 data set where
    % the observations are integer valued and specify the hypothesized
    % class for each observation
    %
    % Decisions can be used in two ways - either as part of an algorithm:
    %
    % algo = prtClassKnn + prtDecisionBinaryMinPe;
    %
    % Or as the internalDecider object inside a prtClass object:
    %
    % myKnn = prtClassKnn;
    % myKnn.internalDecider = prtDecisionBinaryMinPe;
    %
    % In the first case, the resulting object is a prtAlgorithm, which
    % changes the behavior of "PLOT", for example.  In the second case, the
    % decision is incorporated into the classifier, and the decision
    % contours can be plotted easily.  Compare:
    %
    % dsTrain = prtDataGenUnimodal;
    % dsTest = prtDataGenUnimodal;
    % algo = algo.train(dsTrain);
    % myKnn = myKnn.train(dsTrain);
    % 
    % plot(algo); title('Algorithm implementation'); drawnow;
    % pause(3);
    % plot(myKnn); title('internalDecider implementation'); drawnow;
    %
    % Note that the regardless of how one uses a decider, the outputs of
    % algo.run(dsTest) and myKnn.run(dsTest) should be identical;
    
    properties (Hidden)
        classList
    end
    methods
        function obj = set.classList(obj,val)
            obj.classList = val(:);
        end
        function c = get.classList(obj)
            if isempty(obj.classList)
                error('Plotting prtDecisions in cluster methods requires that classList be manually set in postTrainProcessing');
            end
            c = obj.classList;
        end
    end
end