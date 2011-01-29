classdef prtFeatureExtractorEhdGpr < prtFeatureExtractor
    
    properties (SetAccess = private)

        name = 'Edge Histogram Features';
    	nameAbbreviation = 'Ehd';
    	isSupervised = false;
    end
    properties
        
        edgeFilters % Created by the constructor. See ehdInit.
        filterOptions = 'replicate';
        retainFactor = 1;
        windows % Created by the constructor. See ehdInit.
        
        extractHighEnergyDepth = true;
        depthLen = 15;
        
        preprocFn = @(x)x;
    end
    
    methods 
        function obj = prtFeatureExtractorEhdGpr
            obj = obj.ehdInit();
        end            
    end
    
    methods (Access=protected,Hidden=true)
        
        function obj = ehdInit(obj)
            obj.edgeFilters{1} = fliplr(triu(ones(5)) - tril(ones(5)));
            obj.edgeFilters{2} = cat(1,ones(2,5),zeros(1,5),-ones(2,5));
            obj.edgeFilters{3} = triu(ones(5)) - tril(ones(5));
            obj.edgeFilters{4} = obj.edgeFilters{2}';
            
            obj.windows{1} = 5:15;
            obj.windows{2} = 12:22;
            obj.windows{3} = 19:29;
        end
        
        function obj = trainAction(obj,varargin)
            %do nothing
        end
        
        function prtDataSetOut = runAction(obj,prtDataSet)
            %[Features,y,ASLinked] = nfAraProcessAlarmSet(obj,AS,OS,GprPreProcessOptions)
            
            ehdFeats = nan(prtDataSet.nObservations,12); %4 filters
            %ehdFeats = nan(prtDataSet.nObservations,9);   %3 filters
            for iAlarm = 1:prtDataSet.nObservations
                
                data = prtDataSet.getObservations(iAlarm);
                Alarm = prtDataSet.getAlarms(iAlarm);
                while (size(data,3) < 31)
                    data = cat(3,data,data(:,:,end));
                end
                data = obj.preprocFn(data);
                if size(data,3) > 33
                    fprintf('Ehd re-sizing');
                    data = squeeze(data(:,:,ceil(end/2)-16:ceil(end/2)+16));
                end
                
                theImage = squeeze(data(:,Alarm.Info.gprCrossTrack,:));
                
                if obj.extractHighEnergyDepth
                    depthEnergy = sum(abs(theImage).^2,2);
                    [~,maxEnergyDepth] = max(depthEnergy);
                    maxEnergyDepth = clip(maxEnergyDepth,[obj.depthLen+1,size(theImage,1)-obj.depthLen]);
                    theImage = theImage(maxEnergyDepth-obj.depthLen:maxEnergyDepth+obj.depthLen,:);
                end
                
                figure(1); imagesc(theImage,[-4 4]);
                a = obj.extractEhd(theImage);
                ehdFeats(iAlarm,:) = a(:)';
                
                disp(iAlarm);
            end
            prtDataSetOut = prtDataSetClass(ehdFeats,prtDataSet.getTargets);
        end
        
        function [ehdHist,edges,maxInd,imageThresh] = extractEhd(obj,data)
            
            
            
            nFilters = length(obj.edgeFilters);
            edges = cell(1,nFilters);
            for iFilt = 1:nFilters
                edges{iFilt} = imfilter(data,obj.edgeFilters{iFilt},obj.filterOptions);
                edges{iFilt} = abs(edges{iFilt});
            end
            
            edgeImage = cat(3,edges{:});
            [~,maxInd] = max(edgeImage,[],3);
            
            [~,retainedIndices] = thresholdData(abs(data),percentOrderStatistic(abs(data),1-obj.retainFactor));
            %[~,retainedIndices] = thresholdData(abs(maxVals),percentOrderStatistic(abs(maxVals(:)),1-obj.retainFactor));
            imageThresh = data;
            imageThresh(~retainedIndices) = nan;
            maxInd(~retainedIndices) = nan;
            
            histEdges = 1:nFilters;
            nWindows = length(obj.windows);
            ehdHist = nan(nFilters,nWindows);
            for iWindow = 1:nWindows
                currMaxInd = maxInd(:,obj.windows{iWindow});
                ehdHist(:,iWindow) = histc(currMaxInd(:),histEdges);
            end
        end
        
    end
end
        