close all; clear all;
Screen('Preference', 'SkipSyncTests', 1);
%If program crashes you will need to hit control-c and then type "sca" into
%command window...

%Set this to directory where code is and make a subdirectory named "data"
%in it
cd '~/Documents/MATLAB/VisionImageLab/NewGlasses'

subNum = input('Subject Code?>','s');

blockLen=180;  %How long each block is in seconds


firstGrayLen = 0.5;  %How long gray background oval is up before black/white test comes up
secondGrayLen = 0.25; %How long gray is up after black/white test goes away
testLen = .5;    %How long black/white test is up for
testGap = 2;  %1.5   %How long between flashes

grayEndTime = firstGrayLen;
circleEndTime = grayEndTime+testLen;
secondGrayEndTime = circleEndTime+secondGrayLen;
cycleEndTime = secondGrayEndTime+testGap;

cycles2ChangeColor = 3;

allSizes = 80:100;  %How big in pixels flashed ovals can be
locJitter = 200;    %How far around screen ovals can move randomly from trial to trial
frameWidth = 4;    %Thickness in pixels of test
bgOvalPad = 30;     %Extra space in gray oval around test

allAspects = 0.8:0.01:1.2;  %All possible aspect ratios used for adjustment
nAspects = length(allAspects);

gon = input('Glasses on?[y/n]','s');
gon = gon=='y';
rord = input('Ring (0), Disk (1), or Thick Ring (2)? >');

rect=Screen('Rect', 0);
[startx,starty] = RectCenter(rect);
SetMouse(startx,starty);
mouseRange = startx./2;

ListenChar(2);  %Make so keypresses go to psytoolbox and NOT matlab editor

winSize = [800,1280];  %Size of Konkle background set
winRect = SetRect(0,0,winSize(2),winSize(1));
winRect = CenterRectOnPoint(winRect,startx,starty);

theMatch = 1;

AssertOpenGL;
screens=Screen('Screens');
screenNumber=max(screens);

white=WhiteIndex(screenNumber);
black=BlackIndex(screenNumber);
gray=round((white+black)/2);
if gray == white
    gray=white / 2;
end
fudgemean = gray + 5;

[w,winRect] = Screen('OpenWindow',screenNumber, fudgemean, winRect);
ifi=Screen('GetFlipInterval', w);
[winCenterx,winCentery] = RectCenter(winRect);

%Get list of background images
d = dir('konklebgs/*.jpg');
nbgs = length(d);

%Variables to store results
allMatches = {};
allTimings = {};

%Get ready for loop where set matches
done = 0;
[curx,cury,but] = GetMouse;
HideCursor;
[ keyIsDown, seconds, keyCode ] = KbCheck(-1);

vbl = Screen('Flip', w);
blockStart = vbl;

%Loop for the block length or until escape is hit
while (vbl < (blockStart+blockLen)) && ~done
    %Setup variables for a new match to be set
    vbl = GetSecs;
    curAspect = randi(nAspects);  %Random initial aspect ratio
    aspectRatio = allAspects(curAspect);
    
    %Position mouse at correct location for that aspect ratio- a little
    %hacky
    tmp = 1-(nAspects-curAspect)./(nAspects-1); %0 to 1
    tmp = 2*tmp-1; %-1 to 1
    nux = startx+round(tmp*mouseRange);
    SetMouse(nux,starty);
    
    %Variables to keep track of settings
    allSettings = [curAspect];
    allTimes = [vbl];
    
    %random background image
    bgImg = imread(['konklebgs/',d(randi(nbgs)).name]);
    bgImg = double(rgb2gray(bgImg));
    %Normalize background so its mean is 128- so everything is same average
    %brightness
    mn = mean(mean(bgImg));
    cImg = (bgImg-mn)./mn;
    cImg(cImg>1) = 1; cImg(cImg<-1) = -1;
    bgImg = uint8(round(cImg*128+127));
    bgtex=Screen('MakeTexture', w, bgImg);
    
    cycleStart = GetSecs;
    matchSet = 0;  %Set to 1 once hit space bar or click mouse
    nucycle = 1;
    cyclenum = 0;
    %Loop until a match is set or escape is hit or block ends
    while ~matchSet && ~done && (vbl < (blockStart+blockLen))
        t = (GetSecs - cycleStart);
        if nucycle     %start new cycle- new random size and location
            szy = allSizes(randi(length(allSizes)));
            szx = round(szy*aspectRatio);
            locx = winCenterx+round(randi(locJitter)-locJitter./2);
            locy = winCentery+round(randi(locJitter)-locJitter./2);
            cyclenum = cyclenum+1;
            if mod(cyclenum,cycles2ChangeColor) == 1
                if rand > 0.5  %Random color each time
                    c1 = white; c2 = black;
                else
                    c1 = black; c2 = white;
                end
            end
            nucycle = 0;
        end
        Screen('DrawTexture', w, bgtex);
        aspectRatio = allAspects(curAspect);  %Compute rectangle size
        szx = round(szy*aspectRatio);
        theRect = SetRect(1,1, szx,szy);
        theRect = CenterRectOnPoint(theRect,locx,locy);
        if  (t < grayEndTime)
            Screen('FillOval',w, fudgemean, GrowRect(theRect,bgOvalPad,bgOvalPad));
        elseif (t < circleEndTime)
            Screen('FillOval',w, fudgemean, GrowRect(theRect,bgOvalPad,bgOvalPad));
            if rord == 0
                Screen('FrameOval',w, c1, theRect,frameWidth);
            elseif rord == 1
                Screen('FillOval',w, c1, theRect);
            elseif rord == 2
                Screen('FrameOval',w, c1, theRect,2*frameWidth);
            end
        elseif  (t < secondGrayEndTime)
            Screen('FillOval',w, fudgemean, GrowRect(theRect,bgOvalPad,bgOvalPad));
        elseif (t > cycleEndTime)
            nucycle = 1;
            cycleStart = cycleStart+cycleEndTime;
        end
        vbl = Screen('Flip', w, vbl);
        
        %Read mouse and adjust shape- a little hacky
        [curx,cury,but] = GetMouse;
        HideCursor;
        diffx = curx-startx;
        diffx = diffx./mouseRange;  %-1 to 1
        if diffx > 1, diffx = 1; end
        if diffx < -1, diffx = -1; end
        diffx = (diffx+1)/2;        %0 to 1
        nuAspect = round((nAspects-1)*diffx)+1;
        if nuAspect ~= curAspect
            curAspect = nuAspect;
            allSettings = [allSettings curAspect];
            allTimes = [allTimes GetSecs];
        end
        %Check for button press
        if sum(but) > 0
            matchSet = 1;
            while (sum(but) > 0)  %Wait until mouse button is raised
                [curx,cury,but] = GetMouse;
                HideCursor;
            end
        end
        
        %Check for key press & adjust
        [ keyIsDown, seconds, keyCode ] = KbCheck(-1);
        if keyIsDown
            if keyCode(KbName('LeftArrow'))  %Narrower
                curAspect = curAspect-1;
                if curAspect < 1, curAspect = 1; end
                allSettings = [allSettings curAspect];
                allTimes = [allTimes GetSecs];
                KbReleaseWait;
                ellipseDrawn = 0;
            elseif keyCode(KbName('RightArrow'))  %Wider
                curAspect = curAspect+1;
                if curAspect > nAspects, curAspect = nAspects; end
                allSettings = [allSettings curAspect];
                allTimes = [allTimes GetSecs];
                KbReleaseWait;
                ellipseDrawn = 0;
            elseif keyCode(KbName('SPACE')) %Got a match
                matchSet = 1;
                KbReleaseWait;
            elseif keyCode(KbName('ESCAPE'))  %Quit
                done = 1;
            end
            %Keep mouse updated so can use both
            tmp = 1-(nAspects-curAspect)./(nAspects-1); %0 to 1
            tmp = 2*tmp-1; %-1 to 1
            nux = startx+round(tmp*mouseRange);
            SetMouse(nux,starty);
            HideCursor;
        end
    end
    if matchSet  %Save responses in variable
        allTimes = [allTimes GetSecs];
        allMatches{theMatch} = allSettings;
        allTimings{theMatch} = allTimes;
        nMatches = theMatch;
        theMatch = theMatch+1;
        matchSet = 0;
        %Beeper;
    end
end
clear Screen
ListenChar(0);
ShowCursor;

%Save data in file name with time if made some matches (not if bailed
%before first match)
if ~isempty(allMatches)
    currT = datestr(now);
    currT = strrep(strrep(currT,' ','_'),':','-');
    fName = ['Aspect_', subNum,'_',currT];
    if gon
        fName = [fName,'glasseson'];
    end
    fName = [fName,'.mat'];
    cd data
    estr = ['save ',fName,...
        ' allMatches allTimings fudgemean firstGrayLen secondGrayLen testLen testGap '...
        ' nMatches cycles2ChangeColor '...
        'theMatch allSizes allAspects bgOvalPad '...
        'startx starty mouseRange gon blockLen locJitter frameWidth'];
    eval(estr);
    
    cd ..
    
    %Display settings on screen
    allLast = zeros(1,nMatches);
    allFirst = zeros(1,nMatches);
    for i = 1:nMatches
        allLast(i) = allMatches{i}(end);
        allFirst(i) = allMatches{i}(1);
    end
    allLast
end