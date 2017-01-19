% Classifier 2: Moment-space classifier with identical covariances

close all; clc;
clearvars -except Feature Feature_A_Mean
dataset = {'A' 'B' 'C' 'D'};

%% Calculate the covariance matrix (20 by 20)
FeatureNum = length(Feature.A(1,:));
CovarianceMatrix = zeros(FeatureNum,FeatureNum,10);
for TrainClass = 1:10
    x = Feature.A((TrainClass-1)*100+1:(TrainClass-1)*100+100,:)';
    mu = repmat(Feature_A_Mean(TrainClass,:),100,1)';
    CovarianceMatrix(:,:,TrainClass) = (x-mu)*(x-mu)'/100;
end
CovarianceMean = mean(CovarianceMatrix, 3);

%% Test dataset A, B, C, D
Confusion_Table = zeros(10, 10, length(dataset));
for SetNum = 1:4
    g_i = zeros(1000, 10);
    for FileNum = 1:10
        for TestSample = 1:100
            for TrainClass = 1:10
                w_i = CovarianceMean^(-1)*Feature_A_Mean(TrainClass,:)';
                w_i0 = -1/2*Feature_A_Mean(TrainClass,:)*CovarianceMean^(-1)*Feature_A_Mean(TrainClass,:)';
                g_i((FileNum-1)*100+TestSample, TrainClass) = w_i'*Feature.(dataset{SetNum})((FileNum-1)*100+TestSample,:)'+w_i0;
            end
            [Y, I] = max(g_i((FileNum-1)*100+TestSample, :));
            class(TestSample) = I-1;
        end
        Confusion_Table(FileNum,:,SetNum) = histc(class, 0:9);
    end
    Error_Rate.(dataset{SetNum}) = (1000-trace(Confusion_Table(:,:,SetNum)))/1000;
end

Error_Rate
Average_Error_Rate = (Error_Rate.B+Error_Rate.C+Error_Rate.D)/3
Confusion_Table