classdef prtDataSetClassBigData < prtDataSetClass

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
    properties (Dependent)

        matFileName
        writeMode  %'newfile, 'overwrite', 'off'
        writeDir
    end
    properties (Hidden)
        verbose = true;
        matFileObj = [];
        internalMatFileName = '';
        internalWriteMode = 'off';
        
        internalWriteDir = '';
        defaultWriteDir = fullfile(tempdir,'prtBigDataTemp');
        
        previouslyWrittenTempFiles = {};
        warnOnNumBytes = 10*10^10; %About 10 Gig seems like a lot
        warnOnNumFiles = 1000; %1000 files is a lot.
    end
    
    methods
        
        function ds = prtDataSetClassBigData(varargin)
            ds = ds@prtDataSetClass(varargin{:});
            
            ds.checkDirStatus;
        end
        
        function checkDirStatus(obj,directory)
            if nargin == 1
                directory = obj.writeDir;
            end
            d = dir(directory);
            nFiles = sum(~[d.isdir]);
            nBytes = sum(cat(1,d.bytes));
            if nFiles > obj.warnOnNumFiles
                %warn
                fprintf('Pardon me for mentioning, but you seem to have a whole bunch of files in %s. \nMany of these may have been made by prtDataSetClassBigData... you might want to clean them up',directory);
            elseif nBytes > obj.warnOnNumBytes
                %Warn
                fprintf('Pardon me for mentioning, but you seem to have a whole lot of data in %s.  \nMany of these big files may have been made by prtDataSetClassBigData... you might want to clean them up',directory);
            end
        end
            
            
        function self = set.writeDir(self,val)
            %
            
            %check dir exists
            self.internalWriteDir = val;
            self.checkDirStatus;
        end
        
        function val = get.writeDir(self)
            %
            
            if isempty(self.internalWriteDir)
                val = self.defaultWriteDir;
            else
                val = self.internalWriteDir;
            end
            self.assertTempWriteDir(val);
            self.checkDirStatus(val);
        end
        
        function self = set.matFileName(self,val)
            %
            
            %check file exists
            self.internalMatFileName = val;
            if strcmpi(val,'on')
                self.matFileObj = matfile(val,'Writable',true);
            else
                self.matFileObj = matfile(val,'Writable',false);
            end
            %handle leg work
            self.observationInfo = repmat(struct,self.nObservations,1);
            self.featureInfo = repmat(struct,1,self.nFeatures);
        end
        function self = set.writeMode(self,val)
            %
            
            %check is string or is bool; file exists
            self.internalWriteMode = val;
            if strcmpi(val,'on')
                self.matFileObj = matfile(self.matFileName,'Writable',true);
            else
                self.matFileObj = matfile(self.matFileName,'Writable',false);
            end
        end
        
        function val = get.matFileName(self)
            val = self.internalMatFileName;
        end
        function val = get.writeMode(self)
            val = self.internalWriteMode;
        end
    end
    
    methods    
        
        
        function ds = toPrtDataSetClass(obj,X)
            %ds = toPrtDataSetClass(obj)
            %ds = toPrtDataSetClass(obj,newX)
            
            if nargin == 1
                X = obj.X;
            end
            ds = prtDataSetClass(X,obj.Y);
            ds.observationInfo = obj.observationInfo;
            ds.featureInfo = obj.featureInfo;
            ds.name = obj.name;
            ds.description = obj.description;
            ds.userData = obj.userData;
        end
        
        function nObservations = determineNumObservations(obj)
            [nObservations,~] = size(obj.matFileObj,'data');
        end
        
        function nFeatures = determineNumFeatures(obj)
            [~,nFeatures] = size(obj.matFileObj,'data');
        end
        
        function cleanup(obj)
            %this invalidates the object, and deletes all temporary files.
            %(but NOT the original file used to create the data).  Which is
            %nice
            
            for i = 1:length(obj.previouslyWrittenTempFiles);
                if obj.verbose
                    fprintf('Deleting old file %s during data write\n',obj.previouslyWrittenTempFiles{i});
                end
                delete(obj.previouslyWrittenTempFiles{i});
            end
        end
        
    end
    
    
    methods (Access = protected, Hidden = true)
        
        function doubleData = getDataAsMatrix(obj,varargin)
            
            %matObj doesn't like logical
            isColon = false(1,2);
            for i = 1:length(varargin)
                varargin{i} = varargin{i}(:)';
                if islogical(varargin{i})
                    varargin{i} = find(varargin{i});
                elseif isequal(varargin{i},':')
                    s = [obj.nObservations,obj.nFeatures];
                    varargin{i} = 1:s(i);
                    isColon(i) = true;
                end
            end
            
            if nargin == 1 %all data
                doubleData = obj.matFileObj.data;
            elseif nargin == 2
                try
                    doubleData = obj.matFileObj.data(varargin{1},:);
                catch ME
                    if obj.verbose
                        disp('Accessing prtDataSetClassBigData with multiple different step indices makes things very slow, and makes the PRT sad :(');
                    end
                    try
                        doubleData = nan(length(varargin{1}),obj.nFeatures);
                        for i = 1:length(varargin{1})
                            doubleData(i,:) = obj.matfileobj.data(varargin{1}(i),:);
                        end
                    catch ME2
                        throw(ME); %use old error
                    end
                end
            elseif nargin == 3
                try
                    doubleData = obj.matFileObj.data(varargin{1},varargin{2});
                catch ME
                    if obj.verbose
                        disp('Accessing prtDataSetClassBigData with multiple different step indices makes things very slow, and makes the PRT sad :(');
                    end
                   try
                       doubleData = nan(length(varargin{1}),length(varargin{2}));
                       if isColon(1)
                           for j = 1:length(varargin{2})
                               doubleData(:,j) = obj.matFileObj.data(:,varargin{2}(j));
                           end
                       elseif isColon(2)
                           for i = 1:length(varargin{1})
                               doubleData(i,:) = obj.matFileObj.data(varargin{1}(i),:);
                           end
                       else
                           %two loops.  Very sad.
                           for i = 1:length(varargin{1})
                               for j = 1:length(varargin{2})
                                   doubleData(i,j) = obj.matFileObj.data(varargin{1}(i),varargin{2}(j));
                               end
                           end
                       end
                    catch ME2
                        throw(ME); %use old error
                    end
                end 
            else
                error('incorrect nargin');
            end
        end
        
        function obj = setDataFromMatrix(obj,newData,varargin)
            
            switch lower(obj.writeMode);
                case 'overwrite'
                    error('This is currently disabled; it can overwrite important files at times you might not realize');
                case 'off'
                    error('Can''t set data of a prtDataSetClassBigData with writeMode set to off.  Either change the writeMode to newFile, or use toPrtDataSetClass(obj,newX)');
                case 'newfile'
                    
                    if nargin == 2 %all data
                        data = newData;
                    elseif nargin == 3
                        data = newData;
                        data(varargin{1},:) = newData;
                    elseif nargin == 4
                        data = newData;
                        data(varargin{1},varargin{2}) = newData;
                    else
                        error('incorrect nargin');
                    end
                    
                    obj.previouslyWrittenTempFiles{end+1} = fullfile(obj.writeDir,sprintf('dataSetClassBigTemp_%s.mat',mat2str(now*10000)));
                    
                    if obj.verbose
                        fprintf('Creating new file %s during data write\n',obj.previouslyWrittenTempFiles{end});
                    end
                    
                    %if this were a handle class... this would be easier...
                    %we could use "delete".  But that messes up a ton of
                    %other stuff...  if we want to make the switch, we
                    %should do it now.  I vote no; primarily because MATLAB
                    %doesn't use special notation to refer to handles.
                    % Don't do this.
                    %                     if length(obj.previouslyWrittenTempFiles) > 1
                    %                         if obj.verbose
                    %                             fprintf('Deleting old file %s during data write\n',obj.previouslyWrittenTempFiles{end-1});
                    %                         end
                    %                         delete(obj.previouslyWrittenTempFiles{end-1});
                    %                     end
                    
                    save(obj.previouslyWrittenTempFiles{end},'data');
                    obj.matFileName = obj.previouslyWrittenTempFiles{end};
                    obl.matFileObj = matfile(obj.previouslyWrittenTempFiles{end});
                otherwise
                    error('invalid writeMode');
            end
        end
    
        function obj = assertTempWriteDir(obj,dir)
            if ~exist(dir,'dir')
                mkdir(dir);
            end
        end
    end
end
