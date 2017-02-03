function [ Mask, cluster_center ] = ColorSegmentation(im, minCutOff, maxCutOff, SampleWidthR, SampleHeightR, SkinWidthR, SkinHeightR )
%COLORSEGMENTATION 
    
    heHSV = rgb2hsv(((im)));
    V = heHSV(:,:,3);

    VLocalAvg = imgaussfilt(V, 30);

    GlobalAvg = mean(mean(V));

    heHSV(:,:,3) = heHSV(:,:,3) + GlobalAvg - VLocalAvg;

%     subplot(1, 3, 2);
%     imshow(hsv2rgb(heHSV));

    nColors = 2;
  
    lab_he = hsv2rgb(heHSV);
    
    %lab_he = (imresize(lab_he, [250, NaN]));
    
    ab = lab_he;
    nrows = size(ab,1);
    ncols = size(ab,2);
    ab = reshape(ab,nrows*ncols,3);
    count = 0;
    while(count < 5)
        [cluster_idx, cluster_center] = kmeans(ab,nColors,'distance','sqEuclidean', 'Replicates',3);
        pixel_labels = reshape(cluster_idx,nrows,ncols)-1;
        
        Invert = InversionDecisionRGB( lab_he*255, cluster_center*255, SampleWidthR, SampleHeightR, SkinWidthR, SkinHeightR  );
    
        if Invert == 1
            pixel_labels = not(pixel_labels);
        end
        
        %sum(sum(pixel_labels))/(size(pixel_labels,1)*size(pixel_labels,2))
        if((sum(sum(pixel_labels))/(size(pixel_labels,1)*size(pixel_labels,2)) < maxCutOff && sum(sum(pixel_labels))/(size(pixel_labels,1)*size(pixel_labels,2)) > minCutOff))
            break;
        end
        count=count+1;
    end
    
    im = double(im);
    cluster_center = cluster_center*255;
    ErrorOne = sqrt(((im(:,:,1) - cluster_center(1, 1)).^2) + ((im(:,:,2) - cluster_center(1, 2)).^2) + ((im(:,:,3) - cluster_center(1, 3)).^2));
    ErrorTwo = sqrt(((im(:,:,1) - cluster_center(2, 1)).^2) + ((im(:,:,2) - cluster_center(2, 2)).^2) + ((im(:,:,3) - cluster_center(2, 3)).^2));
    cluster_center = cluster_center/255;
    
    Mask = ErrorOne > ErrorTwo;
    
    if Invert == 1
            Mask = not(Mask);
    end
    
end

