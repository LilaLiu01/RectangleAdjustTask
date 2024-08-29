close all; clear all;

%If program crashes you will need to hit control-c and then type "sca" into
%command window...

%Set this to directory where code is and make a subdirectory named "data"
%in it
cd '~/Documents/MATLAB/VisionImageLab/NewGlasses'

subNum = input('Subject Code?>','s');

blockLen = 270;  %How long each block is in seconds


firstGrayLen = 0.5;  %How long gray background oval is up before black/white test comes up
secondGrayLen = 0.25; %How long gray is up after black/white test goes away
testLen = .5;    %How long black/white test is up for
testGap = 2;  %1.5   %How long between flashes

grayEndTime = firstGrayLen;
circleEndTime = grayEndTime+testLen;
secondGrayEndTime = circleEndTime+secondGrayLen;
cycleEndTime = secondGrayEndTime+testGap;

cycles2ChangeColor = 3;

testSize = 150;
bigSize = 450;
sup = 100; %size blurred border region
allSkews = 0.8:0.005:1.2;  %All possible aspect ratios used for adjustment
nSkews = length(allSkews);
locJitter = 200;    %How far around screen ovals can move randomly from trial to trial

gon = input('Glasses on?[y/n]','s');
gon = gon=='y';

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
mygray=round((white+black)/2);
if mygray == white
    mygray=white / 2;
end
fudgemean = mygray + 5;

white = [white white white 255];
black = [black black black 255];

[w,winRect] = Screen('OpenWindow',screenNumber, fudgemean, winRect);
ifi=Screen('GetFlipInterval', w);
[winCenterx,winCentery] = RectCenter(winRect);
[offw,winRect] = Screen('OpenOffscreenWindow',screenNumber, fudgemean, winRect);
Screen('BlendFunction', offw, GL_ONE, GL_ZERO);  %THis is default bu just to be sure

testRect = SetRect(1,1, testSize,testSize);

%Get list of background images
d = dir('konklebgs/*.jpg');
nbgs = length(d);

%Make gray circle alpha weighted with a gaussian on which to present test
bigRect = SetRect(1,1, bigSize,bigSize);
kernel = mkGaussKernel([bigSize bigSize],[bigSize/2 bigSize/2]);
kernel = kernel./max(max(kernel));
grayGaussImg = fudgemean*ones(bigSize,bigSize);
grayGaussImg(:,:,2) = makeBlurredCircularPatch(bigSize-sup*2,sup,256);
grayGaussTex=Screen('MakeTexture', w, grayGaussImg);

%Variables to store results
allMatches = {};
allTimings = {};

%Get ready for loop where set matches
done = 0;
[curx,cury,but] = GetMouse;
HideCursor;
[ keyIsDown, seconds, keyCode ] = KbCheck(-1);

% Subtract 
vbl = Screen('Flip', w);
blockStart = vbl;

%      testImg = makeMultiSinPatch(sinpat,contrast,ncolors);
%      testImg(:,:,2) = 255;  %alpha layer

testImg = imread('SquareCrossTest.png');
testImg = imresize(testImg, testSize/size(testImg,1));
testImg = uint8(rgb2gray(testImg));
testImg(:,:,2) = 255;  %alpha layer

%Loop for the block length or until escape is hit
while (vbl < (blockStart+blockLen)) && ~done
    %Setup variables for a new match to be set
    vbl = GetSecs;
    curSkewNum = randi(nSkews);  %Random initial aspect ratio
    theSkew = allSkews(curSkewNum);
    
    %Position mouse at correct location for that aspect ratio- a little
    %hacky
    tmp = 1-(nSkews-curSkewNum)./(nSkews-1); %0 to 1
    tmp = 2*tmp-1; %-1 to 1
    nux = startx+round(tmp*mouseRange);
    SetMouse(nux,starty);
    
    %Variables to keep track of settings
    allSettings = [curSkewNum];
    allTimes = [vbl];
    
    %random background image
    bgnum = randi(nbgs);
    bgImg = readBG(bgnum,d);
    
    bgImg(:,:,2) = 0;  %alpha layer
    
    bgtex=Screen('MakeTexture', w, bgImg);
    
    %test is a different random background image
    %      posstests = Shuffle(setdiff(1:nbgs,bgnum));
    %      testnum = posstests(1);  %Shuffle puts random one in first place
    %      testImg = readBG(testnum,d);
    
    
    cycleStart = GetSecs;
    matchSet = 0;  %Set to 1 once hit space bar or click mouse
    nucycle = 1;
    cyclenum = 0;
    %Loop until a match is set or escape is hit or block ends
    while ~matchSet && ~done && (vbl < (blockStart+blockLen))
        t = (GetSecs - cycleStart);
        if nucycle     %start new cycle- new random size and location
            locx = winCenterx+round(randi(locJitter)-locJitter./2);
            locy = winCentery+round(randi(locJitter)-locJitter./2);
            srcRect = testRect;
            dstRect = CenterRectOnPoint(srcRect,locx,locy);
            bigdstRect = CenterRectOnPoint(bigRect,locx,locy);
            
            cyclenum = cyclenum+1;
            nucycle = 0;
        end
        
        %Draw background
        Screen('BlendFunction', w, GL_ONE, GL_ZERO);
        Screen('DrawTexture', w, bgtex);
        theSkew = allSkews(curSkewNum);
        
        %Test image
        skImg = skewIm(testImg,theSkew);
        texRect = SetRect(1,1,size(skImg,2),size(skImg,1));
        tmpRect = CenterRect(testRect,texRect);
        skImg = skImg(tmpRect(RectTop):tmpRect(RectBottom),tmpRect(RectLeft):tmpRect(RectRight));
        kernel = mkGaussKernel([testSize testSize],[testSize/6 testSize/6]);
        kernel = kernel./max(max(kernel));
        skImg(:,:,2) = floor(255*kernel);
        testtex=Screen('MakeTexture', w, skImg);
        
        %Leave image alone except where the offscreen window being copied
        %in has alpha value of 1; so this masks out the rest of the
        %rectangle being copied since offscree is initialized to alpha 0
        Screen('BlendFunction', w, GL_SRC_ALPHA,GL_ONE_MINUS_SRC_ALPHA);
        
        if  (t < grayEndTime)
            Screen('DrawTexture', w, grayGaussTex,bigRect,bigdstRect);
        elseif (t < circleEndTime)
            Screen('DrawTexture', w, grayGaussTex,bigRect,bigdstRect);
            Screen('DrawTexture', w, testtex,srcRect,dstRect);
            Screen('BlendFunction', w, GL_ONE, GL_ZERO);
        elseif  (t < secondGrayEndTime)
            Screen('DrawTexture', w, grayGaussTex,bigRect,bigdstRect);
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
        nuSkew = round((nSkews-1)*diffx)+1;
        if nuSkew ~= curSkewNum
            curSkewNum = nuSkew;
            allSettings = [allSettings curSkewNum];
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
                curSkewNum = curSkewNum-1;
                if curSkewNum < 1, curSkewNum = 1; end
                allSettings = [allSettings curSkewNum];
                allTimes = [allTimes GetSecs];
                KbReleaseWait;
                ellipseDrawn = 0;
            elseif keyCode(KbName('RightArrow'))  %Wider
                curSkewNum = curSkewNum+1;
                if curSkewNum > nSkews, curSkewNum = nSkews; end
                allSettings = [allSettings curSkewNum];
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
            tmp = 1-(nSkews-curSkewNum)./(nSkews-1); %0 to 1
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
        % Beeper;
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
    fName = ['AspectRect_', subNum,'_',currT];

    if gon
        fName = [fName,'glasseson'];
    end
    
    
    fName = [fName,'.mat'];
    cd ExpData/Sub12/Day5
    estr = ['save ',fName,...
        ' allMatches allTimings fudgemean firstGrayLen secondGrayLen testLen testGap '...
        ' nMatches cycles2ChangeColor '...
        'theMatch allSkews testSize bigSize sup locJitter '...
        'startx starty mouseRange gon blockLen '... 
        'blockStart'];
    % estr = ['save ',fName];
    eval(estr);
    
    cd ..
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