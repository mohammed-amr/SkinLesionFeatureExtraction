% %region growing
% figure;
% testregion = regiongrowing(im2double(imgray), sizeX/2, sizeY/2,0.2);
% imshow(imfill(testregion, 'holes'));

 SE = strel('disk', round(((1/50)*sqrt(sizeX*sizeY))));
imshow(imclose(FilledIn, SE));