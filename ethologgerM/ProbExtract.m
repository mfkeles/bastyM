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
        
        function outputArg = calcWavelets(obj,tsSnap,CFG)
            %Calculate prob positions
            
            waveparams = CFG.WAVELET_PARAMS('WaveletParameters');
            freqparams = CFG.WAVELET_PARAMS('FrequencyBandwith');
            
            for i=1:numel(tsSnap)
                fb = cwtfilterbank('SignalLength', size(tsSnap{i},1),'SamplingFrequency',30,'FrequencyLimits',freqparams,'WaveletParameters',waveparams);
                getScale = @(x) scaleSpectrum(fb,x);
                wsSnap{i} = varfun(getScale,tsSnap{i});
            end
        end
            
        function
            
        end
        
            
            
            if sum(strcmp(fieldnames(tsSnap),'distance_origin_prob')) && sum(strmcp(fieldnames(tsSnap),'distance_origin_thor_post'))
                dormant_intervals = expt_item.dormant_intervals;
                
                for i=1:size(dormant_intervals,1)
                    sliced_intervals.prob{i} = tsSnap.distance_origin_prob(dormant_intervals(i,1):dormant_intervals(i,2));
                    sliced_intervals.thor_post{i} = tsSnap.distance_origin_thor_post(dormant_intervals(i,1):dormant_intervals(i,2));
                    
                    fb = cwtfilterbank('SignalLength',numel(dormant_probs{2}),'SamplingFrequency',30,'FrequencyLimits',[0.25 1]);
                    savgprob = cellfun(@(x) scaleSpectrum(fb,x),sliced_intervals.prob,'UniformOutput',false);
                    savgthor  = cellfun(@(x) scaleSpectrum(fb,x),sliced_intervals.thor_post,'UniformOutput',false);
                    
                    
                    
                    %calculate 
 
                end

            else
                error("Missing values for distance_origin_prob or distance_origin_thor_post")
            end
            
                
            
            outputArg = obj.Property1 + inputArg;
        end
    end
end
