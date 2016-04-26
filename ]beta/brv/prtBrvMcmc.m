% prtBrvMc - Bayesian Random Variable Monte Carlo





classdef prtBrvMcmc

    methods (Abstract)
        [self, training, samples] = mcmc(self, x);
    end
    
    properties
        mcmcTotalIterations = 2e3; % Total number of iterations
        mcmcDiscardIterations = 1e3; % The first mcmcDiscardIterations will be removed
        mcmcRetainEveryOtherItation = 5; % Draw 1:mcmcRetainEveryOtherItation:end will be retained
        mcmcVerboseText = false; % display text
        mcmcVerbosePlot = false; % plot after each iteration
        mcmcVerboseMovie = false; % make a movie with each frame of plotting
        mcmcVerboseMovieFrames = []; % Where we store the frames
    end
end
