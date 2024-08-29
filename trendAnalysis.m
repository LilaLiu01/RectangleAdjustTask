%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   trendAnalysis.m Dec 02, 2023
%   Sean Liu
%   Tbc...

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

%% Linear regression models
clear
load('ratioAll_onoff.mat');
rawAdj = 100*(0.005*rawAdj + 0.795); % convert to aspect ratio
firstSet = 100*(0.005*firstSet + 0.795);
firSubblk = 100*(0.005*firSubblk + 0.795);

TestNum = 50;
SubNum = 12;
SessionNum = 10;
TestperSession = TestNum/SessionNum; % 5
BaselineIdx = 1:TestperSession:TestNum;
FirstOnIdx = 2:TestperSession:TestNum;
OneHourOnIdx = 3:TestperSession:TestNum;
TwoHourOnIdx = 4:TestperSession:TestNum;
LastOnIdx = 4:TestperSession:TestNum;
AfterIdx = 5:TestperSession:TestNum;
grandmn = mean(rawAdj(1:SubNum,1:TestNum),1,'omitnan');
firSetmn = mean(firstSet(1:SubNum,1:TestNum),1,'omitnan');
firSubblkmn = mean(firSubblk(1:SubNum,1:TestNum),1,'omitnan');
Xall = 1:SessionNum;
xcoordi = 0:SessionNum+1;

%% Inividual slopes of rapid adjustment - t test:
% incorporate all samples in total:
figure;
nFigrow = ceil(SubNum/3);

for i = 1:SubNum
    data1(i,:) = rawAdj(i,FirstOnIdx) - rawAdj(i,BaselineIdx);
    beta1(i,:) = polyfit(Xall, data1(i,:),1);

    data2(i,:) = firstSet(i,FirstOnIdx) - firstSet(i,BaselineIdx);
    beta2(i,:) = polyfit(Xall, data2(i,:),1);

    data3(i,:) = firSubblk(i,FirstOnIdx) - firSubblk(i,BaselineIdx);
    beta3(i,:) = polyfit(Xall, data3(i,:),1);

    data4(i,:) = rawAdj(i,AfterIdx) - rawAdj(i,BaselineIdx);
    beta4(i,:) = polyfit(Xall, data4(i,:),1);

    data5(i,:) = rawAdj(i,AfterIdx);
    beta5(i,:) = polyfit(Xall, data5(i,:),1);


    subplot(nFigrow,3,i);
    plot(Xall, data1(i,:), 'ko', 'MarkerSize',5);
    hold on
    plot(Xall, polyval(beta1(i,:),Xall), '--r', 'LineWidth',1.5);
    ylim([-1,5]);
    text(0.9, 0.9, ['r = ' num2str(beta1(i,1))], 'Units', 'normalized', 'HorizontalAlignment', 'right', 'VerticalAlignment', 'top');
    title(['Sub' num2str(i)]);
end


fprintf('On Session: \n For all trials:\n');
[H,P,CI,STATS] = ttest(beta1(:,1))

fprintf('For first settings:\n');
[H,P,CI,STATS] = ttest(beta2(:,1))

fprintf('For first sub-blocks:\n');
[H,P,CI,STATS] = ttest(beta3(:,1))

fprintf('Off Session:\n');
[H,P,CI,STATS] = ttest(beta4(:,1))

fprintf('Uncorrected aftereffect:\n');
[H,P,CI,STATS] = ttest(beta5(:,1))

%% Group level slope

% All trials
% rapid adjustment
fprintf('For all trials:\n');
figure;
FirstmeanFit = fitlm(Xall,grandmn(FirstOnIdx)-grandmn(BaselineIdx)); %fit for first glasses-on block
disp(['Equation is: y_firstOn = ' num2str(FirstmeanFit.Coefficients.Estimate(2)) '*x + ' num2str(FirstmeanFit.Coefficients.Estimate(1))]);
fprintf('95%% Confidence Interval for slope:\n');
arr = FirstmeanFit.coefCI;
disp([arr(1,:)]);
disp(['t = ' num2str(FirstmeanFit.Coefficients.tStat(2))]);
disp(['p = ' num2str(FirstmeanFit.Coefficients.pValue(2))]);
disp(['R-squared = ' num2str(FirstmeanFit.Rsquared.Ordinary)]);
disp(['F = ' num2str(anova(FirstmeanFit).F(1))]);
y1 = FirstmeanFit.Coefficients.Estimate(2)*xcoordi + FirstmeanFit.Coefficients.Estimate(1);
plot(xcoordi,y1+100,'--','color','black','LineWidth',2.5);
hold on

% total adaptation
LastmeanFit = fitlm(Xall,grandmn(LastOnIdx)-grandmn(BaselineIdx)); %fit for last glasses-on block
disp(['Equation is: y_lastOn = ' num2str(LastmeanFit.Coefficients.Estimate(2)) '*x + ' num2str(LastmeanFit.Coefficients.Estimate(1))]);
fprintf('95%% Confidence Interval for slope:\n');
arr = LastmeanFit.coefCI;
disp([arr(1,:)]);
disp(['t = ' num2str(LastmeanFit.Coefficients.tStat(2))]);
disp(['p = ' num2str(LastmeanFit.Coefficients.pValue(2))]);
disp(['R-squared = ' num2str(LastmeanFit.Rsquared.Ordinary)]);
disp(['F = ' num2str(anova(LastmeanFit).F(1))]);
y2 = LastmeanFit.Coefficients.Estimate(2)*xcoordi + LastmeanFit.Coefficients.Estimate(1);
plot(xcoordi,y2+100,'--','color','black','LineWidth',2.5);

% aftereffect
FirstoffmeanFit = fitlm(Xall,grandmn(AfterIdx)-grandmn(BaselineIdx)); %fit the line for first glass off
disp(['Equation is: y_aftermean = ' num2str(FirstoffmeanFit.Coefficients.Estimate(2)) '*x + ' num2str(FirstoffmeanFit.Coefficients.Estimate(1))]);
fprintf('95%% Confidence Interval for slope:\n');
arr = FirstoffmeanFit.coefCI;
disp([arr(1,:)]);
disp(['t = ' num2str(FirstoffmeanFit.Coefficients.tStat(2))]);
disp(['p = ' num2str(FirstoffmeanFit.Coefficients.pValue(2))]);
disp(['R-squared = ' num2str(FirstoffmeanFit.Rsquared.Ordinary)]);
disp(['F = ' num2str(anova(FirstoffmeanFit).F(1))]);
y3 = FirstoffmeanFit.Coefficients.Estimate(2)*xcoordi + FirstoffmeanFit.Coefficients.Estimate(1);
plot(xcoordi,y3+100,'--','color','black','LineWidth',2.5);

% Not corrected now
line1 = plot(Xall,grandmn(FirstOnIdx)-grandmn(BaselineIdx)+100,'.','MarkerSize',30,'color',[0 0.4470 0.7410],'LineWidth',2.5);
lgd = line1;
hold on
line2 = plot(Xall,grandmn(LastOnIdx)-grandmn(BaselineIdx)+100,'.','MarkerSize',30,'color',[0 0.4470 0.7410]*0.5,'LineWidth',2.5);
lgd = [lgd, line2];
hold on
line3 = plot(Xall,grandmn(AfterIdx)-grandmn(BaselineIdx)+100,'.','MarkerSize',30,'color',[0.4660 0.6740 0.1880],'LineWidth',2.5);
lgd = [lgd, line3];

% ylabel('Corrected Aspect Ratio(%)');
ylabel('Magnification (%)');
xlabel('Day');
xlim([0.8,10.2])
% ylim([-2.3 4]);
ylim([97.7 104]);
xticklabels({'1','2','3','4','5'});
xticks([1 3 5 7 9]);
set(gca,'FontSize',25);
% labels = {'Rapid Adjust', 'Total Adapt', 'Aftereffect'};
labels = {'First Block', 'Last Block', 'Aftereffect'};
legend_obj = legend(lgd, labels, 'Location', 'best');
set(legend_obj, 'FontSize', 15);

% baseline
BaselineFit = fitlm(Xall,grandmn(BaselineIdx)); %fit for first glasses-on block
disp(['Equation is: y_baseline = ' num2str(BaselineFit.Coefficients.Estimate(2)) '*x + ' num2str(BaselineFit.Coefficients.Estimate(1))]);
fprintf('95%% Confidence Interval for slope:\n');
arr = BaselineFit.coefCI;
disp([arr(1,:)]);
disp(['t = ' num2str(BaselineFit.Coefficients.tStat(2))]);
disp(['p = ' num2str(BaselineFit.Coefficients.pValue(2))]);
disp(['R-squared = ' num2str(BaselineFit.Rsquared.Ordinary)]);
disp(['F = ' num2str(anova(BaselineFit).F(1))]);
y4 = BaselineFit.Coefficients.Estimate(2)*xcoordi + BaselineFit.Coefficients.Estimate(1);


% First setting
fprintf('For first settings:\n');
% rapid adjustment
FirstmeanFit = fitlm(Xall,firSetmn(FirstOnIdx)-firSetmn(BaselineIdx)); %fit for first glasses-on block
disp(['Equation is: y_firstOn = ' num2str(FirstmeanFit.Coefficients.Estimate(2)) '*x + ' num2str(FirstmeanFit.Coefficients.Estimate(1))]);
fprintf('95%% Confidence Interval for slope:\n');
arr = FirstmeanFit.coefCI;
disp([arr(1,:)]);
disp(['t = ' num2str(FirstmeanFit.Coefficients.tStat(2))]);
disp(['p = ' num2str(FirstmeanFit.Coefficients.pValue(2))]);
disp(['R-squared = ' num2str(FirstmeanFit.Rsquared.Ordinary)]);
disp(['F = ' num2str(anova(FirstmeanFit).F(1))]);
y1 = FirstmeanFit.Coefficients.Estimate(2)*xcoordi + FirstmeanFit.Coefficients.Estimate(1);

% total adaptation
LastmeanFit = fitlm(Xall,firSetmn(LastOnIdx)-firSetmn(BaselineIdx)); %fit for last glasses-on block
disp(['Equation is: y_lastOn = ' num2str(LastmeanFit.Coefficients.Estimate(2)) '*x + ' num2str(LastmeanFit.Coefficients.Estimate(1))]);
fprintf('95%% Confidence Interval for slope:\n');
arr = LastmeanFit.coefCI;
disp([arr(1,:)]);
disp(['t = ' num2str(LastmeanFit.Coefficients.tStat(2))]);
disp(['p = ' num2str(LastmeanFit.Coefficients.pValue(2))]);
disp(['R-squared = ' num2str(LastmeanFit.Rsquared.Ordinary)]);
disp(['F = ' num2str(anova(LastmeanFit).F(1))]);
y2 = LastmeanFit.Coefficients.Estimate(2)*xcoordi + LastmeanFit.Coefficients.Estimate(1);

% aftereffect
FirstoffmeanFit = fitlm(Xall,firSetmn(AfterIdx)-firSetmn(BaselineIdx)); %fit the line for first glass off
disp(['Equation is: y_aftermean = ' num2str(FirstoffmeanFit.Coefficients.Estimate(2)) '*x + ' num2str(FirstoffmeanFit.Coefficients.Estimate(1))]);
fprintf('95%% Confidence Interval for slope:\n');
arr = FirstoffmeanFit.coefCI;
disp([arr(1,:)]);
disp(['t = ' num2str(FirstoffmeanFit.Coefficients.tStat(2))]);
disp(['p = ' num2str(FirstoffmeanFit.Coefficients.pValue(2))]);
disp(['R-squared = ' num2str(FirstoffmeanFit.Rsquared.Ordinary)]);
disp(['F = ' num2str(anova(FirstoffmeanFit).F(1))]);
y3 = FirstoffmeanFit.Coefficients.Estimate(2)*xcoordi + FirstoffmeanFit.Coefficients.Estimate(1);


% First sub-block (90s)
% rapid adjustment
fprintf('For first sub-blocks:\n');
FirstmeanFit = fitlm(Xall,firSubblk(FirstOnIdx)-firSubblk(BaselineIdx)); %fit for first glasses-on block
disp(['Equation is: y_firstOn = ' num2str(FirstmeanFit.Coefficients.Estimate(2)) '*x + ' num2str(FirstmeanFit.Coefficients.Estimate(1))]);
fprintf('95%% Confidence Interval for slope:\n');
arr = FirstmeanFit.coefCI;
disp([arr(1,:)]);
disp(['t = ' num2str(FirstmeanFit.Coefficients.tStat(2))]);
disp(['p = ' num2str(FirstmeanFit.Coefficients.pValue(2))]);
disp(['R-squared = ' num2str(FirstmeanFit.Rsquared.Ordinary)]);
disp(['F = ' num2str(anova(FirstmeanFit).F(1))]);
y1 = FirstmeanFit.Coefficients.Estimate(2)*xcoordi + FirstmeanFit.Coefficients.Estimate(1);

% total adaptation
LastmeanFit = fitlm(Xall,firSubblk(LastOnIdx)-firSubblk(BaselineIdx)); %fit for last glasses-on block
disp(['Equation is: y_lastOn = ' num2str(LastmeanFit.Coefficients.Estimate(2)) '*x + ' num2str(LastmeanFit.Coefficients.Estimate(1))]);
fprintf('95%% Confidence Interval for slope:\n');
arr = LastmeanFit.coefCI;
disp([arr(1,:)]);
disp(['t = ' num2str(LastmeanFit.Coefficients.tStat(2))]);
disp(['p = ' num2str(LastmeanFit.Coefficients.pValue(2))]);
disp(['R-squared = ' num2str(LastmeanFit.Rsquared.Ordinary)]);
disp(['F = ' num2str(anova(LastmeanFit).F(1))]);
y2 = LastmeanFit.Coefficients.Estimate(2)*xcoordi + LastmeanFit.Coefficients.Estimate(1);

% aftereffect
FirstoffmeanFit = fitlm(Xall,firSubblk(AfterIdx)-firSubblk(BaselineIdx)); %fit the line for first glass off
disp(['Equation is: y_aftermean = ' num2str(FirstoffmeanFit.Coefficients.Estimate(2)) '*x + ' num2str(FirstoffmeanFit.Coefficients.Estimate(1))]);
fprintf('95%% Confidence Interval for slope:\n');
arr = FirstoffmeanFit.coefCI;
disp([arr(1,:)]);
disp(['t = ' num2str(FirstoffmeanFit.Coefficients.tStat(2))]);
disp(['p = ' num2str(FirstoffmeanFit.Coefficients.pValue(2))]);
disp(['R-squared = ' num2str(FirstoffmeanFit.Rsquared.Ordinary)]);
disp(['F = ' num2str(anova(FirstoffmeanFit).F(1))]);
y3 = FirstoffmeanFit.Coefficients.Estimate(2)*xcoordi + FirstoffmeanFit.Coefficients.Estimate(1);


%% Gradual Adaptation Within Days
for i = 1:SubNum
    data_grad1(i,:) = rawAdj(i,OneHourOnIdx) - rawAdj(i,FirstOnIdx);
    beta_grad1(i,:) = polyfit(Xall, data_grad1(i,:),1);

    data_grad2(i,:) = firstSet(i,TwoHourOnIdx) - firstSet(i,FirstOnIdx);
    beta_grad2(i,:) = polyfit(Xall, data_grad2(i,:),1);

    % Baseline
    data_base(i,:) = rawAdj(i,BaselineIdx);
    beta_base(i,:) = polyfit(Xall, data_base(i,:),1);
end


fprintf('Adaptation within 1 hr:\n');
[H,P,CI,STATS] = ttest(beta_grad1(:,1))

fprintf('Adaptation within 2 hr:\n');
[H,P,CI,STATS] = ttest(beta_grad2(:,1))

fprintf('Baseline trend:\n');
[H,P,CI,STATS] = ttest(beta_base(:,1))


% Individual base line trend across days
for i = 1:SubNum
    disp(['Subject' num2str(i)]);
    BaselineFit = fitlm(Xall,data_base(i,:));
    disp(['Equation is: y_baseline = ' num2str(BaselineFit.Coefficients.Estimate(2)) '*x + ' num2str(BaselineFit.Coefficients.Estimate(1))]);
    fprintf('95%% Confidence Interval for slope:\n');
    arr = BaselineFit.coefCI;
    disp([arr(1,:)]);
    disp(['t = ' num2str(BaselineFit.Coefficients.tStat(2))]);
    disp(['p = ' num2str(BaselineFit.Coefficients.pValue(2))]);
    disp(['R-squared = ' num2str(BaselineFit.Rsquared.Ordinary)]);
    disp(['F = ' num2str(anova(BaselineFit).F(1))]);

end


