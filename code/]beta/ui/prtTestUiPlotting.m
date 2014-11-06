close all

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
clear classes

a = prtUiPlot(1:10,randn(10,5),'lineWidth',1);
a.addPlot(11:2:30,randn(10,5),'lineWidth',2,'lineStyle','--');
%%
for iUpdate = 1:1000
    a.updateData([],randn(10,5),[],6:10);
    
    drawnow;
end
%%
a.fixedYLims = [-4 4];
a.fixedXLims = [0 40];
for iUpdate = 1:1000
    a.updateData(ceil(rand(10,1)*20) + 10,randn(10,5),[],6:10);
    
    drawnow;
end
%%

close all
clear classes
p = prtUiManagerPanel;
%%
close all
clear classes
s = prtUiSubplot({{2,2,1:2},{2, 2, 3},{2, 2, 4}});

s.axesManagers{1}.plot(1:2)
s.axesManagers{2}.plot(0:-1:-2)
s.axesManagers{3}.plot(randn(5))
s.axesManagers{1}.title = 'subplot(2,2,1:2)';
s.axesManagers{2}.title = 'subplot(2,2,3)';
s.axesManagers{3}.title = 'subplot(2,2,4)';

s.setAll('fixedYLims',[-3 3])
%%
%%
close all
clear classes
s = prtGuiSubplot({{2,2,1:2},{2, 2, 3},{2, 2, 4}});
s.setAll('fixedYLims',[-3 3]);

for iPlot = 1:100
    s.axesManagers{1}.replot(randn(5,1)+1)
    s.axesManagers{2}.replot((0:-1:-2)+ 0.2*randn(1,3));
    s.axesManagers{3}.replot(randn(5))
    
    
    s.axesManagers{1}.title = 'subplot(2,2,1:2)';
    s.axesManagers{2}.title = 'subplot(2,2,3)';
    s.axesManagers{3}.title = 'subplot(2,2,4)';

    drawnow;
end

