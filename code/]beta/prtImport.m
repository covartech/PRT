classdef prtImport
    % Import Data from CSV or MAT files:
    %
    % p = prtImport;
    % ds = p.import(csvOrMatFile);
    %
    % For CSV files, tries to handle:
    %   Header lines, numeric and string-valued columns, 'nan' and empty
    %   regions as NaN.
    %
    % For MAT files:
    %   If mat file has a prtDataSet, use that, otherwise, if mat file has a
    %   variable x, look for y, and use x & y, otherwise, if mat file has a
    %   variable data, look for targets, and use data & targets.
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
        theDataSet
    end
    
    methods
        function self = prtImport(varargin)
            self = prtUtilAssignStringValuePairs(self,varargin{:});
        end
        
        function exportToCsv(self,dataSet,theFile)
            % exportToCsv(self,dataSet,theFile)
            %  Export the prtDataSet dataSet into the CSV file, theFile.
            %  Note that exporting to CSV can remove significant
            %  information from the data set; all that is retained are the
            %  data, targets, and feature names.
            %
            % ds = prtDataGenIris;
            % theFile = 'testExport.csv';
            % 
            % importer = prtImport;
            % importer.exportToCsv(ds,theFile);
            % dataSetImport = importer.import(theFile);
            
            
            fid = fopen(theFile,'w');
            c = onCleanup(@()fclose(fid));
            
            featureNames = dataSet.featureNames;
            
            format = '';
            for i = 1:length(featureNames);
                fprintf(fid,'%s, ',featureNames{i});
                format = sprintf('%s%%f,',format);
            end
            %add a column for targets, if not empty
            if ~isempty(dataSet.targets);
                fprintf(fid,'targets, ');
                format = sprintf('%s%%f,',format);
            end
            fprintf(fid,'\r\n');
            format = sprintf('%s\\r\\n',format); %add new-line
            
            x = cat(2,dataSet.X,dataSet.Y);
            fprintf(fid,format,x');
            
        end
        
        function ds = import(self,theFile)
            % ds = import(self,theFile)
            %   Import a prtDataSet from the specified file.  If no file is
            %   specified, use uigetfile to find an appropriate file.
            %
            % ds = prtDataGenBimodal;
            % theFile = 'testExport.csv';
            % 
            % importer = prtImport;
            % importer.exportToCsv(ds,theFile);
            % dataSetImport = importer.import(theFile);
            
            [p,f,e] = fileparts(theFile);
            
            switch e
                case {'.txt','.csv','.xls','.xlsx'}
                    % Algo: 
                    %   1) Figure out if it has a header line
                    %   2) Read rest of data
                    
                    % structure comes out as an Nx1 struct, but should
                    % really be a 1x1 struct with N-dim fields.  Todo: add
                    % parameter to csvToStructure, "compressed" which
                    % passes through to csvCellToStructure, and switches
                    % the way the struct gets made
                    [structure,nonNumericFields,featureNames] = prtUtilImportCsvToStructure(theFile);
                    
                    fields = fieldnames(structure);
                    x = nan(length(structure),length(fields));
                    featureInfo = repmat(struct('uStrings',[]),length(fields),1);
                    for i = 1:length(fields);
                        if any(strcmpi(nonNumericFields,fields{i}))
                            %handle string values
                            [inds,uStrings] = prtUtilStringsToClassNumbers({structure.(fields{i})});
                            x(:,i) = inds;
                            featureInfo(i).uStrings = uStrings;
                        else
                            x(:,i) = cat(1,structure.(fields{i}));
                        end
                    end
                    
                    ds = prtDataSetClass(x);
                    if ~isempty(nonNumericFields)
                        ds.featureInfo = featureInfo;
                    end
                    ds.featureNames = featureNames;
                    
                    ds = userChooseTargetVariable(self,ds);
                    
                case '.mat'
                    disp('Easy!');
                    % Algo:
                    %   1) Has a prtDataSetClass?  OK!
                    %   2) Has X and Y?  OK!
                    %   3) Has data and labels?  OK!
                    %   4) Has one variable?  OK!
                    %
                    % Otherwise, ask
                    variables = whos('-file',theFile);
                    if any(strcmpi({variables.class},'prtDataSetClass'))
                        found = find(strcmpi({variables.class},'prtDataSetClass'));
                        variables(found(1)).name

                        loadStruct = load(theFile,variables(found(1)).name);
                        ds = loadStruct.(variables(found(1)).name);
                        return;
                    elseif any(strcmpi({variables.name},'x'))
                        found = find(strcmpi({variables.name},'x'));
                        variables(found(1)).name

                        loadStruct = load(theFile,variables(found(1)).name);
                        x = loadStruct.(variables(found(1)).name);
                        
                        y = [];
                        if any(strcmpi({variables.name},'y'))
                            found = find(strcmpi({variables.name},'y'));
                            variables(found(1)).name
                            
                            loadStruct = load(theFile,variables(found(1)).name);
                            y = loadStruct.(variables(found(1)).name);
                        end
                        ds = prtDataSetClass(x,y);
                            
                        return;
                    elseif any(strcmpi({variables.name},'data'))
                        found = find(strcmpi({variables.name},'data'));
                        variables(found(1)).name
                        
                        loadStruct = load(theFile,variables(found(1)).name);
                        x = loadStruct.(variables(found(1)).name);
                        
                        y = [];
                        if any(strcmpi({variables.name},'targets'))
                            found = find(strcmpi({variables.name},'targets'));
                            variables(found(1)).name
                            
                            loadStruct = load(theFile,variables(found(1)).name);
                            y = loadStruct.(variables(found(1)).name);
                        end
                        ds = prtDataSetClass(x,y);
                        
                        return;
                    end
                otherwise
                    error('prtImport can only import from files with known file extensions: txt, csv, xls, xlsx, or mat');
            end
        end
        
        function ds = userChooseTargetVariable(self,ds)
            str = {'We can''t determine from text files which columns to use as';
                '"targets" or "labels".  You can choose one below,';
                'or choose "cancel" to leave the data unlabeled'};
            
            [selected,ok] = listdlg('ListString',ds.featureNames,'SelectionMode','single','PromptString',str,'ListSize',[300,160]);
            
            if ~ok
                return;
            else
                ds.Y = ds.X(:,selected);
                ds.X = ds.X(:,setdiff(1:ds.nFeatures,selected));
            end
            
        end
    end
end
