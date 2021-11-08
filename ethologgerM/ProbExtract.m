classdef ProbExtract < handle_light
    %UNTITLED Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Property1
    end
    
    methods
        function obj = untitled(inputArg1,inputArg2)
            %UNTITLED Construct an instance of this class
            %   Detailed explanation goes here
            obj.Property1 = inputArg1 + inputArg2;
        end
        
        function wsSnap = calcWavelets(obj,tsSnap,CFG)
            %Calculate prob positions
            
            waveparams = CFG.WAVELET_PARAMS('WaveletParameters');
            freqparams = CFG.WAVELET_PARAMS('FrequencyBandwith');
            smoothingparam =
            
            if iscell(tsSnap)
                for i=1:numel(tsSnap)
                    fb = cwtfilterbank('SignalLength', size(tsSnap{i},1),'SamplingFrequency',30,'FrequencyLimits',freqparams,'WaveletParameters',waveparams);
                    getScale = @(x) scaleSpectrum(fb,x);
                    wsSnap{i} = varfun(getScale,tsSnap{i});
                end
            elseif istable(tsSnap)
                fb = cwtfilterbank('SignalLength', size(tsSnap,1),'SamplingFrequency',30,'FrequencyLimits',freqparams,'WaveletParameters',waveparams);
                getScale = @(x) scaleSpectrum(fb,x)';
                wSnap = varfun(getScale,tsSnap);
            end
        end
        
        function [wavePro, probPeaks, probLocs] = extractProbMovements(wsSnap)
            
            for i=1:numel(wsSnap)
                
                %thor_post
                moving_together{i} = movmean(fix(normalize(wsSnap{i}.Fun_distance_origin_prob.*wsSnap{i}.Fun_distance_origin_thor_post)),smoothingparam);
                waveProb{i} = wsSnap{i}.Fun_distance_origin_prob;
                waveProb{i}(moving_together{i}>0) = 0;
                %atip and a6
                moving_together{i} = movmean(fix(normalize(wsSnap{i}.Fun_distance_origin_prob.*wsSnap{i}.Fun_distance_origin_atip)),smoothingparam);
                waveProb{i}(moving_together{i}>0) = 0;
                %a6
                moving_together{i} = movmean(fix(normalize(wsSnap{i}.Fun_distance_origin_prob.*wsSnap{i}.Fun_distance_origin_a6)),smoothingparam);
                waveProb{i}(moving_together{i}>0) = 0;
                
                [probPeaks{i},probLocs{i},peakWidths{i},peakProminences{i}] = findpeaks(waveProb{i},'MinPeakHeight',mean(waveProb{i}),'MinPeakDistance',45,'MinPeakWidth',30);
            end
            
        end
        
        
        function extractedPeaks = extractPeaks(tsSnap,probLocs,peakWidths)
            
            for i =1:numel(probLocs)
                intvl_length = round(peakWidths{i}(:)*2);
                intvl_locs = [probLocs{i}'-intvl_length probLocs{i}'+intvl_length];
               
                intvl_locs(intvl_locs(:,1)<1,1) = 1;
                intvl_locs(intvl_locs(:,2)>numel(tsSnap{i}.distance_origin_prob),2) = numel(tsSnap{i}.distance_origin_prob);
 
                extractedPeaks{i}  = arrayfun(@(x) tsSnap{i}.distance_origin_prob(intvl_locs(x,1):intvl_locs(x,2)),1:size(intvl_locs,1),'UniformOutput',false);
            end
            
        end
        
        function cleanPeaks(intvl_locs)
            while diff(intvl_locs(:,1))<0
                intvl_locs
            end
                
            
        end
        
        
        %             if sum(strcmp(fieldnames(tsSnap),'distance_origin_prob')) && sum(strmcp(fieldnames(tsSnap),'distance_origin_thor_post'))
        %                 dormant_intervals = expt_item.dormant_intervals;
        %
        %                 for i=1:size(dormant_intervals,1)
        %                     sliced_intervals.prob{i} = tsSnap.distance_origin_prob(dormant_intervals(i,1):dormant_intervals(i,2));
        %                     sliced_intervals.thor_post{i} = tsSnap.distance_origin_thor_post(dormant_intervals(i,1):dormant_intervals(i,2));
        %
        %                     fb = cwtfilterbank('SignalLength',numel(dormant_probs{2}),'SamplingFrequency',30,'FrequencyLimits',[0.25 1]);
        %                     savgprob = cellfun(@(x) scaleSpectrum(fb,x),sliced_intervals.prob,'UniformOutput',false);
        %                     savgthor  = cellfun(@(x) scaleSpectrum(fb,x),sliced_intervals.thor_post,'UniformOutput',false);
        %
        %
        %
        %                     %calculate
        %
        %                 end
        %
        %             else
        %                 error("Missing values for distance_origin_prob or distance_origin_thor_post")
        %             end
        %
        %
        %
        %             outputArg = obj.Property1 + inputArg;
        %         end
    end
end

