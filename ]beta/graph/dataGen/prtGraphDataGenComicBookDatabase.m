function graph = prtGraphDataGenComicBookDatabase
% graph = prtGraphDataGenComicBookDatabase
%  
%  Database created in October 2012 by Peter Torrione by scraping cbdb.com.  
%  Please cite the PRT if you use this in your work:
% 
% @Manual{prt2011,
%   author =	 {Peter Torrione and Sam Keene and Kenneth Morton },
%   title =	 {{PRT}: The Pattern Recognition Toolbox for {MATLAB}},
%   year =	 {2011},
%   note =	 {Software available at \url{http://newfolderconsulting.com/prt}}
% }







[~,bigDataDir] = prtGraphDataDir;
gmlFile = fullfile(bigDataDir,'cbdbDatabase.mat');

if ~exist(gmlFile,'file')
    error('Could not find the bigData graph file %s; you can download it from here: %s',gmlFile,prtGraphDataUrl);
end
load(gmlFile,'cbdbGraph','cbdbCharacterNames');

graph = prtDataTypeGraph(cbdbGraph,cbdbCharacterNames);
