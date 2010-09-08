classdef prtFeatureExtractorTfcmGpr < prtFeatureExtractor
    
    properties (SetAccess = private)

        name = 'Texture feature coding method';
    	nameAbbreviation = 'TFCM';
    	isSupervised = false;
    end
    properties
        threshold = 1;
        distance = [1 1];
        preprocFn = @(x)x;
    end
    
    methods (Access = protected)
        
        function obj = trainAction(obj,varargin)
            %do nothing
        end
        function prtDataSetOut = runAction(obj,prtDataSet)
            %[Features,y,ASLinked] = nfAraProcessAlarmSet(obj,AS,OS,GprPreProcessOptions)
            
            textureFeats = nan(prtDataSet.nObservations,12);
            for iAlarm = 1:prtDataSet.nObservations
                
                data = prtDataSet.getObservations(iAlarm);
                Alarm = prtDataSet.getAlarms(iAlarm);
                while (size(data,3) < 31)
                    data = cat(3,data,data(:,:,end));
                end
                data = obj.preprocFn(data);
                if size(data,3) > 21
                    data = squeeze(data(:,:,ceil(end/2)-10:ceil(end/2)+10));
                end
                theImage = squeeze(data(:,Alarm.Info.gprCrossTrack,:));
                figure(1); imagesc(theImage,[-4 4]);
                textureFeats(iAlarm,:) = obj.extractTfcm(theImage);
                
                disp(iAlarm);
            end
            prtDataSetOut = prtDataSetClass(textureFeats,prtDataSet.getTargets);
        end

        function [textureFeats,textureImage] = extractTfcm(obj,theImage)
            %[textureFeats,textureImage] = extractTfcm(obj)
            
            theImage = medfilt2(theImage);
            [textureFeats,textureImage] = image2textureFeatures(theImage,obj.threshold,obj.distance);
        end
        
        %         function [textureFeats,textureImage] = plot(obj)
        %             %[textureFeats,textureImage] = plot(obj)
        %             [textureFeats,textureImage] = extractTfcm(obj);
        %
        %             subplot(2,1,1); imagesc(obj.theImage);
        %             subplot(2,1,2); imagesc(textureImage);
        %         end
    end
end
        