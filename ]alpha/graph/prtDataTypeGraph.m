classdef prtDataTypeGraph
    %prtDataTypeGraph
    % General data type class for graphs
    %
    % graph = prtDataTypeGraph(connMat)
    %   Generate a graph object with weighted connectivity matrix specified
    %   in connMat
    %
    % graph = prtDataTypeGraph(connMat,nodeNames)
    %   Generate a graph object with weighted connectivity matrix specified
    %   in connMat, and specify the names of the nodes in the matrix.
    %
    % Methods:
    %    graph = graph.retainByDegree(...)
    %    graph.plot;
    %    graph.explore;
    %
    % For example:
    %   
    %   connMat = [0 1 1 1 1 0; 1 0 1 0 1 0; 1 1 0 0 0 0; 1 0 0 0 0 0; 1 1 0 0 0 0; 0 0 1 0 0 0];
    %   nodeNames = {'pete','kenny','sam','wiki','samantha','elena'};
    %   
    %   graph = prtDataTypeGraph(connMat,nodeNames);
    %   graph.plot; 
    %   title('People (and dogs) Who Worked or Lived Together');
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


    properties (Access=private)
        internalPlotLocations = [];
        internalGraph = [];
        internalNodeNames = {};
        internalNodeInfo = [];
    end
    properties (Hidden)
        explorePlotFunction = [];
    end
    %use these to get the data in different formats
    properties (Dependent)
        graph
        nodeNames
        hasNames
        hasInfo 
        plotLocations
        degree
        nodeInfo
    end
    
    methods 
        % dependent variable methods
        function d = get.degree(self)
            d = sum(self.graph,2) - diag(self.graph);
        end
        
        function val = get.nodeInfo(self)
            val = self.internalNodeInfo;
        end
            
        function h = get.hasNames(self)
            h = ~isempty(self.internalNodeNames);
        end
        
        function h = get.hasInfo(self)
            h = ~isempty(self.internalNodeInfo);
        end
        
        function val = get.plotLocations(self)
            val = self.internalPlotLocations;
        end
        
        function self = set.plotLocations(self,val)
            %Do error checking
            self.internalPlotLocations = val;
        end
        
        function self = set.graph(self,val)
            if (~isa(val,'numeric') && ~isa(val,'logical')) || size(val,1) ~= size(val,2)
                error('prtDataTypeGraph:invalidGraph','graph should be a square, numeric (possibly sparse) matrix');
            end
            self.internalGraph = val;
            if ~isequal(size(val,1),length(self.nodeNames))
                self.nodeNames = {};
            end
        end
        
        function self = set.nodeNames(self,val)
            if ~isa(val,'cell') || (~isempty(val) && size(self.graph,1) ~= length(val))
                error('prtDataTypeGraph:invalidNodeNames','nodeNames should be a cell array of strings with length equal to the size of the graph');
            end
            self.internalNodeNames = val;
        end
        
        
        function self = set.nodeInfo(self,val)
            if ~isa(val,'struct') || (~isempty(val) && size(self.graph,1) ~= length(val))
                error('prtDataTypeGraph:invalidNodeNames','nodeNames should be a cell array of strings with length equal to the size of the graph');
            end
            self.internalNodeInfo = val;
        end
        
        function val = get.graph(self)
            val = self.internalGraph;
        end
        
        function val = get.nodeNames(self)
            if self.hasNames
                val = self.internalNodeNames;
            else
                val = prtUtilCellPrintf('Node %d',num2cell(1:length(self.degree)));
            end
        end
    end
    
    methods
        
        function [self,retainedInds] = retainByDegree(self,varargin)
            % graph = retainByDegree(graph,d) 
            %   Return a graph consisting of only elements with degree
            %   greater than or equal to d.
            %
            % graph = retainByDegree(graph,fn) 
            %   For function_handle fn, return a a graph consisting of only
            %   elements where fn(degree) returns true.
            %
            %   e.g., 
            %    graph = retainByDegree(graph,@(d)d > 3 & d < 10);
            %
            
            d = self.degree;
            if isnumeric(varargin{1})
                keep = d >= varargin{1};
            elseif isa(varargin{1},'function_handle')
                keep = varargin{1}(d);
            end
            if islogical(keep)
                retainedInds = find(keep);
            else
                retainedInds = keep;
            end
            self = self.retainNodes(keep);
        end
        

        
        function self = retainNodes(self,indices)
            
            self.internalGraph = self.internalGraph(indices,indices);
            if self.hasNames
                self.nodeNames = self.nodeNames(indices);
            end
            if self.hasInfo
                self.nodeInfo = self.nodeInfo(indices);
            end
        end
        
        function self = prtDataTypeGraph(graph,nodeNames,nodeInfo)
            % prtDataTypeGraph
            %   obj = prtDataTypeGraph(graph)
            %   obj = prtDataTypeGraph(graph,nodeNames)
            %   obj = prtDataTypeGraph(graph,nodeNames,nodeInfoStruct)
            %
            %   obj = prtDataTypeGraph(gmlFile)
            %
            % 
            
            if nargin == 1 && isa(graph,'char')
                if exist(graph,'file')
                    [g,n,e] = prtUtilReadGml(graph);
                    self = prtDataTypeGraph(g,n,e);
                    return;
                else
                    error('prtDataTypeGraph:prtDataTypeGraph:invalidInput','prtDataTypeGraph with one character array input requires a valid file name');
                end
            end
            
            if nargin == 0
                return;
            end
            
            if nargin == 3
                self.graph = graph;
                self.nodeNames = nodeNames;
                self.nodeInfo = nodeInfo;
            elseif nargin == 2
                self.graph = graph;
                self.nodeNames = nodeNames;
            elseif nargin == 1
                self.graph = graph;
            end
        end
        
        
        function self = optimizeSpectralClustering(self)
            
            d = sum(self.graph,2);
            D = speye(size(self.graph));
            for i = 1:length(d);
                D(i,i) = d(i);
            end
            %             L = eye(size(self.graph)) - D^(-1/2)*self.graph*D^(-1/2);
            P = D^(-1)*self.graph;
            [v,s] = svds(P,2);
            self.plotLocations = v;
            
        end
        
        function self = jigglePlotLocations(self,stdev)
            if isempty(self.internalPlotLocations)
                self.internalPlotLocations = randn(size(graph,1),2);
                return;
            end
            if nargin == 1
                stdev = std(self.internalPlotLocations)./5;
            end
            self.internalPlotLocations = self.internalPlotLocations + bsxfun(@times,randn(size(self.graph,1),2),stdev);
        end
            
        function self = optimizePlotLocationsTsne(self,varargin)
            ds = prtDataSetClass(full(self.graph));
            tsne = prtPreProcTsne;
            tsne = tsne.train(ds);
            dsOut = tsne.run(ds);
            self.plotLocations = dsOut.X;
        end
        
        function self = optimizePlotLocationsHooke(self,varargin)
            
            p = inputParser;
            p.addParameter('optimalDistanceFn',@(g)1./g);
            p.addParameter('defaultDistance',1);
            p.addParameter('logicalGraph',false);
            p.addParameter('maxIters',10000);
            p.addParameter('plotOnIter',100);
            p.addParameter('velocityDecay',.99);
            p.addParameter('ka',1);
            p.addParameter('kr',1);
            p.addParameter('repelConnectedNodes',true);
            
            p.parse(varargin{:});
            res = p.Results;
            
            graph = self.graph;
            graph = graph - diag(diag(graph));
            if isempty(self.internalPlotLocations)
                locs = randn(size(graph,1),2)/3;
            else
                locs = self.internalPlotLocations;
            end
                
            
            degree = sum(graph,2);
            if any(degree == 0);
                error('Invalid graph');
            end
            % graph = graph > 0;
            
            v = zeros(size(locs));
            deltaT = 0.01;
            
            optimalDistance = res.optimalDistanceFn(graph);
            optimalDistance(~isfinite(optimalDistance)) = res.defaultDistance;
            optimalDistance = double(optimalDistance);
            
            for i = 1:res.maxIters;
                d = prtDistanceEuclidean(locs,locs);
                dx = bsxfun(@minus,locs(:,1),locs(:,1)');
                dy = bsxfun(@minus,locs(:,2),locs(:,2)');
                theta = atan2(dy,dx);
                
                f = -(d-optimalDistance);
                %                 f = -res.ka*log(d);
                f = f - diag(diag(f));
                f(~isfinite(f)) = 0;
                
                %all connections "pull" with the same force, but goal
                %distances (optimalDistance) is proportional to
                %1/connection degree
                fx = f.*cos(theta).*(graph > 0); 
                fx(~isfinite(fx)) = 0;
                fy = f.*sin(theta).*(graph > 0);
                fy(~isfinite(fy)) = 0;
                
                %natural repelling for un-connected
                fRepel = res.kr*bsxfun(@times,degree,degree')./d.^2;
                if ~res.repelConnectedNodes
                    fRepel = fRepel.*(~graph);
                end
                fRepel(~isfinite(fRepel)) = 0;
                fRepel = fRepel - diag(diag(fRepel));
                
                fRx = fRepel.*cos(theta);
                fRy = fRepel.*sin(theta);
                
                fx = fx + fRx;
                fy = fy + fRy;
                
                %                 keyboard
                %                 fx(fx > 100) = 100;
                %                 fy(fy > 100) = 100;
                %                 keyboard
                %
                ax = sum(fx,2)./degree; %F = ma; a = F/m
                ay = sum(fy,2)./degree; 
                v(:,1) = v(:,1) + ax.*deltaT;
                v(:,2) = v(:,2) + ay.*deltaT;
                v = v.*res.velocityDecay;
                
                locs = locs + v*deltaT;
                
                if ~mod(i,res.plotOnIter) || i == 1
                    plot(locs(:,1),locs(:,2),'b.');
                    title(i);
                    drawnow;
                end
                    
            end
            
            
            self.internalPlotLocations = locs;
        end
        
        %         function self = optimizePlotLocations(self)
        %
        %             hF = [];
        %
        %             graph = self.graph;
        %             locs = rand(size(graph,1),2)-.5;
        %             prevLocs = locs;
        %             connected = logical(graph);
        %             connected = logical(connected + eye(size(connected)));
        %
        %             alpha = 300;
        %             step = 10;
        %             maxIter = 1000;
        %
        %             for i = 1:maxIter
        %                 d = prtDistanceEuclidean(locs,locs);
        %                 dInv = 1./(2*d);
        %                 dInv(~isfinite(dInv)) = 0;
        %
        %                 dx = 2*(bsxfun(@minus,locs(:,1),locs(:,1)')).*dInv;
        %                 dy = 2*(bsxfun(@minus,locs(:,2),locs(:,2)')).*dInv;
        %
        %                 dx(~connected) = -alpha*dx(~connected);
        %                 dy(~connected) = -alpha*dy(~connected);
        %
        %                 mag1 = sqrt(locs(:,1).^2+locs(:,2).^2);
        %                 mag2 = sqrt(locs(:,1).^2+locs(:,2).^2);
        %                 mag1(mag1 == 0) = inf;
        %                 mag2(mag2 == 0) = inf;
        %
        %                 dx = -mean(dx,2) - locs(:,1)./mag1;
        %                 dy = -mean(dy,2) - locs(:,2)./mag2;
        %
        %                 locs(:,1) = locs(:,1)+dx/(step);
        %                 locs(:,2) = locs(:,2)+dy/(step);
        %
        %                 locs = prtUtilMinMax(locs)-.5;
        %                 if ~mod(i,2);
        %                     if isempty(hF)
        %                         hF = figure;
        %                     end
        %                     plot(locs(:,1),locs(:,2),'b.');
        %                     title(sprintf('Optimizing... iteration %d',i));
        %                     drawnow;
        %                 end
        %
        %                 converged = norm(prevLocs(:)-locs(:))/sqrt(size(locs(:),1)) < 1e-3;
        %                 %converged = sum((prevLocs(:)-locs(:)).^2)/sqrt(size(locs(:),1)) < 1e-8;
        %                 if converged
        %                     disp('converged');
        %                     break;
        %                 end
        %                 prevLocs = locs;
        %             end
        %             close(hF);
        %             self.internalPlotLocations = locs;
        %         end
        
        
        function self = optimizePlotLocations(self)
            % self = optimizePlotLocations(self)
            pos = prtUtilGraphPlotNeato(self.graph);
            self.plotLocations = pos;
        end
        
        function handles = plot(self,locs)
            
            graph = self.graph;
            if nargin < 2
                locs = self.internalPlotLocations;
            end
            if isempty(locs)
                self = optimizePlotLocations(self);
                locs = self.internalPlotLocations;
            end
            
            %Get colors
            nBins = round(size(graph,1)/10);
            temp = full(sum(graph,2));
            [~,centers] = hist(log(temp),nBins);
            
            distMat = prtDistanceEuclidean(log(temp(:)),centers(:));
            [~,minInd] = min(distMat,[],2);
            
            c = jet(nBins);
            % plot points
            for i = 1:length(centers);
                current = locs(minInd == i,:);
                h = plot(current(:,1),current(:,2),'b.');
                
                set(h,'color',c(i,:));
                set(h,'markersize',30);
                set(h,'hittest','off');
                hold on;
            end
            
            [linkI,linkJ] = find(graph);
            plotLocs = [];
            
            if length(linkI) < 200
                nSamples = length(linkI);
                indices = 1:nSamples;
            else
                nSamples = 3000;
                %nSamples = length(linkI);
                indices = ceil(rand(nSamples,1)*length(linkI));
            end
            
            
            for i = indices(:)';
                plotLocs = cat(1,plotLocs,locs([linkI(i),linkJ(i)],:),[nan nan]);
            end
            
            hLines = plot(plotLocs(:,1),plotLocs(:,2),'c');
            uistack(hLines,'bottom');
            set(hLines,'hittest','off');
            hold off;
            
            nStrings = min([100 size(graph,1)]);
            nodality = sum(graph,2);
            [~,inds] = sort(nodality,'descend');
            inds = randperm(length(inds)); %random names
            if ~isempty(self.nodeNames)
                for i = 1:nStrings;
                    theLoc = locs(inds(i),:);
                    h = text(theLoc(1),theLoc(2),self.nodeNames{inds(i)});
                    set(h,'fontsize',10,'fontweight','bold');
                    set(h,'hittest','off');
                end
            end
        end
        
        function explore(self)
            prtUtilGraphExplore(self);
        end
        
    end
    methods (Hidden = true)
        function [index,minDist,clickPoint] = findClosestAxesHit(self,e,v)
           cP = get(gca,'currentPoint');
           clickPoint = cP(1,1:2);
           locs = self.plotLocations;
           [minDist,index] = min(prtDistanceEuclidean(clickPoint,locs));
        end
        
        function exploreOnClickInternal(self,e,v)
            index = self.findClosestAxesHit(e,v);
            disp(index)
            if ~isempty(self.explorePlotFunction)
                self.explorePlotFunction(self,index);
            end
        end
    end
end


