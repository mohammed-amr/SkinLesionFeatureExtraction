%edge roughness
JaggedBlobsLabeled = bwlabel(FilledIn);
JaggedBlobProp = regionprops(JaggedBlobsLabeled, 'Area', 'MinorAxisLength', 'MajorAxisLength');
[Sorted, Sorted] = sort([JaggedBlobProp.Area],'descend');
LargestJaggedBlobProp = JaggedBlobProp(Sorted(1));
LargestJaggedBlob = (JaggedBlobsLabeled == Sorted(1));


% figure;
% imshow(LargestJaggedBlob);
per = bwboundaries(LargestJaggedBlob, 8, 'noholes');
per = (cell2mat(per(1)))';
[R JaggedLength] = size(per);
VertexNum = JaggedLength/RoughVal;
Simp = (reduce_poly(per, VertexNum))';
Simp = [Simp(:,2) Simp(:,1)];
SimplePoly = zeros(size(LargestJaggedBlob));
% SimplePoly(sub2ind(size(LargestJaggedBlob), Simp(:,2), Simp(:,1))) = 1;
for i = 1:size(Simp, 1)-1
    [RLin, CLine] = bresenham(Simp(i,2),Simp(i,1),Simp(i+1,2),Simp(i+1,1));
    SimplePoly(sub2ind(size(LargestJaggedBlob), RLin, CLine)) = 1;
end

SimplePerimLength = sum(sum(SimplePoly));
Roughness = JaggedLength/SimplePerimLength;

imshow(SimplePoly);

