% WhiteNoise_1D_FullFieldFlash.m
% 
% Work in progress!
%
% last update: 09.07.16

classdef WhiteNoise_1D_FullFieldFlash_testflip < Stimulus 
    properties 
        Out
        ParamList = {'EpochDuration', 'EpochContrast',...
            'RepeatRNGSeed'};
        EpochDuration
        EpochContrast
        RepeatRNGSeed
    end 
    methods
        % Constructor
        function obj = WhiteNoise_1D_FullFieldFlash_testflip(txtFile)
            obj@Stimulus(txtFile);
        end 
        
        % Displays the stimulus using the parameters specified in the
        % .txt file
        function displayStim(obj, window, ifi, stimDuration)
            % Method A:
            % for each frame or each flip
            %   if done with previous epoch, draw a random contrast value 
            %   display the full field contrast 
            %   update frame counter for current contrast (countdown)
            % Method B:
            % for total number of stimulus updates (contrast values), 
            %   draw a random contrast value
            %   display the contrast for the given duration 
            
            % Here, I've implemented Method A 
            
            % Fetch stimlus paramters
            contrast = cell2mat(obj.EpochContrast); % vector of contrast values
            duration = obj.EpochDuration{1}; % duration of 1 contrast value
%             duration = 0.333; % duration of 1 contrast value
            nValues = length(contrast);  % total number of contrast values
            pdContrast = 0; % photodiode contrast value 
            epochFrameCount = 0; % frame counter to track frames left in an epoch
            
            % user-estimated total stimulus length
            estFrames = ceil(stimDuration/ifi); 
            buffer = ceil(60/ifi); % 1 min buffer
            % number of frames stimulus will actually run for
            totalFrames = estFrames + buffer;
%           % vector to save actual stimulus played
            rawStim = zeros(totalFrames, 1); 
            pdOut = zeros(totalFrames, 1); 
%             nUpdates = ceil(stimDuration/duration); % length of contrast sequence 
           
            % Set random number generator 
            if obj.RepeatRNGSeed{1} == 1 % use same random sequence for every trial you run the stimulus
                rng('default');
            else 
                rng('shuffle'); % use a different random number sequence for each trial
            end 

            % Generate a sequence of random contrast values whose length is
            % determined by the total duration of the stimulus and the
            % update rate. We draw from a uniform distribution because we
            % have such few contrast values 
%             randseq = ceil(nValues*rand(nUpdates+1, 1)); 
%             i = 1;
        
%             currFrame = 1; % initialize frame counter 
            c = 0;
             
            missed = zeros(totalFrames, 1);
            flipstartTimes = zeros(totalFrames, 1);
            
            % --- Psychtoolbox code --- *
            startTime = Screen('Flip', window); 
            vbl = startTime;

            % MAIN LOOP over each stimulus frame
            % Keep playing the stimulus until the user presses a key on the keyboard
            for currFrame = 1:totalFrames % actually the number of flips
                c = double(~c);
                % contrasts are corrected for 6-bit RGB 
                Screen('FillRect', window, c*obj.RGBscale, obj.screenDim); 
                % Draw onto the photodiode
                Screen('FillRect', window, c*obj.RGBscale, obj.pdDim);
                
                % Flip window at the frame rate
%                 [VBLTimestamp StimulusOnsetTime FlipTimestamp Missed Beampos] = 
                [vbl, sot, flp, missed, beampos] = Screen('Flip', window, startTime + (currFrame-0.5)*duration);  
%                 [vbl, sot, flp, missed, beampos] = Screen('Flip', window, vbl + duration+0.001); 
                pause(0)
                
                rawStim(currFrame) = c;
                missed(currFrame) = missed;
                flipstartTimes(currFrame) = vbl;
                
                % If user hits keyboard, exit the stimulus loop 
                if KbCheck
                    break;
                end    
               
%                 currFrame = currFrame + 1; % update frame counter
            end
            
            Screen('CloseAll');
            
            % Save metadata specific to this class
            r = rng;
            obj.Out.rndSeed = r.Seed; % seed for random number generator  
            obj.Out.rawStim = rawStim(1:currFrame); % save stimulus contrast values to Out     
            obj.Out.pdOut = pdOut(1:currFrame); % Test code
            obj.Out.missed = missed(1:currFrame);
            obj.Out.flipStart = flipstartTimes(1:currFrame);
        end 
        
    end 
end 
