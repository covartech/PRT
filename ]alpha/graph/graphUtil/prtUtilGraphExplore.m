function prtUtilGraphExplore(self)

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


locs = self.plotLocations;
graph = self.graph;
names = self.nodeNames;

if isempty(locs)
    self = self.optimizePlotLocations;
    locs = self.plotLocations;
end

hF = figure;
hA = axes;
axis(hA,[-.5 .5 -.5 .5]);

nLines = 500;
lineRndStdDev = 0;

self.plot;

hz = zoom;
hp = pan;
set(hp,'ActionPostCallback',@(e,v)mypostcallback);
set(hz,'ActionPostCallback',@(e,v)mypostcallback);
set(hp,'ActionPreCallback',@(e,v)myprecallback);
set(hz,'ActionPreCallback',@(e,v)myprecallback);
hText = [];
hLines = [];

    function myprecallback(e,v)
        try
            delete(hText);
            hText = [];
            delete(hLines);
            hLines = [];
        catch ME
            disp(ME)
        end
    end

    function mypostcallback(e,v)
        % mypostcallback(e,v)
        v = axis;
        in = locs(:,1) > v(1) & locs(:,1) < v(2) & locs(:,2) > v(3) & locs(:,2) < v(4);
        
        cLocs = locs(in,:);
        cGraph = graph(in,in);
        cD = diag(cGraph);
        cNames = names(in);
        
        %Choose nLines lines to plot, at random... Should we use degree
        %here? Note, all this is done weirdly to make plotting super fast.
        [linkI,linkJ] = find(cGraph);
        plotLocs = [];
        indices = randperm(length(linkI));
        for i = indices(1:min(length(indices),nLines));
            plotLocs = cat(1,plotLocs,cLocs([linkI(i),linkJ(i)],:),[nan nan]);
        end
        
        % If there are any connections to plot, plot them:
        if ~isempty(plotLocs)
            plotLocs = plotLocs + randn(size(plotLocs))*lineRndStdDev;
            hold on
            hLines = plot(plotLocs(:,1),plotLocs(:,2),'c');
            uistack(hLines,'bottom');
            set(hLines,'hittest','off');
            hold off;
            
        end
        
        % Add the text
        [~,inds] = sort(cD,'descend');
        for i = 1:min([20,length(inds)]);
            hText(i) = text(cLocs(inds(i),1),cLocs(inds(i),2),cNames{inds(i)});
            set(hText(i),'fontsize',10,'fontweight','bold');
            set(hText,'hittest','off');
        end
    end
end
