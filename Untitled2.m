imshow(WorkBlockMask);
test = WorkBlockMask;
[sizeR sizeC] = size(test);
test = bwmorph(bwconvhull(test), 'erode', 0.001 * sqrt(sizeC*sizeR));
figure;
imshow(test);
figure;
imshow(test);
hold on
for i = 1:sizeC
    if test(floor(sizeR/2), i) == 1
        StartPointC = i;
        break;
    end
end

for i=1:250
    for j = 1:sizeC
        if test(floor(sizeR/2), j) == 1
            StartPointC = j;
            break;
        end
    end
    t1 = bwtraceboundary(test, [floor(sizeR/2), StartPointC], 'N', 8, Inf, 'clockwise');
    scatter(t1(1,2), t1(1,1), 100, 'yellow');
    scatter(t1(5,2), t1(5,1), 100, 'blue');
    test = test - bwperim(test);
    
end

