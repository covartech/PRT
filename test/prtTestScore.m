function result = prtTestScore
% This function tests a few of the prtScore functions such as:
% prtScorePercentCorrect

result = true;

%% Positive checks, these should work

% try binary labels
guess = [0 1 1 0]';
truth = [1 0 1 0]';

if(prtScorePercentCorrect(guess, truth) ~= .5)
    result = false;
    disp('prtScorePercent binary correct wrong answer')
end

% Try m-ary
guess = [0 1 2 3 ]';
truth = [0 1 4 3]';
if(prtScorePercentCorrect(guess, truth) ~= .75)
    result = false;
    disp('prtScorePercentM-ary correct wrong answer')
end

%%  These things should error 
error = true;

guess = [0 1 1 0];
truth = [1 0 1 0];
try 
    prtScorePercentCorrect(guess,truth);
    error = false;
    disp('prtScorePercentCorrect wrong orientation')
catch
   % no-op
end

guess = [0 1 1 0];
truth = [1 0 1 1 0];
try 
    prtScorePercentCorrect(guess,truth);
    error = false;
    disp('prtScorePercentCorrect wrong orientation')
catch
   % no-op
end