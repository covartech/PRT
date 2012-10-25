classdef prtDataTypeImage < prtUtilActionDataAccess
    %prtDataTypeImage
    % General class for image storage, with conversions between MAT, GRAY,
    % RGB, and HSV.  Also includes tools for data pixel-wise labeling,
    % key-point location and scale storage, multi-scale processing, etc.
    %
    % Note: translating from some image types (gray) to others (rgb) is
    % impossible (unless additional assumptions are made).  In these cases,
    % asking for output in an incompatible type results in NaNs.
    %
    % Constructors:
    %   prtDataTypeImage('imageData',data,'imageType','rgb');
    %   prtDataTypeImage(data,'rgb');
    %   prtDataTypeImage('peppers.png');
    %
    % Examples:
    %
    % peppers = imread('peppers.png');
    % img = prtDataTypeImage('imageData',peppers,'imageType','rgb');
    % imshow(img);
    %
    % imgGray = img.gray;
    % imshow(imgGray)
    %
    % imgFromFile = prtDataTypeImage('peppers.png');
    %
    
    properties
        imageData = [];
        imageType = ''; %'mat','gray','rgb','hsv'
        i
        j
        keypoints
        actionData
    end
    
    properties (Access = protected)
        internalRgbData = [];
        internalGrayData = [];
        internalHsvData = [];
    end
    
    %use these to get the data in different formats
    properties (Dependent)  
        gray
        rgb
        hsv
    end
    
    methods
        
        function [patches,fullPatch] = extractKeypointPatches(self,patchSize,theKeypoints)
            %[patches,fullPatch] = extractKeypointPatches(self,patchSize)
            if nargin < 3
                theKeypoints = self.keypoints;
            end
            patches = cell(size(theKeypoints,1),1);
            theGray = self.gray;
            for keyIndex = 1:size(theKeypoints,1)
                cropRect = [theKeypoints(keyIndex,:)-ceil(patchSize/2),patchSize-1];
                patches{keyIndex} = imcrop(theGray,cropRect);
            end
            fullPatch = cellfun(@(x) isequal(size(x),patchSize), patches);
        end
        
        function [self,points] = extractKeypoints(self,varargin)
            %[self,points] = extractKeypoints(self,varargin)
            %  Call this like you would "corner"
            % to do: add scales
            points = corner(self.gray,varargin{:});
        end
        
        function sz = getImageSize(self,varargin)
            %sz = getImageSize(self,varargin)
            sz = size(self.imageData,varargin{:});
        end
        
        function self = imresize(self,varargin)
            %self = imresize(self,varargin)
            imgData = imresize(self.imageData,varargin{:});
            self = prtDataTypeImage(imgData,self.imageType);
        end
        
        function [self,rect] = imcrop(self,varargin)
            %self = imcrop(self,varargin)
            [imgData,rect] = imcrop(self.imageData,varargin{:});
            self = prtDataTypeImage(imgData,self.imageType);
        end
        
        function self = prtDataTypeImage(varargin) 
            % prtDataTypeImage - video processing image constructor
            %   obj = prtDataTypeImage(imgData,imgType)
            %       Accepts an NxM or NxMx3 matrix and imgType
            %       {'mat','gray','rgb', or 'hsv'}
            %
            %   obj = prtDataTypeImage(imgData)
            %       Accepts an NxM or NxMx3 and assumes the image is either
            %       gray or rgb depending on the image size.
            %
            %   obj = prtDataTypeImage(imgFile)
            %       Uses imread to read the RGB values from the image file
            %       imgFile.
            %
            if nargin == 0
                self.internalRgbData = nan;
                self.imageType = 'gray';
                return;
            end
            
            if nargin == 2
                if isa(varargin{1},'char') % one input, infer type
                    data = varargin{2};
                    if size(data,3) == 3
                        varargin = {'imageData',data,'imageType','rgb'};
                    else
                        varargin = {'imageData',data,'imageType','gray'};
                    end
                    %fall through
                else
                    varargin = {'imageData',varargin{1},'imageType',varargin{2}};
                end
            elseif nargin == 1
                if isa(varargin{1},'char') && exist(varargin{1},'file')
                    data = imread(varargin{1});
                    varargin = {'imageData',data,'imageType','rgb'};
                else
                    data = varargin{1};
                    if size(data,3) == 3
                        varargin = {'imageData',data,'imageType','rgb'};
                    else
                        varargin = {'imageData',data,'imageType','gray'};
                    end
                end
            end
            
            
            self = prtUtilAssignStringValuePairs(self,varargin{:});
            if ~isValid(self)
                error('Need to specify imageData and imageType');
            end
            %self = updateStorage(self);
        end
        
        function data = getDataForImshow(self)
            %data = getDataForImshow(self)
            switch self.imageType
                case 'mat'
                    data = self.gray;
                case 'hsv'
                    data = self.rgb;
                otherwise
                    data = self.imageData;
            end
        end
        
        function data = getDataForImage(self)
            %data = getDataForImage(self)
            switch self.imageType
                case 'mat'
                    data = self.gray;
                    data = data - min(data(:));
                    data = round(data./max(data(:))*255);
                case 'gray'
                    data = self.gray;
                    data = data - min(data(:));
                    data = round(data./max(data(:))*255);
                case 'hsv'
                    data = self.rgb;
                otherwise
                    data = self.imageData;
            end
        end
        
        function h = imagesc(self,varargin)
            %h = imagesc(self,varargin)
            imgData = self.getDataForImage;
            h = imagesc(imgData,varargin{:});
        end
        
        function varargout = imshow(self,varargin)
            %h = imshow(self,varargin)
            imgData = self.getDataForImshow;
            h = imshow(imgData,varargin{:});
			
			varargout = {};
			if nargout
				varargout{1} = h;
			end
        end
        
        function h = image(self,varargin)
            %h = image(self,varargin)
            imgData = self.getDataForImage;
            h = image(imgData,varargin{:});
            set(h,'CDataMapping','scaled');
        end
        
        function self = setImageDataAndType(self,imgData,imgType)
            %self = setImageDataAndType(self,imgData,imgType)
            self.imageData = imgData;
            self.imageType = imgType;
            self = clearStorage(self);
        end
        
        function is = isValid(self)
            is = ~isempty(self.imageData) && ~isempty(self.imageType);
        end
        
        
        function self = convert(self,type)
            switch lower(type)
                case 'gray'
                    self.internalGrayData = self.gray;
                case 'hsv'
                    self.internalHsvData = self.hsv;
                case 'rgb'
                    self.internalHsvData = self.rgb;
                otherwise
                    error('prtDataTypeImage:invalidSpec','The specified image format was not valid');
            end
        end
        
        function self = clearStorage(self)
            self.internalRgbData = [];
            self.internalHsvData = [];
            self.internalGrayData = [];
        end
        
        function self = updateStorage(self)
            switch lower(self.imageType)
                case 'mat'
                    self.internalRgbData = [];
                    self.internalHsvData = [];
                    self.internalGrayData = mat2gray(self.imageData);
                case 'gray'
                    self.internalRgbData = [];
                    self.internalHsvData = [];
                case 'rgb'
                    self.internalGrayData = rgb2gray(self.imageData);
                    self.internalHsvData = rgb2hsv(self.imageData);
                case 'hsv'
                    self.internalRgbData = rgb2gray(self.imageData);
                    self.internalGrayData = rgb2gray(self.internalRgbData);
                otherwise
                    error('prtDataTypeImage:invalidSpec','The specified image format was not valid');
            end
        end
        
        function g = get.gray(self)
            if ~isempty(self.internalGrayData)
                g = self.internalGrayData;
                return;
            else
                switch lower(self.imageType)
                    case 'mat'
                        self.internalGrayData = mat2gray(self.imageData);
                        g = self.internalGrayData;
                    case 'gray'
                        self.internalGrayData = self.imageData;
                        g = self.internalGrayData;
                    case 'rgb'
                        self.internalGrayData = rgb2gray(self.imageData);
                        g = self.internalGrayData;
                    case 'hsv'
                        self.internalRgbData = rgb2gray(self.imageData);
                        self.internalGrayData = rgb2gray(self.internalRgbData);
                        g = self.internalGrayData;
                    otherwise 
                        error('prtDataTypeImage:invalidSpec','The specified image format was not valid');
                end
                return;
            end     
        end
        
        function r = get.rgb(self)
            if ~isempty(self.internalRgbData)
                r = self.internalRgbData;
                return;
            else
                switch lower(self.imageType)
                    case 'mat'
                        %                         error('prtDataTypeImage:invalidSpec','Cannot convert from internal storage "mat" to "rgb"');
                        r = nan;
                    case 'gray'
                        %                         error('prtDataTypeImage:invalidSpec','Cannot convert from internal storage "gray" to "rgb"');
                        r = nan;
                    case 'rgb'
                        self.internalRgbData = self.imageData;
                        r = self.internalRgbData;
                    case 'hsv'
                        self.internalRgbData = rgb2gray(self.imageData);
                        r = self.internalRgbData;
                    otherwise 
                        error('prtDataTypeImage:invalidSpec','The specified image format was not valid');
                end
                return;
            end     
        end
        
        function h = get.hsv(self)
            if ~isempty(self.internalHsvData)
                h = self.internalHsvData;
                return;
            else
                switch lower(self.imageType)
                    case 'mat'
                        %                         error('prtDataTypeImage:invalidSpec','Cannot convert from internal storage "mat" to "hsv"');
                        h = nan;
                    case 'gray'
                        %                         error('prtDataTypeImage:invalidSpec','Cannot convert from internal storage "gray" to "hsv"');
                        h = nan;
                    case 'rgb'
                        self.internalHsvData = rgb2hsv(self.imageData);
                        h = self.internalHsvData;
                    case 'hsv'
                        self.internalHsvData = self.imageData;
                        h = self.internalHsvData;
                    otherwise 
                        error('prtDataTypeImage:invalidSpec','The specified image format was not valid');
                end
                return;
            end     
        end
    end
end