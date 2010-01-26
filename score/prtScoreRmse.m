function rmse = prtScoreRmse(Guess,Truth)
%rmse = prtScoreRmse(Guess,Truth)

yHat = Guess.getObservations;
y = Truth.getTargets;

if size(yHat,2) == 1
    rmse = sqrt(mean((yHat-y).^2));
else %M-ary regression
    eSquared = (yHat-y).^2;
    rmse = sqrt(mean(eSquared(:)));
end