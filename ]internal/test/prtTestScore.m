function result = prtTestScore
% This function tests a few of the prtScore functions such as:
% prtScorePercentCorrect

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


result = true;

%% Positive checks, these should work

% try binary labels
guess = [0 1 1 0]';
truth = [1 0 1 0]';

if(prtScorePercentCorrect(guess, truth) ~= .5)
    result = false;
    disp('prtScorePercent binary correct wrong answer')
end

if(prtScoreRmse(guess, truth) ~= sqrt(2)/2)
    result = false;
    disp('prtScorePercentCorrect wrong answer')
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

try
    prtScoreRmse(guess,truth);
    error = false;
    disp('prtScoreRmse wrong orientation')
catch
    % no-op
end


guess = [0 1 1 0]';
truth = [1 0 1 1 0]';
try
    prtScorePercentCorrect(guess,truth);
    error = false;
    disp('prtScorePercentCorrect wrong size')
catch
    % no-op
end
try
    prtScoreRmse(guess,truth);
    error = false;
    disp('prtScoreRmse wrong size')
catch
    % no-op
end
%% test prtScoreCost

TestDataSet = prtDataGenSpiral;       % Create some test and
TrainingDataSet = prtDataGenSpiral;   % training data
classifier = prtClassGlrt;             % Create a classifier
classifier = classifier.train(TrainingDataSet);    % Train
classified = run(classifier, TestDataSet);
% Find the minimum cost
C = prtScoreCost(classified.getX, TestDataSet.getY, [1 .1; .1 1]);

if (C ~= .55 )
    disp('prtScoreCost wrong value')
    result = false;
end


%% test prtScoreRoc etc...
TestDataSet = prtDataGenSpiral;       % Create some test and
TrainingDataSet = prtDataGenSpiral;   % training data
classifier = prtClassGlrt;             % Create a classifier
classifier = classifier.train(TrainingDataSet);    % Train
classified = run(classifier, TestDataSet);

% Ensure basic operation doesn't fail
try
    prtScoreRoc(classified.getX(), TrainingDataSet.getY())
    close;
catch
    result = false;
    disp('prtScoreRoc basic fail')
end

% Ensure basic operation doesn't fail
try
    [nfa] = prtScoreRocNfa(classified.getX(), TrainingDataSet.getY());
    
catch
    result = false;
    disp('prtScoreRocNfa basic fail')
end

if(min(nfa) ~= 0) || (max(nfa) ~= 200)
    result = false;
    disp('prtScoreNfa wrong ans')
end


% try
%     prtScoreRocBayesianBootstrap(classified.getX(), TrainingDataSet.getY(), 100,100,5);
%     
%     close;
%     disp('prtScoreRocBayesianBootstrap check alpha fail')
%     result = false;
% catch
%     
%     close
% end
% 
% 
% try
%     prtScoreRocBayesianBootstrapNfa(classified.getX(), TrainingDataSet.getY(), 100,100,.1);
%     close;
% catch
%     result = false;
%     disp('prtScoreRocBayesianBootstrapNfa basic fail')
% end
% 
% 
% % Ensure basic operation doesn't fail
% try
%     [nfa] = prtScoreRocBayesianBootstrapNfa(classified.getX(), TrainingDataSet.getY(), 100,100,.1);
%     
% catch
%     result = false;
%     disp('prtScoreRocBayesianBoostrapNfa basic fail')
% end
% 
% if(min(nfa) ~= 0) || (max(nfa) ~= 200)
%     result = false;
%     disp('prtScoreBayesianBootstapNfa wrong ans')
% end
% 
% try
%     prtScoreRocBayesianBootstrapNfa(classified.getX(), TrainingDataSet.getY(), 100,100,5);
%     close;
%     result = false;
%     disp('prtScoreRocBayesianBootstrap check alpha fail')
% catch
%     close
%     
% end




