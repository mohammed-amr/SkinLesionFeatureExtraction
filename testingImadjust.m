im = imread('146_1.jpg');

imGray = rgb2gray(im);
figure;
imhist(imGray);


imGray = imadjust(imGray,stretchlim(imGray));
figure;
imhist(imGray);