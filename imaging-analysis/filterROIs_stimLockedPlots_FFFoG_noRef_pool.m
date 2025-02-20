% filterROIs_stimLockedPlots_FFFoG_noRef_pool.m 
%
% Function to obtain stimulus-locked average responses and error per ROI
%  for presentations of different length flashes off of gray. Uses full 
%  contrast flash stimulus (search stimulus or full field) as way of 
%  identifying responding cells 
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
% CREATED: 3/28/22 - HHY
%
% UPDATED:
%   3/29/22 - HHY
%

function [roiMatNew, iResp, iInv, framesPerLDCycle] = ...
    filterROIs_stimLockedPlots_FFFoG_noRef_pool(roiMat, pairedEpochs, ...
    FRAME_RATE, inv, yScale, binWidthMult)
    
    % initialization
    BIN_WIDTH = binWidthMult * (1/FRAME_RATE);
    BIN_SHIFT = 1/FRAME_RATE;
    P_VAL_THRESH = 0.01; % emperically, based on tests on fake data
    iResp = [];
    iInv = [];
   
    
    cm = colormap('lines');
    close all
    
    % for placing stimulus patch appropriately with inverted or not
    if (inv)
    	patchY = yScale(1);
    else
        patchY = yScale(2);
    end

    % only 1 column
    roiMatNew = roiMat(:,1);
    
    % loop over all cells
    for r = 1:size(roiMat, 1)


        % change how stimDat is dealt with after loadROIData change
        flashDurations = cell2mat(roiMat(r,nonRefCols(1)).stimDat.FlashDuration);
        grayDuration = roiMat(r,nonRefCols(1)).stimDat.GrayDuration{1}; 
        
        % compute mean and error
        [meanResp, stdErr, t] = ...
            compute_meanResp_err_moveAvg_FFFoG_pool(roiMat(r,:),...
            flashDurations + grayDuration, ...
            BIN_SHIFT, BIN_WIDTH, FRAME_RATE);
        
        % save info, 2nd column for impulse
        roiMatNew(r).rats = meanResp;
        roiMatNew(r).stdErrs = stdErr;
        roiMatNew(r).t = t;
        roiMatNew(r).BIN_SHIFT = BIN_SHIFT;
%                     in(r,s).sigPInd = sigPInd;

        % ask if reference stimulus is responding/not/inverted (but display
        % others)
        
        % display
        figure;

%         % -----  plot reference stimulus ---- %
%         subplot(size(roiMatNew,2),size(pairedEpochs,1),1:size(pairedEpochs,1))
%         title(sprintf('Cell %d',r));
%         xScale = [0, refEpochDur * 2];
%         plot_err_patch_v2((0:length(refMeanResp)*2)*BIN_SHIFT,...
%             [refMeanResp; refMeanResp; refMeanResp(1)], ...
%             [refStdErr; refStdErr; refStdErr(1)], [0 0 1],[0.5 0.5 1]);
%         xlabel('time (sec)');
%         ylabel('response (dF/F)');
% %         yScale = ylim;
%         xlim(xScale);
%         line([0 refEpochDur*2],[0 0],'color',[0 0 0]);
%         for k = 1:4
%             line([(k-1)*refEpochDur/2 (k-1)*refEpochDur/2],yScale,...
%                 'color',[0 0 0],'linestyle','--');
%         end
%         % light/dark epoch labels
%         patch([0 0 refEpochDur/2 refEpochDur/2],...
%             [(patchY*0.85) (patchY*0.9) (patchY*0.9) (patchY*0.85)],...
%             [0 0 0]);
%         patch([refEpochDur/2 refEpochDur/2 refEpochDur refEpochDur],...
%             [(patchY*0.85) (patchY*0.9) (patchY*0.9) (patchY*0.85)]...
%             ,[1 1 1]);
%         patch([refEpochDur refEpochDur refEpochDur/2*3 refEpochDur/2*3],...
%             [(patchY*0.85) (patchY*0.9) (patchY*0.9) (patchY*0.85)],...
%             [0 0 0]);
%         patch([refEpochDur/2*3 refEpochDur/2*3 refEpochDur*2 refEpochDur*2],...
%             [(patchY*0.85) (patchY*0.9) (patchY*0.9) (patchY*0.85)]...
%             ,[1 1 1]);
% 
%         set(gca,'xTick',0:(refEpochDur/2):(refEpochDur*2));
%         
%         if (inv) % reverse axes on inverted
%             set(gca,'YDir','reverse');
%         end
        
        % plot red * for all bins where p-value < P_VAL_THRESH
%         sigPIndTimes = (sigPInd-1) / FRAME_RATE + (1/FRAME_RATE/2);
%         plot(sigPIndTimes,ones(1,length(sigPIndTimes))*yScale(1) * 0.75,...
%             'r*');
        
        % ----- plot full field flash onto gray stimuli ---- % 
        % for each light/dark pairing 
        for j = 2:size(roiMatNew,2)
            for k = 1:size(pairedEpochs,1)
                subplot(size(roiMatNew,2),size(pairedEpochs,1),...
                    k+(j-1)*size(pairedEpochs,1))

                for l = 1:size(pairedEpochs,2)
%                     plot_err_patch_v2(...
%                         (0:length(roiMat(r,j).rats{pairedEpochs(k,l)}))...
%                         * BIN_SHIFT,...
%                         [roiMat(r,j).rats{pairedEpochs(k,l)}...
%                         roiMat(r,j).rats{pairedEpochs(k,l)}(1)],...
%                         [roiMat(r,j).stdErrs{pairedEpochs(k,l)}...
%                         roiMat(r,j).stdErrs{pairedEpochs(k,l)}(1)], ...
%                         cm(l,:),(cm(l,:)+1)/2);
                    if (k <= length(roiMatNew(r,j).rats))
                        plot_err_patch_v2(...
                            roiMatNew(r,j).t{pairedEpochs(k,l)},...
                            roiMatNew(r,j).rats{pairedEpochs(k,l)},...
                            roiMatNew(r,j).stdErrs{pairedEpochs(k,l)},...
                            cm(l,:),(cm(l,:)+1)/2);
                        hold on;
                    end
                end
                iDur = pairedEpochs(k);
                seqDur = flashDurations(iDur) + grayDuration;

                xScale = [0, seqDur];
                xlabel('time (sec)');
                ylabel('response (dF/F)');
                yScale = ylim;
                xlim(xScale);
                line([0 seqDur],[0 0],'color',[0 0 0]); % x-axis line

                line([flashDurations(iDur) flashDurations(iDur)], yScale, 'color',[0 0 0],...
                    'linestyle','--');
                
                if (inv) % reverse axes on inverted
                    set(gca,'YDir','reverse');
                end
            end
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