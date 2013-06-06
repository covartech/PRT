classdef prtDataHandlerMatFiles < prtDataHandler
    % prtDataHandlerMatFiles Provide an interface 
    % 
    % h = prtDataHandlerMatFiles('fileList','Y:\swap\prtBigDataTest');
    % parfor (i = 1:h.nBlocks,4); 
    %   ds = h.getBlock(i); 
    %   x(i,:) = mean(ds.X); 
    % end
    %
    
    properties (Dependent)
        fileList
    end
    
    properties 
        currBlock = 1;
    end
    
    properties (Hidden)
        fileListDepHelper
        matFileType = 'xy'; %or dataSet
        dsVarName
        allowedPrtDataTypes = {'prtDataSetClass','prtDataSetRegress','prtDataSetStandard'};
    end
    
    methods
        
        function set.fileList(self,val)
            
            if ischar(val) && exist(val,'dir')
                dirList = prtUtilSubDir(val,'*.mat');
            elseif isa(val,'cell')
                dirList = val;
            else
                error('prtDataHandlerMatFiles:invalidInput','The provided fileList was neither a directory nor a cell array of files');
            end
            
            self.fileListDepHelper = dirList;
            
            varNames = whos('-file',self.fileList{1});
            for i = 1:length(varNames)
                dataSets = strcmpi(varNames(i).class,self.allowedPrtDataTypes);
                if any(dataSets)
                    varInds = dataSets(1);
                    self.matFileType = 'dataSet';
                    self.dsVarName = varNames(varInds).name;
                end
            end
        end
        
        function out = get.fileList(self)
            out = self.fileListDepHelper;
        end
               
        function self = prtDataHandlerMatFiles(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
        function ds = getNextBlock(self)
            ds = self.getBlock(self.currBlock);
            self.currBlock = self.currBlock + 1;
        end
        
        function ds = getBlock(self,i)
            switch self.matFileType
                case 'xy'
                    s = load(self.fileList{i});
                    if ~isfield(s,'X') || ~isfield(s,'Y')
                        error('prt:prtDataHandlerMatFiles','prtDataHandlerMatFiles requires that MAT files not containing a prtDataSet* have at least two variables named "X" and "Y"');
                    end
                    ds = prtDataSetClass(s.X,s.Y);
                    if isfield(s,'observationInfo')
                        ds.observationInfo = s.observationInfo;
                    end
                case 'dataSet'
                    s = load(self.fileList{i},self.dsVarName);
                    ds = s.(self.dsVarName);
            end
        end
        
        function nBlocks = getNumBlocks(self)
            nBlocks = length(self.fileList);
        end
        
        function outputClass = getDataSetType(self) 
            outputClass = 'prtDataSetClass';
        end
    end
end