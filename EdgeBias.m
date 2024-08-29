clc
clear all
close all

cd ExpData/
settingArr = zeros(2, 20000); % Preallocate matrix with enough space
index = 1;
arr = zeros(1,12);

for Sub = 1:12

    x = index;
    for Day = 1:5
        folderName = ['Sub', sprintf('%02d', Sub), '/Day', num2str(Day)];
        cd(folderName);

        d = dir('Aspect*.mat');

        for sess = 1:length(d)
            load(d(sess).name, 'allMatches', 'nMatches');

            for j = 1:nMatches
                allFirst = allMatches{j}(1);
                allLast = allMatches{j}(end);

                % Store values in settingArr
                settingArr(1, index) = allFirst;
                settingArr(2, index) = allLast;

                index = index + 1; % Increment index for next value
            end
        end

        cd ../../
    end

    y = index -1;

    % Extract data for the current Sub and calculate correlation
    if x <= y % Ensure there is data for the current Sub
        subSettingArr = settingArr(:, x:y);
        % Remove NaN values if present
        subSettingArr = subSettingArr(:, ~isnan(subSettingArr(1, :)) & ~isnan(subSettingArr(2, :)));

        if ~isempty(subSettingArr)
            [correlationCoefficient, pValue] = corr(subSettingArr(1, :)', subSettingArr(2, :)');
            arr(Sub) = correlationCoefficient;
            disp(['Sub', sprintf('%02d', Sub), ': Correlation coefficient = ', num2str(correlationCoefficient)]);
            disp(['Sub', sprintf('%02d', Sub), ': P-value = ', num2str(pValue)]);
        else
            disp(['Sub', sprintf('%02d', Sub), ': No valid data found.']);
        end
    else
        disp(['Sub', sprintf('%02d', Sub), ': No data collected.']);
    end
end
