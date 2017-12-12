function [ UnWrapped ] = GetUnwrap( BlobMask, IM, MinorAxis, DepthFactor )
%GETUNWRAP 
%   This unwraps the blob layer by layer similar to that of an onion's skin. 
%   The resultant image is the blob spread out. Imagine take the center of the blob and 
%   pushing it outwards to one side of the image and morphing the rest to fit a rectangle. 
    WorkMask = BlobMask;
    [sizeR, sizeC] = size(WorkMask);
    WorkMask = bwmorph(bwconvhull(WorkMask), 'erode', 0.001 * sqrt(sizeC*sizeR));
    for i = 1:sizeC
        if WorkMask(floor(sizeR/2), i) == 1
            StartPointC = i;
            break;
        end
    end
    t1 = bwtraceboundary(WorkMask, [floor(sizeR/2), StartPointC], 'N', 8, Inf, 'clockwise');
    WorkMask = WorkMask - bwperim(WorkMask);
    [length dummy] = size(t1);
    UnWrapped = IM(sub2ind(size(IM),t1(:,1), t1(:,2)));
    for i=1:(MinorAxis*0.5*DepthFactor)
        for j = StartPointC:sizeC
            if WorkMask(floor(sizeR/2), j) == 1
                StartPointC = j;
                break;
            end
        end
        t1 = bwtraceboundary(WorkMask, [floor(sizeR/2), StartPointC], 'N', 8, Inf, 'clockwise');
        if size(t1) == 0
            break;
        end
        Line = IM(sub2ind(size(IM),t1(:,1), t1(:,2)));
        Line = imresize(Line, [length 1]);
        UnWrapped = [UnWrapped Line];
        WorkMask = WorkMask - bwperim(WorkMask);  

    end
    UnWrapped = UnWrapped';
end

