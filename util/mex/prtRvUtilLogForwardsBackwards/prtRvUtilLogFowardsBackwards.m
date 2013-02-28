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
%   xi - state transition probability by time - nStates x nStates x nObservations

