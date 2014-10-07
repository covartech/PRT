classdef prtClassGeneticProgram < prtClass

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


    properties (SetAccess=private)
        name = 'Genetic Program'
        nameAbbreviation = 'GP'
        isNativeMary = false; 
    end
    
    properties
        availableOperations = {@(x,y)plus(x,y),...
                               @(x,y)minus(x,y),...
                               @(x,y)times(x,y),...
                               @(x,y)rdivide(x,y),...
                               @(x,y)real(power(x,y))}; % wrap real() around power so that we inherently avoid complex here rather than handling it elsewhere in the code.
        availableOperationsStrings = {'%s + %s'...
                                      '%s - %s'...
                                      '%s * %s'...
                                      '%s / %s'...
                                      'Re[%s^{%s}]'};
        availableOperationsStringsLatex = {'%s + %s'...
                                      '%s - %s'...
                                      '%s \\cdot %s'...
                                      '\\frac{%s}{%s}'...
                                      '\\Re\\left[ %s^{%s} \\right]'};
%         availableOperations = {@(x,y)plus(x,y),...
%                                @(x,y)minus(x,y),...
%                                @(x,y)times(x,y),...
%                                @(x,y)rdivide(x,y),...
%                                @(x,y)real(power(x,y)),... % wrap real() around power so that we inherently avoid complex here rather than handling it elsewhere in the code.
%                                @(x,y)cos(x),...
%                                @(x,y)exp(x),...
%                                @(x,y)log(abs(x))};
%         availableOperationsStrings = {'%s + %s'...
%                                       '%s - %s'...
%                                       '%s * %s'...
%                                       '%s / %s'...
%                                       'Re[%s^{%s}]'...
%                                       'cos(%s)'...
%                                       'exp(%s)'...
%                                       'log(|%s|)'};
%         availableOperationsStringsLatex = {'%s + %s'...
%                                       '%s - %s'...
%                                       '%s \\cdot %s'...
%                                       '\\frac{%s}{%s}'...
%                                       '\\Re\\left[ %s^{%s} \\right]'...
%                                       '\\cos\\left(%s\\right)'...
%                                       '\\exp\\left(%s\\right)'...
%                                       '\\log\\left(\\lvert%s\\rvert\\right'};
        useLatexStringsByDefault = false;
        ephemeralRandomConstantProb = []; % with this probability an ERC will be selected as input argument rather than an input variable, if it is empty it will selected with probabilty 1/(n+1) where n is the number input features
        ephemeralRandomConstantFunction = @()10*randn(1)
        maxTreeDepth = 3;
        maxCrossoverTries = 10;
        nOrganisms = 500;
        organisms = []; % will be initialized during trainAction
        fitnessFunction = @(x,y)prtScoreAuc(x,y);
        fitnesses = []; % will be initialized during trainAction
        nBootstrapSamplesForFitness = [];
        nGenerations = 10;
        
        bestOrganism = [];
        bestFitness = [];
        selectionMethod = 'tournament'; % Or roulette
        selectionTournamentBootstrapOrganisms = 5;
        grandfatherProb = 0.05; % Top percent go on untouched
        randomImmigrantProb = 0.05; % Bottom percent get replaced by random trees
        mutationProbability = 0.01;  % Less than 10 for sure
        verbosePlot = false;
    end
    
    properties (Dependent, SetAccess='protected')
        nOperations
    end
    properties (SetAccess = 'protected',Hidden = true)
        nInputs = [];
        ercProb = []; % Actual used (will match the above if the above is empty)
    end
    
    
    methods 
        function self = prtClassGeneticProgram(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        function self = initOrganisms(self)
            for iOrganism = 1:self.nOrganisms
                cOrganism = generateOrganism(self);
                if iOrganism == 1
                    self.organisms = repmat(cOrganism,self.nOrganisms,1);
                else
                    self.organisms(iOrganism) = cOrganism;
                end
            end
        end
    end
    
    methods (Access=protected, Hidden = true)
        function self = trainAction(self,ds)
            
            self.nInputs = ds.nFeatures;
            if isempty(self.ephemeralRandomConstantProb)
                self.ercProb = 1/(self.nInputs+1);
            else
                self.ercProb = self.ephemeralRandomConstantProb;
            end
            
            if isempty(self.organisms)
                self = initOrganisms(self);
            end
            
            nGrandfathers = round(self.grandfatherProb.*self.nOrganisms); % Top percent go on untouched
            nImmigrants = round(self.randomImmigrantProb.*self.nOrganisms); % Bottom percent get replaced by random trees
            
            nOffspring = self.nOrganisms-nGrandfathers - nImmigrants;
            
            allFitnesses = zeros(self.nOrganisms,self.nGenerations);
            for iGen = 1:self.nGenerations
            
                self.fitnesses = zeros(self.nOrganisms,1);
                cY = ds.getY;
                for iOrg = 1:self.nOrganisms
                    cOut = self.evalOrganism(self.organisms(iOrg), ds);
                    
                    if size(cOut,1) ~= ds.nObservations
                        self.fitnesses(iOrg) = nan;
                    else
                        if ~isempty(self.nBootstrapSamplesForFitness)
                            cBootStrapSamples = prtRvUtilRandomSample(size(cOut,1), self.nBootstrapSamplesForFitness);
                            cOut = cOut(cBootStrapSamples);
                            cY = ds.getY(cBootStrapSamples);
                        end
                        
                        self.fitnesses(iOrg) = self.fitnessFunction(cOut, cY);
                    end
                end
                
                nanOrgs = isnan(self.fitnesses);
                workingFitnesses = self.fitnesses;
                workingFitnesses(nanOrgs) = -inf;
                [sortedFitness, fitnessOrder] = sort(workingFitnesses,'descend'); %#ok<ASGLU>
                
                [self.bestFitness, bestOrganismInd] = max(workingFitnesses);
                self.bestOrganism = self.organisms(bestOrganismInd);
                
                if iGen ~= self.nGenerations % Not last iteration
                    oldOrganisms = self.organisms;
                    newOrganisms = oldOrganisms;
                
                    newOrganisms(1:nGrandfathers) = oldOrganisms(fitnessOrder(1:nGrandfathers));
                    for iImm = 1:nImmigrants
                        newOrganisms(nGrandfathers + nOffspring + iImm) = generateOrganism(self);
                    end
                    
                    switch lower(self.selectionMethod)
                        case 'roulette'
                            % Roulette
                            %   cumsum of all the scores ./ sum() -> between [0 1]
                            %   rand pick a bin
                            %   once for a mother once for a father
                            %
                            %   starts to favor the initial popultaion
                            useableFitnesses = isfinite(workingFitnesses);
                            if any(~useableFitnesses)
                                error('Non finite fitnesses have been found consider using tournament')
                            end
                            normFit = cat(1,0,cumsum(self.fitnesses)./sum(self.fitnesses(:)));
                            
                            for iOff = 1:nOffspring
                                cMother = oldOrganisms(find(rand > normFit,1,'last'));
                                cFather = oldOrganisms(find(rand > normFit,1,'last'));
                                
                                newOrg = self.crossoverOrganisms(cMother, cFather);
                                
                                if rand < self.mutationProbability
                                    newOrg = self.mutateOrganism(newOrg);
                                end
                                
                                newOrganisms(nGrandfathers + iOff) = newOrg;
                            end
                        case 'tournament'
                            % Tournament
                            %   Pick N organisms at random, pick the max for the mother
                            %   Repeat for the father
                            %
                            %   slower in the beginning but explores out better
                            for iOff = 1:nOffspring
                                
                                cInds = prtRvUtilRandomSample(self.nOrganisms,self.selectionTournamentBootstrapOrganisms);
                                [maxFits, cIndsInd] = max(self.fitnesses(cInds)); %#ok<ASGLU>
                                cMother = oldOrganisms(cInds(cIndsInd));
                                
                                cInds = prtRvUtilRandomSample(self.nOrganisms,self.selectionTournamentBootstrapOrganisms);
                                [maxFits, cIndsInd] = max(self.fitnesses(cInds)); %#ok<ASGLU>
                                cFather = oldOrganisms(cInds(cIndsInd));
                                
                                for crossOverIter = 1:self.maxCrossoverTries
                                    newOrg = self.crossoverOrganisms(cMother, cFather);
                                    if any(newOrg.depths > self.maxTreeDepth+1)
                                        if crossOverIter == self.maxCrossoverTries
                                            if rand < .5
                                                newOrg = cFather;
                                            else
                                                newOrg = cMother;
                                            end
                                            break
                                        else
                                            continue;
                                        end
                                    else
                                        break;
                                    end
                                end 
                                
                                if rand < self.mutationProbability
                                    newOrg = self.mutateOrganism(newOrg);
                                end
                                
                                newOrganisms(nGrandfathers + iOff) = newOrg;
                            end
                        otherwise
                            error('unknown selectionMethod')
                    end
                    
                    self.organisms = newOrganisms;
                    
                end
                if self.verbosePlot
                    allFitnesses(:,iGen) = self.fitnesses;
                
                    imagesc(allFitnesses)
                    xlabel('Generation')
                    ylabel('Organism');
                    title({'Best Program'; self.organismToString(self.bestOrganism)})
                    colorbar
                    drawnow;
                end
            end
        end
        
        function ds = runAction(self, ds)
            cOut = self.evalOrganism(self.bestOrganism, ds);
            ds = ds.setX(cOut);
        end
    end
    
    methods 
        function o = generateOrganism(self)
            [o.commands, o.isOperator, o.isInput, o.isEphemeralRandomConstant, o.ephemeralRandomConstants, o.depths] = prtClassGeneticProgram.generateOrganismRecursive(self.maxTreeDepth, self.nOperations, self.nInputs, self.ercProb, self.ephemeralRandomConstantFunction);
        end
        
        function out = evalOrganism(self, organism, in)
            out = prtClassGeneticProgram.evalOrganismRecursive(self.availableOperations, in.getX, organism.commands, organism.isOperator, organism.isInput, organism.isEphemeralRandomConstant, organism.ephemeralRandomConstants, organism.depths);
        end
        
        function str = organismToString(self, organism, useLatex)
            if nargin < 3
                useLatex = self.useLatexStringsByDefault;
            end
            if useLatex
                str = prtClassGeneticProgram.organismToStringRecursive(self.availableOperationsStringsLatex, organism.commands, organism.isOperator, organism.isInput, organism.isEphemeralRandomConstant, organism.ephemeralRandomConstants, organism.depths, true);
            else
                str = prtClassGeneticProgram.organismToStringRecursive(self.availableOperationsStrings, organism.commands, organism.isOperator, organism.isInput, organism.isEphemeralRandomConstant, organism.ephemeralRandomConstants, organism.depths,false);
            end
        end
        
        function newOrg = crossoverOrganisms(self, mother, father)
            
            
            % This implementation only does crossover at operations
            % Select mother inds
            nPossibilities = sum(mother.isOperator(2:end));
            motherSelectedPoint = prtRvUtilRandomSample(ones(nPossibilities,1)./nPossibilities,1,find(mother.isOperator(2:end)')+1);
            
            motherTreeMat = prtClassGeneticProgram.organismToTreeMat(mother);
            motherSelectInds1 = 1:(motherSelectedPoint-1);
            motherSelectStart2 = (find(~motherTreeMat(motherSelectedPoint,(motherSelectedPoint+1):end),1,'first')+motherSelectedPoint);
            motherSelectInds2 = motherSelectStart2:length(mother.isOperator);
            motherDepth = mother.depths(motherSelectedPoint);
            
            % Select father inds
            nPossibilities = sum(father.isOperator(2:end));
            fatherSelectedPoint = prtRvUtilRandomSample(ones(nPossibilities,1)./nPossibilities,1,find(father.isOperator(2:end)')+1);
            
            fatherTreeMat = prtClassGeneticProgram.organismToTreeMat(father);
            fatherSelectInds = find(fatherTreeMat(fatherSelectedPoint,:));
            fatherDepth = father.depths(fatherSelectedPoint);
            
            % Create the new organim
            
            % The ephemeral constants need to get cat'ed together so the
            % index must get incremented
            newFatherCommands = father.commands;
            newFatherCommands(father.isEphemeralRandomConstant) = newFatherCommands(father.isEphemeralRandomConstant) + length(mother.ephemeralRandomConstants);
            
            newOrg.commands = cat(2,mother.commands(motherSelectInds1), newFatherCommands(fatherSelectInds), mother.commands(motherSelectInds2));
            newOrg.isOperator = cat(2,mother.isOperator(motherSelectInds1),father.isOperator(fatherSelectInds),mother.isOperator(motherSelectInds2));
            newOrg.isInput  = cat(2,mother.isInput(motherSelectInds1),father.isInput(fatherSelectInds),mother.isInput(motherSelectInds2));
            newOrg.isEphemeralRandomConstant  = cat(2,mother.isEphemeralRandomConstant(motherSelectInds1),father.isEphemeralRandomConstant(fatherSelectInds),mother.isEphemeralRandomConstant(motherSelectInds2));
            newOrg.ephemeralRandomConstants = cat(1,mother.ephemeralRandomConstants(:),father.ephemeralRandomConstants(:))';
            % Must account for the change in depths of the pieces
            newOrg.depths = cat(2,mother.depths(motherSelectInds1), father.depths(fatherSelectInds)-fatherDepth+motherDepth, mother.depths(motherSelectInds2));
            
            [usedEphemeralInds, dontNeed, newEphemeralInds] = unique(newOrg.commands(newOrg.isEphemeralRandomConstant)); %#ok<ASGLU>
            newOrg.ephemeralRandomConstants = newOrg.ephemeralRandomConstants(usedEphemeralInds);
            newOrg.commands(newOrg.isEphemeralRandomConstant) = newEphemeralInds;
            
            
            
        end
        
        function o = mutateOrganism(self, o)
            randomO = self.generateOrganism();
            o = self.crossoverOrganisms(o,randomO);
        end
        
    end
    
    methods
        function nOpp = get.nOperations(self)
            nOpp = length(self.availableOperations);
        end
    end
    
    methods (Static)
        function [commands, isOperator, isInput, isEphemeralRandomConstant, ephemeralRandomConstants, depths] = generateOrganismRecursive(maxDepth, nAvailableOpp, nAvailableInputs, ercProp, ercFun, cDepth)
            
            ephemeralRandomConstants = [];
            if nargin < 6 || isempty(cDepth)
                cDepth = 1;
            end
            
            depths = cDepth;
            % Uses the Grow method with the || uncommented 
            if maxDepth == 0% || (rand() < (nAvailableInputs+1)/(nAvailableInputs+1+nAvailableOpp))
                % Choose a random term (input or erc
                if rand < ercProp
                    % Use a random Constant
                    ephemeralRandomConstants = ercFun();
                    commands = length(ephemeralRandomConstants);
                    isOperator = false;
                    isInput = false;
                    isEphemeralRandomConstant = true;
                else
                    % Use a random input
                    commands = find(rand*nAvailableInputs < (1:nAvailableInputs),1,'first');
                    isOperator = false;
                    isInput = true;
                    isEphemeralRandomConstant = false;
                end
            else
                % Choose a random function
                commands = find(rand*nAvailableOpp < (1:nAvailableOpp),1,'first');
                isOperator = true;
                isInput = false;
                isEphemeralRandomConstant = false;
                
                [subTree1.commands, subTree1.isOperator, subTree1.isInput, subTree1.isEphemeralRandomConstant, subTree1.ephemeralRandomConstants, subTree1.depths] = prtClassGeneticProgram.generateOrganismRecursive(maxDepth-1, nAvailableOpp, nAvailableInputs, ercProp, ercFun, cDepth+1);
                [subTree2.commands, subTree2.isOperator, subTree2.isInput, subTree2.isEphemeralRandomConstant, subTree2.ephemeralRandomConstants, subTree2.depths] = prtClassGeneticProgram.generateOrganismRecursive(maxDepth-1, nAvailableOpp, nAvailableInputs, ercProp, ercFun, cDepth+1);
                
                % subTrees 1 and 2 come with their own self referenced
                % erc's so we need to modify these indexes accordingly
                subTree2.commands(subTree2.isEphemeralRandomConstant) = subTree2.commands(subTree2.isEphemeralRandomConstant) + length(subTree1.ephemeralRandomConstants);
                
                commands = cat(2, commands, subTree1.commands, subTree2.commands);
                isOperator = cat(2,isOperator, subTree1.isOperator, subTree2.isOperator);
                isInput = cat(2,isInput, subTree1.isInput, subTree2.isInput);
                isEphemeralRandomConstant = cat(2,isEphemeralRandomConstant, subTree1.isEphemeralRandomConstant, subTree2.isEphemeralRandomConstant);
                ephemeralRandomConstants = cat(2,subTree1.ephemeralRandomConstants, subTree2.ephemeralRandomConstants);
                depths = cat(2,depths, subTree1.depths, subTree2.depths);
            end
        end
              
        function str = organismToStringRecursive(oppStrings, commands, isOperator, isInput, isEphemeral, ephemeralRandomConstants, depths, useLatex)
            
            if length(commands)==1
                % We are at the end o the line
                if isInput
                    if useLatex
                        str = sprintf('x_{%d}',commands);
                    else
                        str = sprintf('x%d',commands);
                    end
                elseif isEphemeral
                    str = sprintf('%0.2f',ephemeralRandomConstants(commands));
                else
                    error('Bad command string, you can''t end with an opperation')
                end
            else
                % We are not at the end
                if isOperator(1)
                    % We have an operator
                    % Find the next two input sequences
                    % Turn those into strings
                    % Plug into this operator string strings
                    
                    if sum(isOperator)==1
                        % This is the only remaining operator
                        leftInds = 2;
                        rightInds = 3;
                    else
                        segmentStarts = find(depths == depths(2));
                        leftInds = segmentStarts(1):(segmentStarts(2)-1);
                        rightInds = segmentStarts(2):length(isOperator);
                    end
                    
                    % Get the strings for the left and right parts of the
                    % tree
                    leftString = prtClassGeneticProgram.organismToStringRecursive(oppStrings, commands(leftInds), isOperator(leftInds), isInput(leftInds), isEphemeral(leftInds), ephemeralRandomConstants, depths(leftInds),useLatex);
                    rightString = prtClassGeneticProgram.organismToStringRecursive(oppStrings, commands(rightInds), isOperator(rightInds), isInput(rightInds), isEphemeral(rightInds), ephemeralRandomConstants, depths(rightInds),useLatex);
                    
                    % Put this together with the operator string.
                    
                    nInputsThisCommand = length(strfind(oppStrings{commands(1)},'%s'));
                    if useLatex
                        switch nInputsThisCommand
                            case 1
                                str = sprintf(cat(2,'\\left(',oppStrings{commands(1)},'\\right)'),leftString);
                            case 2
                                str = sprintf(cat(2,'\\left(',oppStrings{commands(1)},'\\right)'),leftString, rightString);
                        end
                    else
                        switch nInputsThisCommand
                            case 1
                                str = sprintf(cat(2,'(',oppStrings{commands(1)},')'),leftString);
                            case 2
                                str = sprintf(cat(2,'(',oppStrings{commands(1)},')'),leftString, rightString);
                        end
                    end                    
                else
                    % Input or constant
                    % This shouldn't happen
                    error('Bad command string, missing operator');
                end
            end
        end
        
        function out = evalOrganismRecursive(opps, x, commands, isOperator, isInput, isEphemeral, ephemeralRandomConstants, depths)
            
            if length(commands)==1
                % We are at the end o the line
                if isInput
                    out = x(:,commands); sprintf('x%d',commands);
                elseif isEphemeral
                    out = ephemeralRandomConstants(commands);
                else
                    error('Bad command string, you can''t end with an opperation')
                end
            else
                % We are not at the end
                if isOperator(1)
                    % We have an operator
                    % Find the next two input sequences
                    % Evaluate those
                    % Plug into this operator
                    
                    if sum(isOperator)==1
                        % This is the only remaining operator
                        leftInds = 2;
                        rightInds = 3;
                    else
                        segmentStarts = find(depths == depths(2));
                        leftInds = segmentStarts(1):(segmentStarts(2)-1);
                        rightInds = segmentStarts(2):length(isOperator);
                    end
                    
                    % Get the strings for the left and right parts of the tree
                    leftX = prtClassGeneticProgram.evalOrganismRecursive(opps, x, commands(leftInds), isOperator(leftInds), isInput(leftInds), isEphemeral(leftInds), ephemeralRandomConstants, depths(leftInds));
                    rightX = prtClassGeneticProgram.evalOrganismRecursive(opps, x, commands(rightInds), isOperator(rightInds), isInput(rightInds), isEphemeral(rightInds), ephemeralRandomConstants, depths(rightInds));
                    
                    % Put this together with the operator string.
                    out = opps{commands(1)}(leftX, rightX);
                else
                    % Input or constant
                    % This shouldn't happen
                    error('Bad command string, missing operator');
                end
            end
        end        
        
        function treeMat = organismToTreeMat(organism)
            d = organism.depths;
            treeMat = false(length(d));
            for iDepth = 1:(length(d)-1)
                cEnd = find(d(iDepth+1:end) <= d(iDepth),1,'first') + iDepth-1;
                if isempty(cEnd)
                    cEnd = length(d);
                end
                treeMat(iDepth,iDepth:cEnd) = true;
            end
            treeMat(end,end) = true;
        end
        
    end
    
end
