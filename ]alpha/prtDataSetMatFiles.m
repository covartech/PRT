classdef prtDataSetMatFiles < prtDataSetClass
    %prtDataSetMatFile < prtDataSetClass
    %
    % DS = prtDataGenBimodal;
    % for i = 1:DS.nObservations; 
    %   file{i} = sprintf('data_%s.mat',int2fixedWidthStr(i,3)); 
    %   x = DS.getX(i); 
    %   save(file{i},'x'); 
    % end
    % dsFile = prtDataSetMatFiles(file(:),DS.getTargets);
    %
    % dsFile.getObservations(10)
    %
    % dsFile.getObservations(10:20)
    %
    % dsFile.matFileVaribleName = 'x';
    %
    % dsFile.getObservations(10)
    %
    % dsFile.getObservations(10:20)
    %
    % plot(dsFile);
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

        matFileVaribleName = '';
    end
    methods
        function obj = prtDataSetMatFiles(varargin)
            if nargin == 0
                return;
            end
            if isa(varargin{1},'prtDataSetMatFiles')
                obj = prtDataSetMatFiles;
                varargin = varargin(2:end);
            end
            if isa(varargin{1},'cell')
                obj.data = varargin{1};
                varargin = varargin(2:end);
                
                if nargin >= 2 && (isa(varargin{1},'double') || isa(varargin{1},'logical'))
                    obj = obj.setTargets(varargin{1});
                end
                varargin = varargin(2:end);
            end
            obj = prtUtilAssignStringValuePairs(obj,varargin{:});
        end
        
        function data = getObservations(obj,indices1)
            if nargin == 1 || strcmpi(indices1,':');
                indices1 = 1:obj.nObservations;
            end
            for i = 1:length(indices1)
                if ~isempty(obj.matFileVaribleName)
                    data(i) = load(obj.data{indices1(i)},obj.matFileVaribleName);
                else
                    data(i) = load(obj.data{indices1(i)});
                end
            end
            if ~isempty(obj.matFileVaribleName)
                data = cat(1,data.(obj.matFileVaribleName));
            end
        end
        
        function obj = catObservations(obj,varargin)
            error('can''t cat observations yet; use setAlarms');
        end
        
        function files = getFiles(obj,indices1)
            %alarms = getAlarms(obj,indices1)
            
            if nargin == 1 || strcmpi(indices1,':');
                indices1 = 1:obj.nObservations;
            end
            files = obj.data(indices1);
        end
        
        function h = plot(obj)
            if ~isempty(obj.matFileVaribleName)
                data = obj.getObservations;
                plot(prtDataSetClass(data,obj.getTargets));
            else
                error('Can''t plot prtDataSetMatFiles when obj.matFileVaribleName is not set');
            end
        end
        function h = explore(obj)
            %asPlot(obj.alarmSet);
            if ~isempty(obj.matFileVaribleName)
                data = obj.getObservations;
                explore(prtDataSetClass(data,obj.getTargets));
            else
                error('Can''t plot prtDataSetMatFiles when obj.matFileVaribleName is not set');
            end
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
