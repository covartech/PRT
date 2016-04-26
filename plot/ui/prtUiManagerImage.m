classdef prtUiManagerImage < prtUiManagerAxes





    properties (Dependent)

      	
    end
    
    properties
        imageHandle = [];
        climSliderHandle = [];
    end
    properties (Hidden)
        axesPosition
    end
    
    methods
        
        function tickoff(self)
            set(self.managedHandle,'xtick',[]);
            set(self.managedHandle,'ytick',[]);
        end 
        
        function self = prtUiManagerImage(varargin)
           if nargin
               self = prtUtilAssignStringValuePairs(self, varargin{:});
           end
        end
        
        function reImage(self, varargin)
            if isempty(self.imageHandle)
                self.imageHandle = image(varargin{:},'Parent',self.managedHandle);
            else
                self.updateCData(varargin{1});
            end
        end
        
        function reImagesc(self, varargin)
            if isempty(self.imageHandle)
                self.imageHandle = imagesc(varargin{:},'Parent',self.managedHandle);
            else
                self.updateCData(varargin{1});
            end
        end
        
        function reImshow(self, varargin)
            if isempty(self.imageHandle)
                self.imageHandle = imshow(varargin{:},'Parent',self.managedHandle);
            else
                self.updateCData(varargin{1});
            end
        end
        
        function image(self,varargin)
            self.imageHandle = image(varargin{:},'Parent',self.managedHandle);
        end
        
        function imagesc(self,varargin)
            self.imageHandle = imagesc(varargin{:},'Parent',self.managedHandle);
        end
        
        function imshow(self,varargin)
            self.imageHandle = imshow(varargin{:},'Parent',self.managedHandle);
        end
        
        function updateCData(self, cData)
            % updateData(self, cData)
            self.checkValid;
            
            prevCdata = get(self.imageHandle,'cdata');
            if ~isequal(size(prevCdata),size(cData))
                warning('prt:prtUiManagerImage:changeCdataSize','Attempt to change the size of the data in an image by setting the cData, try re-creating the image');
            end
            set(self.imageHandle,'CData',cData);
        end
        
        function ih = get.imageHandle(self)
            ih = self.imageHandle;
        end
        
        function shapePoly = getRoiPoly(self)
            % Output either a struct or an empty array
            self.checkValid;
            
            axes(self.managedHandle); %#ok<MAXES> %Because roipoly doesn't let you specify axes
            [~,xi,yi] = roipoly;
            shapePoly = [];
            if ~isempty(xi)
                shapePoly = struct('type','poly','xi',xi,'yi',yi);
            end
        end
        
        function shapeLine = getRoiLine(self)
            % Output either a struct or an empty array
            self.checkValid;
            
            axes(self.managedHandle); %#ok<MAXES> %Because roipoly doesn't let you specify axes
            [~,xi,yi] = roipoly;
            shapeLine = [];
            if ~isempty(xi)
                xi = xi(1:end-1);
                yi = yi(1:end-1);
                shapeLine = struct('type','line','xi',xi,'yi',yi);
            end
        end
        
        function shapeRect = getRoiRect(self)
            % Output either a struct or an empty array
            self.checkValid;
            
            axes(self.managedHandle); %#ok<MAXES>  %Because imcrop doesn't let you specify axes
            [~,rect] = imcrop;
            shapeRect = [];
            if ~isempty(rect)
                xi = [rect(1);rect(1);rect(1)+rect(3);rect(1)+rect(3);rect(1)];
                yi = [rect(2);rect(2)+rect(4);rect(2)+rect(4);rect(2);rect(2)];
                shapeRect = struct('type','rect','xi',xi,'yi',yi);
            end
            
        end
        
        function is = checkValid(self)
            assert(ishandle(self.imageHandle),'prt:prtUiManagerImage:badHandle','Some or all of the requested handles are no longer valid. The axes may have been deleted.');
            is = true;
        end
        
        function h = plotShape(self,shapeArray)
            self.checkValid;
            
            axes(self.managedHandle); %#ok<MAXES>  %Because ishold doesn't let you specify axes
            holdState = ishold;
            h = nan(size(shapeArray));
            hold(self.managedHandle,'on');
            %Plot each shape:
            try
                for i = 1:length(shapeArray)
                    if length(shapeArray(i).xi) == 1
                        h(i) = plot(shapeArray(i).xi,shapeArray(i).yi,'b.'); %points
                    else
                        h(i) = plot(shapeArray(i).xi,shapeArray(i).yi,'b');
                    end
                end
            catch ME
                disp(ME)
                debugdlg('I had trouble plotting one of your objects.  Do you want to debug?');
            end
            if ~holdState
                hold(self.managedHandle,'off');
            end
        end
    end
end
