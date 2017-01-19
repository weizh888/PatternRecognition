% Classification 5: Neural Networks

close all; clc;
clearvars -except Feature
dataset = {'A' 'B' 'C' 'D'};

%% Test dataset A, B, C, D
Confusion_Train = zeros(10, 10, length(dataset));
Confusion_Test = zeros(10, 10, length(dataset));
for SetNum = 1:4
    target_matrix = zeros(10, 2000);
    for column = 1:10
        target_matrix(column, (column-1)*100+1:column*100) = 1;
        target_matrix(column, (column-1)*100+1001:column*100+1000) = 1;
    end
    % dataset used to train and test
    datasets = [Feature.A' Feature.(dataset{SetNum})'];
    
    % nprtool
    % Solve a Pattern Recognition Problem with a Neural Network
    inputs = datasets;
    targets = target_matrix;
    
    % Create a Pattern Recognition Network
    hiddenLayerSize = 20; % set hidden layer to 20
    net = patternnet(hiddenLayerSize);
    
    % Setup Division of Data for Training, Validation, Testing
    net.divideParam.trainRatio = 50/100;
    net.divideParam.valRatio = 0/100;
    net.divideParam.testRatio = 50/100;
    
    % Train the Network
    [net,tr] = train(net,inputs,targets);
    
    % Test the Network
    outputs = net(inputs);
    errors = gsubtract(targets,outputs);
    performance = perform(net,targets,outputs);
    
    classes = vec2ind(outputs);
    class_histo_train = reshape(classes(1:1000), 100, 10);
    class_histo_test = reshape(classes(1001:2000), 100, 10);
    
    % draw confusion table
    for FileNum = 1:10
        Confusion_Train(FileNum,:,SetNum) = histc(class_histo_train(:, FileNum), 1:10);
        Confusion_Test(FileNum,:,SetNum) = histc(class_histo_test(:, FileNum), 1:10);
    end
    Error_Train.(dataset{SetNum}) = (1000-trace(Confusion_Train(:,:,SetNum)))/1000;
    Error_Test.(dataset{SetNum}) = (1000-trace(Confusion_Test(:,:,SetNum)))/1000;
    
    % % View the Network
    %     view(net)
    
    %     % Plots
    %     % Uncomment these lines to enable various plots.
    %     figure, plotperform(tr)
    %     figure, plottrainstate(tr)
    %     figure, plotconfusion(targets,outputs)
    %     figure, ploterrhist(errors)
end
%%
Error_Test % display the error rate of test data
Confusion_Test % display the confusion table of test data