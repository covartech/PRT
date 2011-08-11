close all
clear classes
a = prtGuiPlot(1:10,randn(10,5),'lineWidth',1);
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
p = prtGuiManagerPanel;
%%
close all
clear classes
s = prtGuiSubplot({{2,2,1:2},{2, 2, 3},{2, 2, 4}});

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

