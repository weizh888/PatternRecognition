% CSE426 Final Project - Preprocess & Extract Moment features
% Wei Zhang (wez311@lehigh.edu)

clear all; close all; clc;

dataset = {'A' 'B' 'C' 'D'};
Typeface = {'AR' 'CB' 'CI' 'CR' 'HB' 'HI' 'HR' 'TB' 'TI' 'TR'};
for SetNum = 1:4
    TempMoment = [];
    for FileNum = 1:10
        i1 = 1;
        FileName = ['C-V\' dataset{SetNum} '-' Typeface{FileNum},'.txt'];
        fid1 = fopen(FileName);
        while 1
            tline = fgetl(fid1);
            if ~ischar(tline),   break,   end
            %     disp(tline);
            data(i1,1:length(tline)) = tline;
            i1 = i1+1;
        end
        fclose(fid1);
        
        line_ind = 1;
        image_ind = 1;
        count = 0; % count the number of 2-digit height images
        while line_ind < length(data)
            if data(line_ind,1) ~= 'C', break,  end
            if data(line_ind,5) == ' '
                height = str2num(data(line_ind,4));  % 1-digit height
                if data(line_ind, 8) == ' '
                    width = str2num(data(line_ind, 7)); % 1-digit width
                else
                    width = str2num(data(line_ind, 7:8)); % 2-digit width
                end
            else
                count = count + 1;
                height = str2num(data(line_ind,4:5)); % 2-digit height
                if data(line_ind,9) == ' '
                    width = str2num(data(line_ind, 8)); % 1-digit width
                else
                    width = str2num(data(line_ind, 8:9)); % 2-digit width
                end
            end
            
            %% Preprocess each image
            height_margin = 16-height;
            width_margin = 16-width;
            Top_Margin = ceil(height_margin/2);
            Left_Margin = ceil(width_margin/2);
            for row = 1:16
                for column = 1:16
                    if Top_Margin+1 <= row && row <= Top_Margin+height && Left_Margin+1 <= column && column <= Left_Margin+width
                        image(row,column,image_ind) = data(line_ind+row-Top_Margin, column-Left_Margin);
                    else
                        image(row,column,image_ind) = '.';
                    end
                end
            end
            
            image_ind = image_ind + 1;
            line_ind = line_ind + height + 1;
        end
        
        %% Extract "Central Moment" image features
        % Initialize the pixel value I(x,y,image) of the pattern image matrix
        I = zeros(16,16,100);
        for sample = 1:100
            for row = 1:16
                for column = 1:16
                    if image(row,column,sample) == 'x'
                        I(row,column,sample) = 1;
                    else
                        I(row,column,sample) = 0;
                    end
                end
            end
        end
        % Calculate "Central Moment" image features
        for sample = 1:100
            Moment_Sample = [CentralMoment(I(:,:,sample),1,1) CentralMoment(I(:,:,sample),2,1) CentralMoment(I(:,:,sample),1,2)...
                CentralMoment(I(:,:,sample),3,1) CentralMoment(I(:,:,sample),2,2) CentralMoment(I(:,:,sample),1,3)...
                CentralMoment(I(:,:,sample),4,1) CentralMoment(I(:,:,sample),3,2) CentralMoment(I(:,:,sample),2,3)...
                CentralMoment(I(:,:,sample),1,4) CentralMoment(I(:,:,sample),3,3) CentralMoment(I(:,:,sample),4,2)...
                CentralMoment(I(:,:,sample),2,4) CentralMoment(I(:,:,sample),1,5) CentralMoment(I(:,:,sample),5,1)...
                CentralMoment(I(:,:,sample),3,4) CentralMoment(I(:,:,sample),2,5) CentralMoment(I(:,:,sample),1,6)...
                CentralMoment(I(:,:,sample),5,2) CentralMoment(I(:,:,sample),4,3)];
            TempMoment = [TempMoment; Moment_Sample];
        end
    end
    MomentFeature.(dataset{SetNum}) = TempMoment;
end

%% Normalize "Central Moment" image features
% calculate RMS value from training data
Feature_A_RMS = sqrt(sum(MomentFeature.A.^2,1)/1000);

% use normalized factors from training data
FeatureNum = length(MomentFeature.A(1,:));
for SetNum = 1:4
    for rr = 1:FeatureNum
        Feature.(dataset{SetNum})(:,rr) = MomentFeature.(dataset{SetNum})(:,rr)/Feature_A_RMS(1,rr);
    end
end

for TrainClass = 1:10
    Feature_A_Mean(TrainClass, :) = mean(Feature.A(100*(TrainClass-1)+1:100*TrainClass,:));
end
