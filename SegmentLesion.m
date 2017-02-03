function [AllBlobsMask, RoughSegment, im] = SegmentLesion(im, SampleWidthR, SampleHeightR, SkinWidthR, SkinHeightR, ShapeFactor, HairFactor, minCutOff, maxCutOff)
    
    im = im(2:end-1, 2:end-1, :);
    [imBW] = ColorSegmentation(im, minCutOff, maxCutOff, SampleWidthR, SampleHeightR, SkinWidthR, SkinHeightR);
    
    [sizeX, sizeY, ~] = size(im);
    
    %Filling in holes.
    FilledIn = imfill(imBW, 'holes'); 
    
    %helps remove small specs before expanding 
    FilledIn = bwareaopen(FilledIn, 5); 

    RoughSegment = FilledIn;
    
    %applying a morphilogocial operation to help connect stary blobs.
    %using a circle with a standerdized radius.
    SE = strel('line', round((HairFactor*sqrt(sizeX*sizeY))), sqrt(sizeX*sizeY));
    AllBlobsMask = imerode(FilledIn,SE);
    SE = strel('disk', round((ShapeFactor*sqrt(sizeX*sizeY))));
    AllBlobsMask = imdilate(AllBlobsMask,SE);
    
    %Filling in holes.
    AllBlobsMask = imfill(AllBlobsMask, 'holes'); 
    
end

