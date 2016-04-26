% prtRvUtilLogForwardsBackwards
% Runs the forward backwards algorithm in a robust manner everything is
% done in log space
%
% Inputs:
%   log pi - 1 x nStates
%   log transition matrix - nStates x nStates
%   log component log likelihoods - nObservations x nStates
%
% Outputs:
%   alpha - Forward variable - nObservations x nStates
%   beta - Backwards variables  - nObservations x nStates
%   gamma - State probability by time - nObservations x nStates 
%   xi - state transition probability by time - nStates x nStates x nObservations





%   xi - state transition probability by time - nStates x nStates x nObservations

