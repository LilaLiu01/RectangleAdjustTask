clc
clear all
close all
cd Sub12/Day5/

d = dir('Aspect*.mat');
figure;
tot = 1;
allmns = zeros(1,length(d));
alltyps = zeros(1,length(d));

for sess = 1:length(d)
    load(d(sess).name,'allMatches','nMatches');
    allLast = zeros(1,nMatches);
    for j = 1:nMatches
        allLast(j) = allMatches{j}(end);
    end
    if ~isempty(strfind(d(sess).name,'glasseson'))
        sym = 'r*';  %Glasses on
        alltyps(sess) = 1;
     elseif mod(sess,5) == 0
         alltyps(sess) = 2; %aftereffect
         sym = 'k*';
    else
        sym = 'ko';  %Off
    end
    plot(tot:(tot+nMatches-1),allLast,sym); hold on;
    plot([tot, (tot+nMatches-1)],[mean(allLast),mean(allLast)],'k-');
    tot = tot+nMatches;
    allmns(sess) = mean(allLast); %median(allLast);
    allsd(sess) = std(allLast);
end
  
xs = 1:length(allmns);
figure; plot(xs,allmns,'k-'); hold on
plot(xs(alltyps == 1),allmns(alltyps == 1),'r*');
plot(xs(alltyps == 0),allmns(alltyps == 0),'ko');
plot(xs(alltyps == 2),allmns(alltyps == 2),'k*');

cd ../
