% Classifier 4: 5NN in moment space, under the Euclidian (Minkowski L2) metric

close all; clc;
clearvars -except Feature
dataset = {'A' 'B' 'C' 'D'};

%% Test dataset A, B, C, D
Confusion_Table = zeros(10, 10, length(dataset));
for SetNum = 1:4
    distance = zeros(1000, 1000);
    class_5NN = zeros(1, 5);
    for FileNum = 1:10
        class = zeros(1, 100);
        for TestSample = 1:100
            % calculate the distance between each sample and 1000 training samples
            for TrainSample = 1:1000
                distance((FileNum-1)*100+TestSample, TrainSample) = sqrt(sum((Feature.(dataset{SetNum})((FileNum-1)*100+TestSample, :)-Feature.A(TrainSample, :)).^2));
            end
            % count the five nearest neighbors of each test sample
            [B, Index] = sort(distance((FileNum-1)*100+TestSample, :));
            
            % classes of 5 nearest neighbors for each test sample
            class_5NN = floor((Index(1:5)-1)/100); % between 0 ~ 9
            count = zeros(1, 10);
            for class_value = 0:9
                count(class_value+1) = length(find(class_5NN == class_value));
            end
            
            % decide the class of each test sample
            [Y, I] = max(count);
            if length(I) == 1 % max(count)>=3, or count = [2 1 1 1 0 0 0 0 0 0]
                class(TestSample) = I-1;
            elseif length(I) == 2 % count = [2 2 1 0 0 0 0 0 0 0]
                z = randi(2, 1, 1);
                class(TestSample) = I(z)-1;
            else % count = [1 1 1 1 1 0 0 0 0 0]
                z = randi(5, 1, 1);
                class(TestSample) = I(z)-1;
            end
        end
        Confusion_Table(FileNum,:,SetNum) = histc(class, 0:9);
    end
    Error_Rate.(dataset{SetNum}) = (1000-trace(Confusion_Table(:,:,SetNum)))/1000;
end

Error_Rate
Average_Error_Rate = (Error_Rate.B+Error_Rate.C+Error_Rate.D)/3
Confusion_Table