function logLoss = prtScoreLogLoss(dataSet1,dataSet2)
% prtScoreLogLoss - Logarithmic loss function
%   
%   logLoss = prtScoreLogLoss(dataSet) score the logarithmic loss for the
%   estimates in dataSet.X of the targets in dataSet.Y.  Lower log-loss
%   indicates better performance.
%
%   If x_{i} and y_{i} represent the estimate and true (0/1) value, then
%   the log-loss is defined as:
%
%       ll = -1*mean( y_{i}log(x_{i}) + (1-y_{i})*log(1-x_{i}) )
%   
%   The log-loss penalizes being "confident and wrong" more than being
%   somewhat wrong - e.g., if the true value is 1, and the guess is 0.001,
%   the log-loss for that example is 6.9.  
%
%   In practice, some algorithms can provide guesses that become
%   arbitrarily close to 1 and 0.  These can result in unbounded
%   log-losses.  prtScoreLogLoss enforces a limit so that no guess is
%   larger or smaller than 0.999 or 0.001.  
%
%   Note that log-loss assumes that the guesses are bounded in [0,1] and
%   the labels also take values 0 or 1.  If either of these is violated,
%   the log-loss is meaningless.
%
%   See: https://www.kaggle.com/wiki/LogarithmicLoss for more information.
%
%    See also prtScoreConfusionMatrix, prtScoreRmse, prtScoreRocNfa,
%             prtScorePercentCorrect, prtScoreAuc








% Based on the algorithm provided here:
% https://www.kaggle.com/wiki/LogarithmicLoss
if nargin < 2
    dataSet2 = dataSet1;
end 

[guess,truth] = prtUtilScoreParseFirstTwoInputs(dataSet1,dataSet2);
if unique(truth(:)) ~= [0;1];
    error('prt:LogLoss:InvalidLabels','prtScoreLogLoss only defined for binary data sets, but unique(y) is %s',[mat2str(unique(truth(:)))]);
end

delta=0.001; %arbitrary value, may be model tuning parameter  
guess=min(max(guess,delta),1-delta); 
logLoss=-mean(truth.*log(guess)+(1-truth).*log(1-guess));  

