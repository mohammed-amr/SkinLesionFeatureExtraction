ShapeFactor = 1/100;
[sizeX, sizeY, ~] = size(im);

SE = strel('line', round((ShapeFactor*sqrt(sizeX*sizeY))), sqrt(sizeX*sizeY));
AllBlobsMask = imerode(RoughSegment,SE);

subplot(1,2,2);
imshow(AllBlobsMask);
subplot(1,2,1);
imshow(RoughSegment);