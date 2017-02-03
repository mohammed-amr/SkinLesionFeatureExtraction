function [ pixel_labels, cluster_center ] = ColorSegmentation(im, minCutOff, maxCutOff, SampleWidthR, SampleHeightR, SkinWidthR, SkinHeightR )
%COLORSEGMENTATION 

    he = im;
    
    %he = rgb2gray(he);
%     figure;
%     subplot(1, 3, 1);
%     imshow(he);

    heHSV = rgb2hsv(((he)));
    V = heHSV(:,:,3);

    VLocalAvg = imgaussfilt(V, 30);

    GlobalAvg = mean(mean(V));

    heHSV(:,:,3) = heHSV(:,:,3) + GlobalAvg - VLocalAvg;

%     subplot(1, 3, 2);
%     imshow(hsv2rgb(heHSV));

    nColors = 2;
  
    lab_he = hsv2rgb(heHSV);
    ab = lab_he;
    nrows = size(ab,1);
    ncols = size(ab,2);
    ab = reshape(ab,nrows*ncols,3);
    count = 0;
    while(count < 5)
        [cluster_idx, cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', 'Replicates',3);
        pixel_labels = reshape(cluster_idx,nrows,ncols)-1;
        
        Invert = InversionDecisionRGB( im, cluster_center*255, SampleWidthR, SampleHeightR, SkinWidthR, SkinHeightR  );
    
        if Invert == 1
            pixel_labels = not(pixel_labels);
        end
        
        %sum(sum(pixel_labels))/(size(pixel_labels,1)*size(pixel_labels,2))
        if((sum(sum(pixel_labels))/(size(pixel_labels,1)*size(pixel_labels,2)) < maxCutOff && sum(sum(pixel_labels))/(size(pixel_labels,1)*size(pixel_labels,2)) > minCutOff))
            break;
        end
        count=count+1;
    end
end

