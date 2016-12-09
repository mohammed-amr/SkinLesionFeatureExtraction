function [ CroppedBinaryMask, CroppedRGB, CroppedGray ] = CenterCrop( WorkBlockMask, im, imgray )
%CENTERCROP Summary of this function goes here
%   Detailed explanation goes here
%classify the largest disconnected blobs separately.S
    LargeBlobData = regionprops(WorkBlockMask*2, 'Orientation');
    LargeBlobData = LargeBlobData(2);

    RotatedMask = imrotate(WorkBlockMask, -LargeBlobData.Orientation);
    RotatedRGB = imrotate(im, -LargeBlobData.Orientation);
    RotatedGray = imrotate(imgray, -LargeBlobData.Orientation);

    LargeBlobData2 = regionprops(RotatedMask*2, 'Centroid', 'BoundingBox', 'Area');
    LargeBlobData2 = LargeBlobData2(2);

    BoundBox = LargeBlobData2.BoundingBox;
    Centroid = LargeBlobData2.Centroid;

    DistYPos = ceil(BoundBox(2) + BoundBox(4) - Centroid(2));
    DistYNeg = ceil(Centroid(2) - BoundBox(2));
    DistXPos = ceil(BoundBox(1) + BoundBox(3) - Centroid(1));
    DistXNeg = ceil(Centroid(1) - BoundBox(1));

    if DistYPos > DistYNeg
        MaxYDist = DistYPos;
    else
        MaxYDist = DistYNeg;
    end

    if DistXPos > DistXNeg
        MaxXDist = DistXPos;
    else
        MaxXDist = DistXNeg;
    end

    [RMSizeR, RMSizeC] = size(RotatedMask);

    RotatedMaskWithBuffer = [ zeros(MaxYDist, RMSizeC + (MaxXDist*2)); zeros(RMSizeR, MaxXDist) RotatedMask zeros(RMSizeR, MaxXDist); zeros(MaxYDist, RMSizeC + (MaxXDist*2))];
    RotatedRed = [ zeros(MaxYDist, RMSizeC + (MaxXDist*2)); zeros(RMSizeR, MaxXDist) RotatedRGB(:,:,1) zeros(RMSizeR, MaxXDist); zeros(MaxYDist, RMSizeC + (MaxXDist*2))];
    RotatedGreen = [ zeros(MaxYDist, RMSizeC + (MaxXDist*2)); zeros(RMSizeR, MaxXDist) RotatedRGB(:,:,2) zeros(RMSizeR, MaxXDist); zeros(MaxYDist, RMSizeC + (MaxXDist*2))];
    RotatedBlue = [ zeros(MaxYDist, RMSizeC + (MaxXDist*2)); zeros(RMSizeR, MaxXDist) RotatedRGB(:,:,3) zeros(RMSizeR, MaxXDist); zeros(MaxYDist, RMSizeC + (MaxXDist*2))];
    RotatedRGB = cat(3, RotatedRed, RotatedGreen, RotatedBlue);
    RotatedGray = [ zeros(MaxYDist, RMSizeC + (MaxXDist*2)); zeros(RMSizeR, MaxXDist) RotatedGray zeros(RMSizeR, MaxXDist); zeros(MaxYDist, RMSizeC + (MaxXDist*2))];

    Centroid(1) = Centroid(1) + MaxXDist;
    Centroid(2) = Centroid(2) + MaxYDist;

    CroppedBinaryMask = RotatedMaskWithBuffer( (Centroid(2)-MaxYDist):(Centroid(2)+MaxYDist), (Centroid(1)-MaxXDist):(Centroid(1)+MaxXDist) );
    CroppedRGB = RotatedRGB( (Centroid(2)-MaxYDist):(Centroid(2)+MaxYDist), (Centroid(1)-MaxXDist):(Centroid(1)+MaxXDist),: );
    CroppedRGB = uint8(double(CroppedRGB).*repmat(CroppedBinaryMask,[1,1,3]));
    CroppedGray = RotatedGray( (Centroid(2)-MaxYDist):(Centroid(2)+MaxYDist), (Centroid(1)-MaxXDist):(Centroid(1)+MaxXDist) );
    CroppedGray = uint8(double(CroppedGray) .* CroppedBinaryMask);

end

