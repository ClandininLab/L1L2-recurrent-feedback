% filterROIs_stimLockedPlots_FFFBC_pool.m 
%
% Function to obtain stimulus-locked average responses and error per ROI
%  for presentations of binary contrast full field flash stimuli. Uses full 
%  contrast flash stimulus (search stimulus or full field) as way of 
%  identifying responding cells 
% Pools FFF responses across multiple trials
% Asks for user to identify responding/inverted/non-responding ROIs with
%  Y/I/N
%
% INPUT:
%   roiMat - 2D matrix of structs for each ROI, output of loadROIData
%   refColumn - which column of roiMat contains reference stimulus time
%       series (binary contrast or search stimulus)
%   pairedEpochs - 2D matrix indicating which epochs of flash off gray
%       stimulus are paired with each other (e.g. light and dark of same 
%       flash duration)
%   FRAME_RATE - frame rate to bin average responses at, in Hz
%   inv - 1 if responses are inverted (i.e. your indictor is ASAP), else 0
%   yScale - upper and lower limits of y axis for plots
%   binWidthMult - how many bins (at FRAME_RATE) to perform sliding average
%
% OUTPUT:
%   roiMatNew - first 2 columns of roiMat input with additional fields 
%       rats and stdErr(s)
%   iResp - indicies into roiMat of responding ROIs
%   iInv - indicies into roiMat of ROIs responding with opposite sign
%   framesPerLDCycle - number of frames in light flash + dark flash, for
%       reference stimulus
%
% CREATED: 4/14/22 - HHY
%
% UPDATED:
%

function [roiMatNew, iResp, iInv, framesPerLDCycle] = ...
    filterROIs_stimLockedPlots_FFFBC_pool(roiMat, refColumn, ...
    FRAME_RATE, inv, yScale, binWidthMult)
    
    % initialization
    BIN_WIDTH = binWidthMult * (1/FRAME_RATE);
    BIN_SHIFT = 1/FRAME_RATE;
    P_VAL_THRESH = 0.01; % emperically, based on tests on fake data
    iResp = [];
    iInv = [];
    
    % timing for reference stimulus
%     refEpochDur = roiMat(1,1).stimDat.obj.Duration{1}*2;
    % change how stimDat is dealt with after loadROIData change
    refEpochDur = roiMat(1,refColumn).stimDat.Duration{1}*2;
    
    cm = colormap('lines');
    close all
    
    % for placing stimulus patch appropriately with inverted or not
    if (inv)
    	patchY = yScale(1);
    else
        patchY = yScale(2);
    end

    roiMatNew = roiMat(:,1:2);
    
    % loop over all cells
    for r = 1:size(roiMat, 1)
        % get response to reference stim

        % compute mean response, std err, indicies of
        %  significantly different regions of trace
        [refMeanResp, refStdErr, ~, ~, ~, ~, ~, framesPerLDCycle] = ...
        compute_meanResp_err_moveAvg_FFFBC(roiMat(r,refColumn), refEpochDur,...
        BIN_SHIFT, BIN_WIDTH, FRAME_RATE, P_VAL_THRESH);
    
        % first column for ref stim
        roiMatNew(r,1).rats = refMeanResp;
        roiMatNew(r,1).stdErr = refStdErr;
        roiMatNew(r,1).framesPerLDCycle = framesPerLDCycle;
        roiMatNew(r,1).BIN_SHIFT = BIN_SHIFT;

        % get number of columns
        numCols = size(roiMat,2);
        % get all non-refColumn columns, indices
        nonRefCols = 1:numCols;
        nonRefCols(nonRefCols == refColumn) = [];

        % epoch duration (light + dark flash)
        epochDur = roiMat(r,nonRefCols(1)).stimDat.Duration{1}*2;

        % compute mean and error
        [meanResp, stdErr, ~, ~, ~, ~, ~, framesPerLDCycleNonRef] = ...
            compute_meanResp_err_moveAvg_FFFBC_pool(roiMat(r,nonRefCols), ...
            epochDur, BIN_SHIFT, BIN_WIDTH, FRAME_RATE, P_VAL_THRESH);
        
        % save info, 2nd column for fff, non-ref resp
        roiMatNew(r,2).rats = meanResp;
        roiMatNew(r,2).stdErrs = stdErr;
        roiMatNew(r,2).framesPerLDCycle = framesPerLDCycleNonRef;
        roiMatNew(r,2).BIN_SHIFT = BIN_SHIFT;
%                     in(r,s).sigPInd = sigPInd;

        % ask if reference stimulus is responding/not/inverted (but display
        % others)
        
        % display
        figure;

        % -----  plot reference stimulus ---- %
        subplot(size(roiMatNew,2),1,1);
        title(sprintf('Cell %d',r));
        xScale = [0, refEpochDur * 2];
        plot_err_patch_v2((0:length(refMeanResp)*2)*BIN_SHIFT,...
            [refMeanResp; refMeanResp; refMeanResp(1)], ...
            [refStdErr; refStdErr; refStdErr(1)], [0 0 1],[0.5 0.5 1]);
        xlabel('time (sec)');
        ylabel('response (dF/F)');
%         yScale = ylim;
        xlim(xScale);
        line([0 refEpochDur*2],[0 0],'color',[0 0 0]);
        for k = 1:4
            line([(k-1)*refEpochDur/2 (k-1)*refEpochDur/2],yScale,...
                'color',[0 0 0],'linestyle','--');
        end
        % light/dark epoch labels
        patch([0 0 refEpochDur/2 refEpochDur/2],...
            [(patchY*0.85) (patchY*0.9) (patchY*0.9) (patchY*0.85)],...
            [0 0 0]);
        patch([refEpochDur/2 refEpochDur/2 refEpochDur refEpochDur],...
            [(patchY*0.85) (patchY*0.9) (patchY*0.9) (patchY*0.85)]...
            ,[1 1 1]);
        patch([refEpochDur refEpochDur refEpochDur/2*3 refEpochDur/2*3],...
            [(patchY*0.85) (patchY*0.9) (patchY*0.9) (patchY*0.85)],...
            [0 0 0]);
        patch([refEpochDur/2*3 refEpochDur/2*3 refEpochDur*2 refEpochDur*2],...
            [(patchY*0.85) (patchY*0.9) (patchY*0.9) (patchY*0.85)]...
            ,[1 1 1]);

        set(gca,'xTick',0:(refEpochDur/2):(refEpochDur*2));
        
        if (inv) % reverse axes on inverted
            set(gca,'YDir','reverse');
        end
        
        
        % ----- plot non-ref fff ---- % 
        subplot(size(roiMatNew,2),1,2);
        title(sprintf('Cell %d',r));
        xScale = [0, epochDur * 2];
        plot_err_patch_v2((0:length(meanResp)*2)*BIN_SHIFT,...
            [meanResp; meanResp; meanResp(1)], ...
            [stdErr; stdErr; stdErr(1)], [0 0 1],[0.5 0.5 1]);
        xlabel('time (sec)');
        ylabel('response (dF/F)');
%         yScale = ylim;
        xlim(xScale);
        line([0 epochDur*2],[0 0],'color',[0 0 0]);
        for k = 1:4
            line([(k-1)*epochDur/2 (k-1)*epochDur/2],yScale,...
                'color',[0 0 0],'linestyle','--');
        end
        % light/dark epoch labels
        patch([0 0 epochDur/2 epochDur/2],...
            [(patchY*0.85) (patchY*0.9) (patchY*0.9) (patchY*0.85)],...
            [0 0 0]);
        patch([epochDur/2 epochDur/2 epochDur epochDur],...
            [(patchY*0.85) (patchY*0.9) (patchY*0.9) (patchY*0.85)]...
            ,[1 1 1]);
        patch([epochDur epochDur epochDur/2*3 epochDur/2*3],...
            [(patchY*0.85) (patchY*0.9) (patchY*0.9) (patchY*0.85)],...
            [0 0 0]);
        patch([epochDur/2*3 epochDur/2*3 epochDur*2 epochDur*2],...
            [(patchY*0.85) (patchY*0.9) (patchY*0.9) (patchY*0.85)]...
            ,[1 1 1]);

        set(gca,'xTick',0:(epochDur/2):(epochDur*2));
        
        if (inv) % reverse axes on inverted
            set(gca,'YDir','reverse');
        end
        
        % ask if responding
        userInput = input('Responding? [Y/I/N]: ','s');
        
        if (strcmpi(userInput, 'y')) % yes, responding
            iResp = [iResp r];
        elseif (strcmpi(userInput, 'i')) % inverted
            iInv = [iInv r];
        end % anything else, treat as no

        close all
        
    end

end