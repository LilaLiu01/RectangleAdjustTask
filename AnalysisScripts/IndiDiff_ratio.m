%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   IndiDiff_rg.m Jul 30, 2024
%   Sean Liu

%% Plot the main results of raw data and baseline-corrected data
clc
clear all
close all
cd ExpData/
figure;
load('ratioAll_onoff.mat'); % raw data
rawAdj = 100*(0.005*rawAdj + 0.795); % convert to aspect ratio
firstSet = 100*(0.005*firstSet + 0.795);
firSubblk = 100*(0.005*firSubblk + 0.795);

TestNum = 50;
SubNum = 12;
SessionNum = 10;
TestperSession = TestNum/SessionNum; % 5

first_BaseIdx = 1:TestperSession*2:TestNum;
second_BaseIdx = 6:TestperSession*2:TestNum;
grandmn = mean(rawAdj(1:SubNum,1:TestNum),1,'omitnan');
grandStdErr = std(rawAdj(1:SubNum,1:TestNum),1,'omitnan')/sqrt(size(rawAdj(1:SubNum,1:TestNum),1));
firSetmn = mean(firstSet(1:SubNum,1:TestNum),1,'omitnan');
firSubblkmn = mean(firSubblk(1:SubNum,1:TestNum),1,'omitnan');


% set the index
BaseIdx = 1:TestperSession:TestNum;
X = [1:TestperSession,  %1:5
    TestperSession+2:2*TestperSession+1,   %7:11
    2*TestperSession+4:3*TestperSession+3,   %14:18
    3*TestperSession+5:4*TestperSession+4,   %20:24
    4*TestperSession+7:5*TestperSession+6,   %27:31
    5*TestperSession+8:6*TestperSession+7,   %33:37
    6*TestperSession+10:7*TestperSession+9,   %40:44
    7*TestperSession+11:8*TestperSession+10,   %46:50
    8*TestperSession+13:9*TestperSession+12,   %53:57
    9*TestperSession+14:10*TestperSession+13];   %59:63
X = reshape(X.', 1, []);

% color the background for 2nd session in each day
div = [6, 12.5, 19, 25.5, 32, 38.5, 45, 51.5, 58, 64.5];
for i = 1:2:length(div)-1
    v = [div(i) 80; div(i+1) 80; div(i+1) 120; div(i) 120];
    f = [1 2 3 4];
    patch('Faces',f,'Vertices',v,...
        'EdgeColor','white','FaceColor','[.9 .9 .9]','LineWidth',0.5,'FaceAlpha',0.4);
end
hold on

% error bars and marker
for i = 1:SessionNum
    errorbar(X((i-1)*TestperSession+2:(i-1)*TestperSession+4),grandmn((i-1)*TestperSession+2:(i-1)*TestperSession+4),grandStdErr((i-1)*TestperSession+2:(i-1)*TestperSession+4),'color',[0.75,0.75,0.75],'LineWidth',2);
    hold on
    on_line = plot(X((i-1)*TestperSession+2:(i-1)*TestperSession+4),grandmn((i-1)*TestperSession+2:(i-1)*TestperSession+4),'k.-','MarkerSize',30,'Color',[0 0.4470 0.7410],'LineWidth',2);
    hold on
    errorbar(X((i-1)*TestperSession+5),grandmn((i-1)*TestperSession+5),grandStdErr((i-1)*TestperSession+5),'color',[0.75,0.75,0.75],'LineWidth',2);
    hold on
    after_line = plot(X((i-1)*TestperSession+5),grandmn((i-1)*TestperSession+5),'k.-','MarkerSize',30,'Color',[0.4660 0.6740 0.1880],'LineWidth',2,'MarkerFaceColor',[0.6,0.9,0.6]);
    hold on
end
lgd = [on_line, after_line];

% line the baseline
baseline = plot(X(BaseIdx),grandmn(BaseIdx),'Color',[0 0 0],'LineStyle','-','MarkerSize',30,'LineWidth',2);
hold on
for i = 1:length(BaseIdx)
    errorbar(X(BaseIdx(i)),grandmn(BaseIdx(i)),grandStdErr(BaseIdx(i)),'color',[0.75,0.75,0.75],'LineWidth',2);
    hold on
end

% mark the baseline
sz = 75;
c1 = [0 0 0];
mk1 = scatter(X(first_BaseIdx),grandmn(first_BaseIdx),sz,c1,'filled');
hold on
mk2 = scatter(X(second_BaseIdx),grandmn(second_BaseIdx),sz,c1,'filled');
hold on
lgd = [lgd, baseline];

% Figure explanation
% ylabel('Aspect Ratio(%)');
ylabel('Magnification (%)');
xlabel('Day');
xticks([6:13:58]);
xticklabels({'1','2','3','4','5'});
xlim([0 64])
ylim([97 105])
% ylim for baseline corrected
% ylim([-80,20])
labels = {'Glasses on', 'Glasses off', 'Baseline'};
legend_obj = legend(lgd, labels, 'Location', 'best');
set(legend_obj, 'FontSize', 15);
set(gca,'FontSize',25);
box on


%% Correlation Analysis
% To investigate the stability of gaining color adaptation, for each session,
% we plotted the corrected magnification as a function of time/trial number
% Correlations of magnification patterns across sessions were higher within each
% participant than between different participants, suggesting stable
% pattern of evolution of perceived skew within each observer.

% Within
Rarr_wt = NaN(SessionNum,SessionNum,SubNum);
Rmean_wt = NaN(SubNum,1);
parr_wt = NaN(SessionNum,SessionNum,SubNum);
for i = 1:SubNum
    for j = 1:SessionNum-1
        for k = j+1:SessionNum
            [R,p] = corrcoef(rawAdj(i,(j-1)*TestperSession+1:(j-1)*TestperSession+TestperSession),rawAdj(i,(k-1)*TestperSession+1:(k-1)*TestperSession+TestperSession), 'Rows', 'pairwise'); % With all trials in each session - see pattern as a whole
            %[R,p] = corrcoef(bMall(i,(j-1)*10+2:(j-1)*10+10),bMall(i,(k-1)*10+2:(k-1)*10+10),'Rows', 'pairwise'); % Exclude baseline in each session
            %[R,p] = corrcoef(bMall(i,(j-1)*10+2:(j-1)*10+6),bMall(i,(k-1)*10+2:(k-1)*10+6), 'Rows', 'pairwise'); % With glasses-on trials in each session
            %[R,p] = corrcoef(bMall(i,(j-1)*10+7:(j-1)*10+10),bMall(i,(k-1)*10+7:(k-1)*10+10), 'Rows', 'pairwise'); % With glasses-off trials in each session
            Rarr_wt(j,k,i) = R(1,2);
            parr_wt(j,k,i) = p(1,2);
        end
    end
    Rmean_wt(i) = nanmean(Rarr_wt(:,:,i),'all'); % For each subject

end
R_indi_wt = nanmean(Rarr_wt,[1 2]);
fprintf('Correlation Coefficients across sessions within each observer: \n');
Rmean_wt


% Between
Rarr_bt = NaN(SessionNum,SessionNum,SubNum,SubNum);
Rmean_bt = NaN(SubNum);
parr_bt = NaN(SessionNum,SessionNum,SubNum,SubNum);
for i = 1:SubNum-1
    for j = i+1:SubNum
        for k = 1:SessionNum
            for l = 1:SessionNum
                [R,p] = corrcoef(rawAdj(i,(k-1)*TestperSession+1:(k-1)*TestperSession+TestperSession),rawAdj(j,(l-1)*TestperSession+1:(l-1)*TestperSession+TestperSession), 'Rows', 'pairwise');
                Rarr_bt(k,l,i,j) = R(1,2);
                parr_bt(k,l,i,j) = p(1,2);
            end
        end
        Rmean_bt(i,j) = nanmean(Rarr_bt(:,:,i,j),'all');
    end
end
R_indi_bt = nanmean(Rarr_bt,[1,2,3]);
fprintf('Correlation Coefficients across sessions between each observer: \n');
Rmean_bt

for s = 1:SubNum
    Rmean_bt_ind(s) = (nansum(Rmean_bt(s,:),'all') + nansum(Rmean_bt(:,s),'all'))/(SubNum-1);
end
observed_diff = Rmean_wt - (Rmean_bt_ind)';


% Permutation
% how surprising is it to get a correlation diff with these data?
n_permutations = 1000;
permuted_diffs = NaN(SubNum, n_permutations);

rawAdj_sub = rawAdj(1:SubNum,:);

permuted_corr_wt = NaN(SubNum,1,n_permutations);
permuted_corr_bt = NaN(SubNum,SubNum,n_permutations);

for n = 1:n_permutations
    % Shuffle and reshape to original
    combined_data = reshape(rawAdj_sub,SessionNum*SubNum, TestperSession);
    combined_data = combined_data(randperm(size(combined_data, 1)), :);
    combined_data = reshape(combined_data, SubNum, TestNum);

    permuted_corr_wt = NaN(SessionNum,SessionNum,SubNum,n_permutations);
    Rmean_wt_perm = NaN(SubNum,1);
    permuted_corr_bt = NaN(SessionNum,SessionNum,SubNum,n_permutations);
    Rmean_bt_perm = NaN(SubNum,SubNum);

    for i = 1:SubNum
        for j = 1:SessionNum-1
            for k = j+1:SessionNum
                [R,p] = corrcoef(rawAdj(i,(j-1)*TestperSession+1:(j-1)*TestperSession+TestperSession),rawAdj(i,(k-1)*TestperSession+1:(k-1)*TestperSession+TestperSession), 'Rows', 'pairwise'); % With all trials in each session - see pattern as a whole
                %[R,p] = corrcoef(bMall(i,(j-1)*10+2:(j-1)*10+10),bMall(i,(k-1)*10+2:(k-1)*10+10),'Rows', 'pairwise'); % Exclude baseline in each session
                %[R,p] = corrcoef(bMall(i,(j-1)*10+2:(j-1)*10+6),bMall(i,(k-1)*10+2:(k-1)*10+6), 'Rows', 'pairwise'); % With glasses-on trials in each session
                %[R,p] = corrcoef(bMall(i,(j-1)*10+7:(j-1)*10+10),bMall(i,(k-1)*10+7:(k-1)*10+10), 'Rows', 'pairwise'); % With glasses-off trials in each session
                Rarr_wt(j,k,i) = R(1,2);
            end
        end
        Rmean_wt_perm(i) = nanmean(Rarr_wt(:,:,i),'all');
    end

    for i = 1:SubNum-1
        for j = i+1:SubNum
            for k = 1:SessionNum
                for l = 1:SessionNum
                    [R,p] = corrcoef(rawAdj(i,(k-1)*TestperSession+1:(k-1)*TestperSession+TestperSession),rawAdj(j,(l-1)*TestperSession+1:(l-1)*TestperSession+TestperSession), 'Rows', 'pairwise');
                    Rarr_bt(k,l,i,j) = R(1,2);
                end
            end
            Rmean_bt_perm(i,j) = nanmean(Rarr_bt(:,:,i,j),'all');
        end
    end

    for s = 1:SubNum
        Rmean_bt_permind(s) = (nansum(Rmean_bt_perm(s,:),'all') + nansum(Rmean_bt_perm(:,s),'all'))/(SubNum-1);
    end
    Rmean_bt_permind = (Rmean_bt_permind)';
    % Calculate the difference in correlation coefficients for the permuted pairs
    diffs = Rmean_wt_perm - (Rmean_bt_permind)';
    permuted_diffs(:,n) = diffs(:,1);
end

% Calculate the p-value
for n = 1:SubNum
    p_value(n) = sum(permuted_diffs(:,n) >= observed_diff(n)) / n_permutations;
end

fprintf('P-value for each subject: %.4f\n');
p_value

