classdef prtDataSetAlarmSet < prtDataSetClass
    %prtDataSetAlarmSet < prtDataSetBase
    %
    %   Contains an array of Alarms which must have a field "dataFile" and
    %   a field ".Info.downTrack", and (optionally) a field
    %   ".Linking.onTarget" for labeled...
    %   
    %   araFileReaderConstructor = @(file)fileReaderAraNfGpr(file,'invalidChannels',[22 24],'replacementChannels',[21 23]);
    %   alarmDataSet = prtDataSetAlarmSet(AS,araFileReaderConstructor);
    %   

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


    properties
        fileReaderConstructorFn
    end
    
    properties (Hidden)
        %Note: need to use this to hold all the fileReaders we've
        %generated; otherwise we will be forced to re-read entire files to
        %get their file lengths (as required by file reader) for every
        %alarm we use...  I haven't done this yet
        assocArrayFileKeys  %Hash table
        alarmSet
    end
    
    methods
        function obj = prtDataSetAlarmSet(inputAlarmSet,fileReaderConstructorFn,varargin)
            
            %deduce from input arguments:
            originalInputAlarmSet = inputAlarmSet;
            if isfield(inputAlarmSet,'AlarmSet') && isfield(inputAlarmSet,'ObjectSet')
                inputAlarmSet = inputAlarmSet.AlarmSet;
            end
            % This is an inputAlarmSet
            if ~isfield(inputAlarmSet.Alarms(1),'dataFile') && isfield(inputAlarmSet,'dataFile')
                for i = 1:length(inputAlarmSet.Alarms)
                    inputAlarmSet.Alarms(i).dataFile = inputAlarmSet.dataFile;
                end
                alarmArray = inputAlarmSet.Alarms;
            elseif isfield(inputAlarmSet.Alarms(1),'dataFile')
                alarmArray = alarmInput.Alarms;
            else
                error('No field dataFile specified');
            end
            if isfield(inputAlarmSet.Alarms(1),'Linking')
                localTargets = nan(length(inputAlarmSet.Alarms),1);
                for i = 1:length(inputAlarmSet.Alarms)
                    localTargets(i) = inputAlarmSet.Alarms(i).Linking.onObject;
                end
            else
                localTargets = [];
            end
            
            obj.alarmSet = originalInputAlarmSet;
            obj.fileReaderConstructorFn = fileReaderConstructorFn;
            obj.data = alarmArray;
            obj.targets = localTargets;
        end
        
        
        function data = getObservations(obj,index)
            fileReader = obj.fileReaderConstructorFn(obj.data(index).dataFile);
            data = fileReader.getLocalChunk(obj.data(index).Info.downTrack);
        end
        
        function obj = joinObservations(obj,varargin)
            error('can''t set observations; use setAlarms');
        end
        
        function obj = catObservations(obj,varargin)
            error('can''t set observations; use setAlarms');
        end
        
        function obj = setObservations(obj,alarms,indices1,indices2)
            %obj = setObservations(obj,alarms,indices1,indices2)
            %   For prtDataSetAlarmSet, this is used to set the *alarms*.
            %   We still need to totally simplify these, imho.
            
            if nargin == 2
                obj.data = alarms;
                return;
            end
            if nargin < 3 || isempty(indices1) || isequal(indices1,':')
                indices1 = 1:obj.nObservations;
            end
            if nargin < 4 || isempty(indices2) || isequal(indices2,':')
                indices2 = 1:obj.nFeatures;
            end
            if isnumeric(indices1)
                nRefs1 = length(indices1);
            elseif islogical(indices1)
                nRefs1 = sum(indices1);
            else
                error('prt:prtDataSetInMemory:setObservations','Invalid indices');
            end
            if isnumeric(indices2)
                nRefs2 = length(indices2);
            elseif islogical(indices2)
                nRefs2 = sum(indices2);
            else
                error('prt:prtDataSetInMemory:setObservations','Invalid indices');
            end
            
            if ~isequal([nRefs1,nRefs2],size(alarms))
                error('setObservations sizes not commensurate');
            end
            obj.data(indices1,indices2) = alarms;
            
            return;
        end
        
        function obj = setAlarms(obj,alarmArray,indices1)
            %obj = setAlarms(obj,alarmArray,indices1)
            obj = setObservations(obj,alarmArray,indices1);
        end
        
        function alarms = getAlarms(obj,indices1)
            %alarms = getAlarms(obj,indices1)
            
            if nargin == 1 || isempty(indices1) || (isa(indices1,'char') && isequal(indices1,':'))
                indices1 = 1:obj.nObservations;
            end
            alarms = obj.data(indices1);
        end
        
        function h = plot(obj)
            asPlot(obj.alarmSet);
        end
        function h = explore(obj)
            asPlot(obj.alarmSet);
        end
        
        %Note: need to overload all the crazy stuff that prtDataSetClass
        %lets you do.. that we can't do
        %
        %   joinFeatures - Combine the features from two or more data sets
        %   joinObservations - Combine the observations from two or more data sets
        %
        %   catFeatures - Combine the features from a data set with additional data
        %   catObservations - Combine the Observations from a data set with additional data
        %
        %   removeObservations - Remove observations from a data set
        %   retainObservations - Retain observatons (remove all others) from a data set
        %   replaceObservations - Replace observatons in a data set
        %
        %   removeFeatures - Remove features from a data set
        %   retainFeatures - Remove features (remove all others) from a data set
        %   replaceFeatures - Replace features in a data set
    end
end
