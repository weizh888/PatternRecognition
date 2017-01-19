% CSE426 Final Project - Preprocess & Extract New features
% Wei Zhang (wez311@lehigh.edu)

clear all; close all; clc;

dataset = {'A' 'B' 'C' 'D'};
Typeface = {'AR' 'CB' 'CI' 'CR' 'HB' 'HI' 'HR' 'TB' 'TI' 'TR'};
for SetNum = 1:4
    TempPixel = [];
    TempMoment = [];
    TempHole = [];
    TempWidth = []; TempHeight = [];
    TempTotPixel = []; TempUpPixel = []; TempDownPixel = []; TempULPixel = []; TempURPixel = []; TempDLPixel = []; TempDRPixel = [];
    TempSlope = [];
    TempRowPixel = []; TempColPixel = [];
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
        
        %% Extract image features
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
            TempPixel = [TempPixel; reshape(I(:,:,sample),[1 256])];
            TempWidth = [TempWidth; 1-length(find(sum(I(:,:,sample),1)==0))];
            TempHeight = [TempHeight; 1-length(find(sum(I(:,:,sample),2)==0))];
            
            SlopeFactor = [7 6 5 4 3 2 1 0 0 1 2 3 4 5 6 7]';
            TempSlope = [TempSlope; sum(I(:,:,sample))*SlopeFactor];
            
            TempTotPixel = [TempTotPixel; sum(sum(I(:,:,sample)))];
            TempUpPixel = [TempUpPixel; sum(sum(I(1:8,:,sample)))];
            TempDownPixel = [TempDownPixel; sum(sum(I(9:16,:,sample)))];
            TempULPixel = [TempULPixel; sum(sum(I(1:8,1:8,sample)))];
            TempURPixel = [TempURPixel; sum(sum(I(1:8,9:16,sample)))];
            TempDLPixel = [TempDLPixel; sum(sum(I(9:16,1:8,sample)))];
            TempDRPixel = [TempDRPixel; sum(sum(I(9:16,9:16,sample)))];
            
            TempRowPixel = [TempRowPixel; sum(I(3:14,:,sample),2)'];
            TempColPixel = [TempColPixel; sum(I(:,3:14,sample),1)]; % don't use 4 columns to get rid of singular covariance matrix
            
            % size of the hole on the upper half of letter "e"
            HoleSize = 0;
            for row = 1:8
                countw = 0;
                flag = 0;
                for column = 1:16
                    if flag == 0 && I(row,column,sample)==1
                        flag = 1;
                    end
                    if flag == 1 && I(row,column,sample)==0
                        flag = 2;
                    end
                    if flag == 2 && I(row,column,sample)==1
                        flag = 3;
                    end
                end
                % for rows that have dot points inside
                if flag == 3
                    column = 1;
                    while I(row,column,sample) == 0
                        countw = countw+1;
                        column = column+1;
                    end
                    column = 16;
                    while I(row,column,sample) == 0
                        countw = countw+1;
                        column = column-1;
                    end
                    HoleSize = HoleSize+length(find(I(row,:,sample)==0))-countw;
                end
            end
            TempHole = [TempHole; HoleSize];
        end
        
        % Calculate "Central Moment" image features
        for sample = 1:100
            Moment_Sample = [
                CentralMoment(I(:,:,sample),1,1) CentralMoment(I(:,:,sample),2,1) CentralMoment(I(:,:,sample),1,2)...
                CentralMoment(I(:,:,sample),3,1) CentralMoment(I(:,:,sample),2,2) CentralMoment(I(:,:,sample),1,3)...
                CentralMoment(I(:,:,sample),4,1) CentralMoment(I(:,:,sample),3,2) CentralMoment(I(:,:,sample),2,3)...
                CentralMoment(I(:,:,sample),1,4) CentralMoment(I(:,:,sample),3,3) CentralMoment(I(:,:,sample),4,2)...
                CentralMoment(I(:,:,sample),2,4) CentralMoment(I(:,:,sample),1,5) CentralMoment(I(:,:,sample),5,1)...
                CentralMoment(I(:,:,sample),3,4) CentralMoment(I(:,:,sample),2,5) CentralMoment(I(:,:,sample),1,6)...
                CentralMoment(I(:,:,sample),5,2) CentralMoment(I(:,:,sample),4,3)...
                CentralMoment(I(:,:,sample),6,1) CentralMoment(I(:,:,sample),7,1) CentralMoment(I(:,:,sample),6,2)...
                CentralMoment(I(:,:,sample),5,3) CentralMoment(I(:,:,sample),4,4) CentralMoment(I(:,:,sample),3,5)...
                CentralMoment(I(:,:,sample),2,6) CentralMoment(I(:,:,sample),1,7) CentralMoment(I(:,:,sample),8,1)...
                CentralMoment(I(:,:,sample),7,2) CentralMoment(I(:,:,sample),6,3) CentralMoment(I(:,:,sample),5,4)...
                CentralMoment(I(:,:,sample),4,5) CentralMoment(I(:,:,sample),3,6) CentralMoment(I(:,:,sample),2,7)...
                CentralMoment(I(:,:,sample),1,8) CentralMoment(I(:,:,sample),9,1) CentralMoment(I(:,:,sample),8,2)...
                CentralMoment(I(:,:,sample),2,8) CentralMoment(I(:,:,sample),1,9)...
                ];
            TempMoment = [TempMoment; Moment_Sample];
        end
    end
    PixelFeature.(dataset{SetNum}) = TempPixel;
    MomentFeature.(dataset{SetNum}) = TempMoment;
    CombinedFeature.(dataset{SetNum}) = [TempMoment TempTotPixel TempColPixel TempRowPixel TempUpPixel TempULPixel TempWidth TempHeight TempSlope TempHole];
end

%% Normalize image features
% calculate RMS value from training data
CombinedFeature_A_RMS = sqrt(sum(CombinedFeature.A.^2,1)/1000);

% use normalized factors from training data
CombinedFeatureNum = length(CombinedFeature.A(1,:));
for SetNum = 1:4
    for rr = 1:CombinedFeatureNum
        CombinedFeature.(dataset{SetNum})(:,rr) = CombinedFeature.(dataset{SetNum})(:,rr)/CombinedFeature_A_RMS(1,rr);
    end
end

%% Expand the feature matrix
for SetNum = 1:4
    %     Feature.(dataset{SetNum}) = [PixelFeature.(dataset{SetNum}) CombinedFeature.(dataset{SetNum})];
    Feature.(dataset{SetNum}) = [CombinedFeature.(dataset{SetNum})];
    Feature.(dataset{SetNum})(~isfinite(Feature.(dataset{SetNum})))=0;
end

for TrainClass = 1:10
    Feature_A_Mean(TrainClass, :) = mean(Feature.A(100*(TrainClass-1)+1:100*TrainClass,:));
end
