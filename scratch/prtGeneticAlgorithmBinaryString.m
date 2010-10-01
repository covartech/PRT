classdef prtGeneticAlgorithmBinaryString
    
    properties
        
        geneArray
        geneLength
        
        currentFitnessVector
        fitnessMatrix = [];
        fitnessFunction
        
        generation = 1;
        nGenerations = 20;
        populationSize = 20;
        elitistPercentage = .05;
        mutationRate = 0.01;
        priorP1 = 0.5;
        isInitialized = false;
        
        maxPositiveElements = 10;
        plotPerformanceOnGeneration = true;
        verbose = true;
    end
    
    methods
        
        function obj = enforceMaxPositiveElements(obj)
            for i = 1:obj.populationSize
                element = obj.geneArray(i,:);
                on = find(element);
                if length(on) > obj.maxPositiveElements
                    on = on(randperm(length(on)));
                    on = on(1:obj.maxPositiveElements);
                    newElement = zeros(size(element));
                    newElement(on) = 1;
                    obj.geneArray(i,:) = newElement;
                end
            end
        end
        
        function obj = initialize(obj)
            obj.geneArray = double(rand(obj.populationSize,obj.geneLength) < obj.priorP1);
            obj = enforceMaxPositiveElements(obj);
            obj.isInitialized = true;
        end
        
        function obj = initializeManual(obj,geneArray)
            obj.geneArray = geneArray;
            obj.isInitialized = true;
        end
        
        function obj = evaluateFitness(obj)
            obj.currentFitnessVector = zeros(obj.populationSize,1);
            for i = 1:obj.populationSize
                if ~mod(i,floor(obj.populationSize/10)) && obj.verbose
                    fprintf('Generation %d; Evaluting fitness of element %d / %d\n',obj.generation,i,obj.populationSize);
                end
                obj.currentFitnessVector(i) = obj.fitnessFunction(obj.geneArray(i,:));
            end
            if isempty(obj.fitnessMatrix)
                obj.fitnessMatrix = nan(obj.populationSize,obj.nGenerations);
            end
            obj.fitnessMatrix(:,obj.generation) = obj.currentFitnessVector;
        end
        
        function obj = run(obj)
            if ~obj.isInitialized
                    obj = obj.initialize;
            end
            
            obj = evaluateFitness(obj);
            
            %start at 2; we already evaluated the first generation:
            for i = 2:obj.nGenerations 
                obj = recombine(obj);
                obj = evaluateFitness(obj);
                
                if ~mod(i,obj.plotPerformanceOnGeneration)
                    plot(obj.fitnessMatrix','.');
                    drawnow;
                    xlim([0, obj.generation+10]);
                end
            end
        end
        
        function obj = recombine(obj)
            oldGeneration = obj.geneArray;
            [sortedFitness,sortedFitnessIndices] = sort(obj.currentFitnessVector,'descend');
            obj.currentFitnessVector = sortedFitness;
            oldGenerationSorted = oldGeneration(sortedFitnessIndices,:);
            
            fitness = sortedFitness./sum(sortedFitness);
            accuFitness = cumsum(fitness);
            
            nElites = floor(obj.elitistPercentage * obj.populationSize);
            newGeneration(1:nElites,:) = oldGenerationSorted(1:nElites,:);
            
            for childIndex = nElites+1:obj.populationSize
                p = rand(1,2);
                fatherIndex = find(accuFitness > p(1),1);
                motherIndex = find(accuFitness > p(2),1);
                
                father = oldGenerationSorted(fatherIndex,:);
                mother = oldGenerationSorted(motherIndex,:);
                crossOverIndex = ceil(rand*length(father));
                child = cat(2,father(1:crossOverIndex),mother(crossOverIndex+1:end));
                
                mutations = double(rand(size(child)) < obj.mutationRate);
                child = mod(child + mutations,2);
                newGeneration(childIndex,:) = child;
            end
            obj.geneArray = newGeneration;
            obj = enforceMaxPositiveElements(obj);
            obj.generation = obj.generation + 1;
        end
    end
end