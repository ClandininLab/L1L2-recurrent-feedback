% Clear the workspace and the screen
clear all
Screen('CloseAll');
close all;
clearvars;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer.
% For help see: Screen Screens?
screens = Screen('Screens');

% limits sync tests to critical ones
Screen('Preference', 'SkipSyncTests', 1);

% suppress printout of all warnings
Screen('Preference', 'SuppressAllWarnings',1);

Screen('Preference', 'VBLTimestampingMode', -1);

% makes initial screen black
Screen('Preference', 'VisualDebugLevel',1);

% Draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external
% screen. When only one screen is attached to the monitor we will draw to
% this.
% For help see: help max
screenNumber = max(screens);
% screenNumber = 1;

% rescale to match LightCrafter

% Define black (white will be 1 and black 0). This is because
% luminace values are (in general) defined between 0 and 1.
% For help see: help BlackIndex
black = BlackIndex(screenNumber);

% Open an on screen window and color it black
% For help see: Screen OpenWindow?
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Get the size of the on screen window in pixels
% For help see: Screen WindowSize?
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window in pixels
% For help see: help RectCenter
[xCenter, yCenter] = RectCenter(windowRect);


% Make a base Rect of 200 by 200 pixels. This is the rect which defines the
% size of our square in pixels. Rects are rectangles, so the
% sides do not have to be the same length. The coordinates define the top
% left and bottom right coordinates of our rect [top-left-x top-left-y
% bottom-right-x bottom-right-y]. The easiest thing to do is set the first
% two coordinates to 0, then the last two numbers define the length of the
% rect in X and Y. The next line of code then centers the rect on a
% particular location of the screen.
baseRect = [0 0 100 200];

% Center the rectangle on the centre of the screen using fractional pixel
% values.
% For help see: CenterRectOnPointd
centeredRect = CenterRectOnPointd(baseRect, xCenter, yCenter);
centeredRect2 = CenterRectOnPointd(baseRect, xCenter + 150, yCenter);

% Set the color of our square to full red. Color is defined by red green
% and blue components (RGB). So we have three numbers which
% define our RGB values. The maximum number for each is 1 and the minimum
% 0. So, "full red" is [1 0 0]. "Full green" [0 1 0] and "full blue" [0 0
% 1]. Play around with these numbers and see the result.
fullVal = 1;
grVal = fullVal * (63/255);
rectColor = [0 1 0];
rectColor2 = [0.5 0 0.5];


% Draw the square to the screen. For information on the command used in
% this line see Screen FillRect?
Screen('FillRect', window, rectColor, centeredRect);
Screen('FillRect', window, rectColor2, centeredRect2);

% Flip to the screen. This command basically draws all of our previous
% commands onto the screen. See later demos in the animation section on more
% timing details. And how to demos in this section on how to draw multiple
% rects at once.
% For help see: Screen Flip?
Screen('Flip', window);

% Now we have drawn to the screen we wait for a keyboard button press (any
% key) to terminate the demo.
% For help see: help KbStrokeWait
KbStrokeWait;

% Clear the screen. "sca" is short hand for "Screen CloseAll". This clears
% all features related to PTB. Note: we leave the variables in the
% workspace so you can have a look at them if you want.
% For help see: help sca
Screen('CloseAll');

