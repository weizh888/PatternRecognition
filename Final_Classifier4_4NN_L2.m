% 5NN in pixel space, under the Euclidian (Minkowski L2) metric

close all; clc;
clearvars -except Feature
dataset = {'A' 'B' 'C' 'D'};

%% Test dataset A, B, C, D
Confusion_Table = zeros(10, 10, length(dataset));
for SetNum = 1:4
    ndistance = zeros(1000, 1000);
    class_4NN = zeros(1, 4); % 4NN
    for FileNum = 1:10
        class = zeros(1, 100);
        for TestSample = 1:100
            % calculate the distance between each sample and 1000 training samples
            for TrainSample = 1:1000
                ndistance((FileNum-1)*100+TestSample, TrainSample) = sqrt(sum((Feature.(dataset{SetNum})((FileNum-1)*100+TestSample, :)-Feature.A(TrainSample, :)).^2));
            end
            % count the five nearest neighbors of each test sample
            [B, Index] = sort(ndistance((FileNum-1)*100+TestSample, :));
            
            % classes of 4 nearest neighbors for each test sample           
            count = zeros(1, 10);
            for k = 1:4
                class_4NN(k) = ceil(Index(k)/100); % between 1 ~ 10
                for class_value = 1:10
                    if class_4NN(k) == class_value
                        count(class_value) = count(class_value) + 1;
                    end
                end
            end
            % decide the class of each test sample
            [Y, I] = max(count); % automatically break ties lexically
            class(TestSample) = I-1;
        end
        %         confusion_table(FileNum, :) = histc(class, 1:10)
        
        
        %         for class_value = 0:9
        %             count(class_value+1) = length(find(class_5NN == class_value));
        %         end
        %
        %         % decide the class of each test sample
        %         [Y, I] = max(count);
        %         if length(I) == 1 % max(count)>=3, or count = [2 1 1 1 0 0 0 0 0 0]
        %             class(TestSample) = I-1;
        %         elseif length(I) == 2 % count = [2 2 1 0 0 0 0 0 0 0]
        %             z = randi(2, 1, 1);
        %             class(TestSample) = I(z)-1;
        %         else % count = [1 1 1 1 1 0 0 0 0 0]
        %             z = randi(5, 1, 1);
        %             class(TestSample) = I(z)-1;
        %         end
        %     end
        Confusion_Table(FileNum,:,SetNum) = histc(class, 0:9);
    end
    Error_Rate.(dataset{SetNum}) = (1000-trace(Confusion_Table(:,:,SetNum)))/1000;
end

Error_Rate
Confusion_Table