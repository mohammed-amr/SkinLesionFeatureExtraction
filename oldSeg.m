%%old segmentation
 %Otsu's algorithm for bw conversion. Thorws back a threshold for
    %segmentation
    [level EM] = graythresh(imgray);

    %deciding whether or not to negate the image. For cases where the lesion(s)
    %are lighter than the skin or vice versa.
    Invert = InversionDecision(imgray,sizeX,sizeY,sizeZ,SampleWidthR,SampleHeightR,SkinWidthR,SkinHeightR);

    %converting image to BW using the threshold 
    imBW = im2bw(imgray,level);
    if Invert == 1
        imBW = not(imBW);
    end
    

    %Trimming corners. This is needed for images with vignetting in the corners.
    if TrimCorners == 1;
        Trim = 1/9;
        trimmed = FilledIn;
        trimmed(1:Trim*sizeX, 1:Trim*sizeY) = 0;
        trimmed( sizeX-(Trim*sizeX): sizeX, 1:(Trim*sizeY) ) = 0;
        trimmed( sizeX-(Trim*sizeX): sizeX, sizeY-(Trim*sizeY):sizeY ) = 0;
        trimmed( 1 : Trim*sizeX, sizeY-(Trim*sizeY):sizeY ) = 0;
        FilledIn = trimmed;
    end 

    %Filling in holes.
    FilledIn = imfill(FilledIn, 'holes'); 
    
    %helps remove small specs before expanding 
    FilledIn = bwareaopen(FilledIn, 5); 

    RoughSegment = FilledIn;
    
    %applying a morphilogocial operation to help connect stary blobs.
    %using a circle with a standerdized radius.
    SE = strel('disk', round((ShapeFactor*sqrt(sizeX*sizeY))));
    AllBlobsMask = imdilate(FilledIn,SE);
    
    %Filling in holes.
    AllBlobsMask = imfill(AllBlobsMask, 'holes'); 