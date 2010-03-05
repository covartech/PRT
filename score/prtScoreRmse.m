function rmse = prtScoreRmse(Guess,Truth)
%rmse = prtScoreRmse(Guess,Truth)

if isa(Guess,'prtDataSet')
    yHat = Guess.getObservations;
    y = Truth.getTargets;
elseif isa(Guess,'double')
    yHat = Guess;
    y = Truth;
end

if size(yHat,2) == 1
    rmse = sqrt(mean((yHat-y).^2));
else %M-ary regression
    eSquared = (yHat-y).^2;
    rmse = sqrt(mean(eSquared(:)));
end