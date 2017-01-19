% Classifier 3: 1NN in moment space, under the Euclidian (Minkowski L2) metric

close all; clc;
clearvars -except Feature
dataset = {'A' 'B' 'C' 'D'};

%% Test dataset A, B, C, D
Confusion_Table = zeros(10, 10, length(dataset));
for SetNum = 1:4
    distance = zeros(1000, 1000);
    for FileNum = 1:10
        for TestSample = 1:100
            for TrainSample = 1:1000
                % 1-NN in moment space under L2 metric
                distance((FileNum-1)*100+TestSample, TrainSample) = sqrt(sum((Feature.(dataset{SetNum})((FileNum-1)*100+TestSample,:)-Feature.A(TrainSample,:)).^2));
            end
            [Y, I] = min(distance((FileNum-1)*100+TestSample, :));
            class(TestSample) = floor((I-1)/100);
        end
        Confusion_Table(FileNum,:,SetNum) = histc(class, 0:9);
    end
    Error_Rate.(dataset{SetNum}) = (1000-trace(Confusion_Table(:,:,SetNum)))/1000;
end

Error_Rate
Average_Error_Rate = (Error_Rate.B+Error_Rate.C+Error_Rate.D)/3
Confusion_Table