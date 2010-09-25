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
            
            for iAlarm = 1:prtDataSet.nObservations
                
                data = prtDataSet.getObservations(iAlarm);
                Alarm = prtDataSet.getAlarms(iAlarm);
                while (size(data,3) < obj.maxDtSize)
                    fprintf('Feature Processing re-sizing; DataSet output 3-D data which was too small\n');
                    data = cat(3,data,data(:,:,end));
                end
                data = obj.preprocFn(data);
                
                maxDtSizeHalf = floor(obj.maxDtSize/2);
                if size(data,3) > obj.maxDtSize
                    fprintf('Feature Processing re-sizing; DataSet output 3-D data which was too large\n');
                    data = squeeze(data(:,:,ceil(end/2)-maxDtSizeHalf:ceil(end/2)+maxDtSizeHalf));
                end
                
                depthSegments = depthSegment3dData(data,20,10);
                
                %                 mu = mean(data(:).^2);
                %                 sigma = std(data(:).^2);
                for depthSegmentInd = 1:length(depthSegments);
                    depthSegments{depthSegmentInd} = squeeze(sum(depthSegments{depthSegmentInd}.^2));
                    data = depthSegments{depthSegmentInd};
                    
                    Ep = 0.5;
                    pixelLocation = [Alarm.Info.gprCrossTrack,maxDtSizeHalf];
                    adaptiveCompact(iAlarm,depthSegmentInd) = extractAdaptiveCompactness(data,pixelLocation,Ep);
                    
                    %data = (data-mu)./sigma;
                    level = graythresh(data./max(data(:)));
                    binaryDepthSegments{depthSegmentInd} = double(data./max(data(:)) > level);
                    g = extractRegionPropsNearLocation(binaryDepthSegments{depthSegmentInd},pixelLocation);
                    area(iAlarm,depthSegmentInd) = g.Area;
                    eccentricity(iAlarm,depthSegmentInd) = g.Eccentricity;
                    solidity(iAlarm,depthSegmentInd) = g.Solidity;
                    energy(iAlarm,depthSegmentInd) = sum(data(:));
                end
                
                %Plotting:
                if ~mod(iAlarm,20)
                    for i = 1:6; subplot(4,3,i); imagesc(depthSegments{i}); end;
                    for i = 1:6; subplot(4,3,i+6); imagesc(binaryDepthSegments{i}); end;
                    drawnow;
                end
                    
                disp(iAlarm);
            end
            features = cat(2,adaptiveCompact,area,eccentricity,solidity,energy);
            prtDataSetOut = prtDataSetClass(features,prtDataSet.getTargets);
        end

        function [textureFeats,textureImage] = extractTfcm(obj,theImage)
            %[textureFeats,textureImage] = extractTfcm(obj)
            
            theImage = medfilt2(theImage);
            [textureFeats,textureImage] = image2textureFeatures(theImage,obj.threshold,obj.distance);
        end
    end
end
        