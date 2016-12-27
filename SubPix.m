
[sizeX, sizeY, sizeZ] = size(im); 

%clipping the dermotology watermark at the bottom of the image so that it
%doesn't interfere with segmentation.
if DermLogo == 1 
    im = im(1:sizeX-20, :,:);
    sizeX = sizeX-20;
end


%converting image to grayscale
imgray = rgb2gray(im);


%stretching image histogram.

%stretches so that the highest value is now 255
imgray = imadjust(imgray,[double(min(min(imgray)))/255 double(max(max(imgray)))/255],[]);

%%%%%%%%%%%%%%%% Initial Segmentation %%%%%%%%%%%%%%%%%%%%%%%%%

%Otsu's algorithm for bw conversion. Thorws back a threshold for
%segmentation
[level EM] = graythresh(imgray);

%deciding whether or not to negate theimage. For cases where the lesion(s)
%are lighter than the skin or vice versa.
Invert = InversionDecision(imgray,sizeX,sizeY,sizeZ,SampleWidthR,SampleHeightR,SkinWidthR,SkinHeightR);

%converting image to BW using the threshold 
imBW = im2bw(imgray,level);
if Invert == 1
    imBW = not(imBW);
end

%Filling in holes.
FilledIn = imfill(imBW, 'holes'); 

%Trimming corners. This is needed for images with shading in the corners.
if TrimCorners == 1;
    Trim = 1/9;
    trimmed = FilledIn;
    trimmed(1:Trim*sizeX, 1:Trim*sizeY) = 0;
    trimmed( sizeX-(Trim*sizeX): sizeX, 1:(Trim*sizeY) ) = 0;
    trimmed( sizeX-(Trim*sizeX): sizeX, sizeY-(Trim*sizeY):sizeY ) = 0;
    trimmed( 1 : Trim*sizeX, sizeY-(Trim*sizeY):sizeY ) = 0;
    FilledIn = trimmed;
end 


FilledIn = bwareaopen(FilledIn, 5); %helps remove small specs before expanding 

%applying a morphilogocial operation to help connect stary blobs.
%using a circle with a standerdized radius.
SE = strel('disk', round((ShapeFactor*sqrt(sizeX*sizeY))));
AllBlobsMask = imdilate(FilledIn,SE);

%Filling in holes.
FilledIn = imfill(imBW, 'holes'); 

%%%%%%%%%%%%%%%% Initial Labeling %%%%%%%%%%%%%%%%%%%%5

%Labelling disconnected blobs
LabeledMaster = bwlabel(AllBlobsMask);
%getting areas of blobs.
s = regionprops(LabeledMaster, 'Area');

%sorting blobs in descending order based on area.
[ListedIndecies, ListedIndecies] = sort([s.Area],'descend');
MaxList = ListedIndecies(1);


%extracting top NumberToTake blobs if they exist
for i = 2:numel(ListedIndecies)
    if i>NumberToTake 
        break;
    end

    if s(ListedIndecies(i)).Area > BlobCutOff*s(ListedIndecies(1)).Area
        MaxList = [MaxList ListedIndecies(i)];
    else
        break;
    end
end

LargestBlobs = s(MaxList);


%labeling them as one blob for color and symmetry 
WorkBlockMask = (LabeledMaster==MaxList(1));
LargestBlob = WorkBlockMask; %largest blob there is
for i = 2:numel(MaxList)
    Temp = (LabeledMaster==MaxList(i));
    WorkBlockMask = or(WorkBlockMask, Temp); 
end


%%%%%%%%%%%%%%%%%%%%%%%%% Color Information %%%%%%%%%%%%%%%%%%%%%%%%%

[AvgColor, ColorVariance ClusterCentroids] = FindColorParam(im, WorkBlockMask, ColorClusterSize);


%%%%%%%%%%%%%%% Preparing top NumberToTake blobs for symmetry calc. %%%%%%%%%%%%%
[ CroppedBinaryMask, CroppedRGB, CroppedGray ] = CenterCrop( WorkBlockMask, im, imgray );

%calling symmetry fucntions on top NumberToTake blobs
[SymErrorBinaryX, SymErrorBinaryY]  = BinarySymmetryError(CroppedBinaryMask);
SymErrorBinary = [SymErrorBinaryX SymErrorBinaryY];
[SymErrorRGBX, SymErrorRGBY] = RGBSymmetryError(CroppedRGB, CroppedBinaryMask);
SymErrorRGB = [SymErrorRGBX, SymErrorRGBY];
[SymErrorGrayX, SymErrorGrayY] = GraySymmetryError(CroppedGray, CroppedBinaryMask);
SymErrorGray = [SymErrorGrayX SymErrorGrayY];

%%%%%%%%%%%%%%%%%%%% Getting gradient of largest blob %%%%%%%%%%%%%%%%%%%%

%cropping and centering the largesrt blob
[ CroppedLargeBlobMask, CroppedLargeBlobRGB, CroppedLargeBlobGray ] = CenterCrop( LargestBlob, im, imgray );
im = imread('Mel.jpg');
 
[L,N] = superpixels(CroppedLargeBlobRGB,50);

[featureVector,hogVisualization] = extractHOGFeatures(CroppedLargeBlobRGB);


figure
BW = boundarymask(L);
imshow(imoverlay(CroppedLargeBlobRGB,BW,'cyan'),'InitialMagnification',67);


a = ones(100, 100);
b(:, :, 1) = a;
b(:, :, 2) = a;
b(:, :, 3) = a;
[featureVector,hogVisualization] = extractHOGFeatures(b,'CellSize',[32 32]);

figure
imshow(uint8(b));
hold on;
plot(hogVisualization);