function ss = prtPlotUtilCurrentCursorScreenSize
% Internal function, 
% xxx Need Help xxx







try
    ss = get(0,'MonitorPositions');
    cursorPosition = get(0,'PointerLocation');
    
    monitorInd = find(cursorPosition(1) >= ss(:,1) & cursorPosition(1) <= ss(:,3) & cursorPosition(2) >= ss(:,2) & cursorPosition(2) <= ss(:,4),1,'first');
    
    ss = ss(monitorInd,:);
    
catch  %#ok<CTCH>
    ss = get(0,'screensize');
end
