% Classifier 1: Moment-space minimum-distance classifier

close all; clc;
clearvars -except Feature Feature_A_Mean
dataset = {'A' 'B' 'C' 'D'};

%% Test dataset A, B, C, D
Confusion_Table = zeros(10, 10, length(dataset));
for SetNum = 1:4
    distance = zeros(1000, 10);
    for FileNum = 1:10
        for TestSample = 1:100
            for TrainClass = 1:10
                distance((FileNum-1)*100+TestSample, TrainClass) = sqrt(sum((Feature.(dataset{SetNum})((FileNum-1)*100+TestSample,:)-Feature_A_Mean(TrainClass,:)).^2));
            end
            [Y, I] = min(distance((FileNum-1)*100+TestSample, :));
            class(TestSample) = I-1;
        end
        Confusion_Table(FileNum,:,SetNum) = histc(class, 0:9);
    end
    Error_Rate.(dataset{SetNum}) = (1000-trace(Confusion_Table(:,:,SetNum)))/1000;
end

Error_Rate
Average_Error_Rate = (Error_Rate.B+Error_Rate.C+Error_Rate.D)/3
Confusion_Table