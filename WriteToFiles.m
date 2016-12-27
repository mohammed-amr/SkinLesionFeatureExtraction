%no need to worry about this.

MelanomaVectors = [MelanomaVectors ones(size(MelanomaVectors,1), 1)];
NotMelVectors = [NotMelVectors zeros(size(NotMelVectors,1), 1)];



MelanomaVectorsTraining = MelanomaVectors(1:floor(size(MelanomaVectors, 1)*0.9),:);
MelanomaVectorsValidation = MelanomaVectors(ceil(size(MelanomaVectors, 1)*0.9):end,:);

NotMelVectorsTraining = NotMelVectors(1:floor(size(NotMelVectors, 1)*0.9),:);
NotMelVectorsValidation = NotMelVectors(ceil(size(NotMelVectors, 1)*0.9):end,:);

FinalVecTraining = [MelanomaVectorsTraining; NotMelVectorsTraining];
FinalVecValidation = [MelanomaVectorsValidation; NotMelVectorsValidation];

FinalVecTrainingShuffled = FinalVecTraining(randperm(end),:);
FinalVecValidationShuffled = FinalVecValidation(randperm(end),:);

%%dlmwrite('Training.txt',FinalVecTrainingShuffled,' ');

fid = fopen('Training.txt','wt');

for i = 1:size(FinalVecTrainingShuffled, 1)
    fprintf(fid, '|features ');
    for j = 1:size(FinalVecTrainingShuffled,2)-1;
         fprintf(fid, num2str(FinalVecTrainingShuffled(i,j)));
         fprintf(fid, ' ');
    end
    j = size(FinalVecTrainingShuffled,2);
    fprintf(fid, '|labels ');
    fprintf(fid, num2str(FinalVecTrainingShuffled(i,j)));
    fprintf(fid, '\r\n');
end

fclose(fid);

%dlmwrite('Validation.txt',FinalVecValidationShuffled,' ');

fid = fopen('Validation.txt','wt');

for i = 1:size(FinalVecValidationShuffled, 1)
    fprintf(fid, '|features ');
    for j = 1:size(FinalVecValidationShuffled,2)-1;
         fprintf(fid, num2str(FinalVecValidationShuffled(i,j)));
         fprintf(fid, ' ');
    end
    j = size(FinalVecValidationShuffled,2);
    fprintf(fid, '|labels ');
    fprintf(fid, num2str(FinalVecValidationShuffled(i,j)));
    fprintf(fid, '\r\n');
end

fclose(fid);

