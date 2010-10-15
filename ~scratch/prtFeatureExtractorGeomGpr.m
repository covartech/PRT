classdef prtFeatureExtractorGeomGpr < prtFeatureExtractor
    
    properties (SetAccess = private)

        name = 'Geometric Features';
    	nameAbbreviation = 'GEOM';
    	isSupervised = false;
        maxDtSize = 31;
    end
    properties
        preprocFn = @(x)x;
    end
    
    methods (Access = protected)
        
        function obj = trainAction(obj,varargin)
            %do nothing
        end
        
        function prtDataSetOut = runAction(obj,prtDataSet)
            %[Features,y,ASLinked] = nfAraProcessAlarmSet(obj,AS,OS,GprPreProcessOptions)
            
            features = nan(prtDataSet.nObservations,30);
            for iAlarm = 1:prtDataSet.nObservations
                
                data = prtDataSet.getObservations(iAlarm);
                Alarm = prtDataSet.getAlarms(iAlarm);
                
                [features(iAlarm,:),depthSegments,binaryDepthSegments] = obj.runOnData(data,Alarm.Info.gprCrossTrack);
                
                %Plotting:
                if ~mod(iAlarm,20)
                    for i = 1:6; subplot(4,3,i); imagesc(depthSegments{i}); end;
                    for i = 1:6; subplot(4,3,i+6); imagesc(binaryDepthSegments{i}); end;
                    drawnow;
                end
                disp(iAlarm);
            end
            prtDataSetOut = prtDataSetClass(features,prtDataSet.getTargets);
        end
        
    end
    methods
        function [features,depthSegments,binaryDepthSegments] = runOnData(obj,data,channel)
            
            
            %If the data has < 31 down-track scans, make it bigger
            while (size(data,3) < obj.maxDtSize)
                fprintf('Feature Processing re-sizing; DataSet output 3-D data which was too small\n');
                data = cat(3,data,data(:,:,end));
            end
            tic;
            data = obj.preprocFn(data);
            t1 = toc;
            fprintf('%.2f seconds in pre-processing (viterbi)\n',t1);
            
            tic;
            %If the data has > 31 down-track scans, take the central scans
            maxDtSizeHalf = floor(obj.maxDtSize/2);
            if size(data,3) > obj.maxDtSize
                fprintf('Feature Processing re-sizing; DataSet output 3-D data which was too large\n');
                data = squeeze(data(:,:,ceil(end/2)-maxDtSizeHalf:ceil(end/2)+maxDtSizeHalf));
            end
            
            depthSegments = depthSegment3dData(data,20,10);
            
            %                 mu = mean(data(:).^2);
            %                 sigma = std(data(:).^2);
            adaptiveCompact = nan(1,length(depthSegments));
            area = nan(1,length(depthSegments));
            eccentricity = nan(1,length(depthSegments));
            solidity = nan(1,length(depthSegments));
            energy = nan(1,length(depthSegments));
            
            for depthSegmentInd = 1:length(depthSegments);
                depthSegments{depthSegmentInd} = squeeze(sum(depthSegments{depthSegmentInd}.^2));
                data = depthSegments{depthSegmentInd};
                
                Ep = 0.5;
                pixelLocation = [channel,maxDtSizeHalf];
                adaptiveCompact(1,depthSegmentInd) = extractAdaptiveCompactness(data,pixelLocation,Ep);
                
                %data = (data-mu)./sigma;
                level = graythresh(data./max(data(:)));
                binaryDepthSegments{depthSegmentInd} = double(data./max(data(:)) > level);
                g = extractRegionPropsNearLocation(binaryDepthSegments{depthSegmentInd},pixelLocation);
                area(1,depthSegmentInd) = g.Area;
                eccentricity(1,depthSegmentInd) = g.Eccentricity;
                solidity(1,depthSegmentInd) = g.Solidity;
                energy(1,depthSegmentInd) = sum(data(:));
            end
            t2 = toc;
            features = cat(2,adaptiveCompact,area,eccentricity,solidity,energy);
            fprintf('\t%.2f seconds in feature extraction\n',t2);
            
        end
    end
end
        