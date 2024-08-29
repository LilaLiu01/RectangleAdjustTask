%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   blockPattern.m Apr 1, 2024
%   by Sean Liu
%   This script visualize the variability of each block for each
%   participants, and the potential trends residing in each type of blcok.
%   1. Fresh off block (2 blk/d)
%   2. First on blcoks (2 blk/d)
%   3. 1-hr-on blocks (2 blk/d)
%   4. 2-hr-on blocks (2 blk/d)
%   5. Immediate off blocks (2 blk/d)
%   Please enter the Subject Number to for each participant.
%   eg. For Subject 1, please enter 1 in the prompt.

function blockPattern()
clc
clear all
close all
clear all figure
cd '~/Documents/MATLAB/VisionImageLab/NewGlasses/ExpData'
SubNum = input('Enter the SubNum: ');
cd (['Sub0' num2str(SubNum)]);

% Init vars
numDay = 5;
BlkperDay = 10;
allmns = zeros(numDay,BlkperDay);
alltyps = zeros(numDay,BlkperDay);
allstd = zeros(numDay,BlkperDay);
allrange = zeros(numDay,BlkperDay);

    for iday = 1:numDay
        cd (['Day' num2str(iday)]);
    
        d = dir('Aspect*.mat'); % 10 blocks per day
        figure(iday);
        tot = 1;
    
    
        for sess = 1:length(d)
            load(d(sess).name,'allMatches','nMatches', 'allTimings');
            allLast = zeros(1,nMatches);
            trialTime = zeros(1,nMatches);
            aftereffect = 0;
    
            % Read in adjusted aspect ratio, exact times
            for j = 1:nMatches
                allLast(j) = allMatches{j}(end);

                % Confirm starting time
                firstTrial = allTimings{1};
                startTime = firstTrial(1);
                trialTime(j) = allTimings{j}(end) - startTime;
            end

            % Determine block type
            if ~isempty(strfind(d(sess).name,'glasseson'))
                sym = 'r*';  %Glasses on
                cstyle = 'r-';
                alltyps(iday, sess) = 1;
    
            elseif mod(sess,5) == 0
                alltyps(iday, sess) = 2; %aftereffect
                sym = 'k*';
                cstyle = 'k-';
                aftereffect = 1;
    
            else
                sym = 'ko';  %Off
                cstyle = 'k-';
            end
    
            % Calculate matrices
            allmns(iday, sess) = mean(allLast);
            allstd(iday, sess) = std(allLast,0,"all");
            allrange(iday, sess) = max(allLast) - min(allLast);
    
            % Plotting
            plot(tot:(tot+nMatches-1),allLast,sym); hold on;
            plot(tot:(tot+nMatches-1), allLast, cstyle); hold on; % Smoothly connect all
            plot([tot, (tot+nMatches-1)],[mean(allLast),mean(allLast)],'k-', 'LineWidth', 2);
            tot = tot+nMatches;
            title(['Day' num2str(iday)]);
    
            % A trend for tilt aftereffect (averaged all sessions) + plots
            % Try averaged aftereffect (for first 3 days?)
            % interpolate: linterp
            % firstBlock = allTimings{1}
            % secondBlk = allTimings{2}
            % firstBlock(end) - firstBlock(1)
            % secondBlk(end) - firstBlock(1)
            % Form: y=A⋅exp(−kx); A = amplitude; k = dacay rate.
            if aftereffect == 1
                ori_x = trialTime;
                ori_y = allLast;    
                new_x = ceil(trialTime(1)):1:floor(trialTime(end));
                len = length(new_x);
                new_y = interp1(ori_x, ori_y, new_x, 'nearest');
                
               
                exp_model = @(b, x) b(1) * exp(b(2) * x);
                % Initial guess for parameters
                b0 = [36, 0];
                % Fitting as function of time, not matches.
                % b_fit = lsqcurvefit(exp_model, b0, tot:(tot+nMatches-1), allLast);
                b_fit = lsqcurvefit(exp_model, b0, 1:len, new_y);

                disp(['Day' num2str(iday), '  Off block ' num2str(sess/5)]);
                disp('Fitted Parameters:');
                disp(['Amplitude: ' num2str(b_fit(1))]);
                disp(['Decay Rate: ' num2str(b_fit(2))]);
            end
    
            % Calculate midpoint
            line_x = [tot, (tot+nMatches-1)];
            mid_x = mean(line_x);
            mid_y = mean(allLast);
    
            % Text annotations for std and range
            text(mid_x, mid_y - 0.5, ...
                ['Std: ' num2str(allstd(iday, sess))], 'Color', 'blue', ...
                'HorizontalAlignment', 'center');
            text(mid_x, mid_y - 1, ...
                ['Range: ' num2str(allrange(iday, sess))], 'Color', 'red', ...
                'HorizontalAlignment', 'center');
    
    
        end
    
        % Print and save
        disp(['Std of Day ' num2str(iday) ':']);
        disp(allstd(iday, :));
    
        % Return to the original directory
        cd ..
    
    end
    save(['allstd.mat'], 'allstd');
    save(['allrange.mat'], 'allrange');
end
