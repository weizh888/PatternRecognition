% Classification 5: SVM

close all; clc;
clearvars -except Feature
dataset = {'A' 'B' 'C' 'D'};

%% Test dataset A, B, C, D
Confusion_Table = zeros(10, 10, length(dataset));
for SetNum = 1:4
    TrainingSet = Feature.A; % 1000 by (256 + 20)
    TestSet = Feature.(dataset{SetNum});
    
    GroupTrain = zeros(1000, 1);
    for i = 1:1000
        GroupTrain(i) = ceil(i/100);
    end
    results = multisvm(TrainingSet, GroupTrain, TestSet); % use SVM
    
    class = zeros(1, 100);
    for FileNum = 1:10
        for TestSample = 1:100
            class(TestSample) = results(100*(FileNum-1)+TestSample);
        end
        Confusion_Table(FileNum, :, SetNum) = histc(class, 1:10);
    end
    Error_Rate.(dataset{SetNum}) = (1000-trace(Confusion_Table(:,:,SetNum)))/1000;
end

Error_Rate
Average_Error_Rate = (Error_Rate.B+Error_Rate.C+Error_Rate.D)/3
Confusion_Table