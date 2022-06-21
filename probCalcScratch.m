%dormant intervals
%slice prob associated features 

%look at delta

dormant_intervals = expt_item.dormant_intervals;

for i = 1:size(dormant_intervals,1)
dormant_probs{i} = tSnap.distance_origin_prob(dormant_intervals(i,1):dormant_intervals(i,2),:);
end

ndormant_probs = cellfun(@(x) normalize(x),dormant_probs,'UniformOutput',false);

findpeaks(dormant_probs{2},'MinPeakDistance',25,'MinPeakProminence',20)
invertedProbs = max(dormant_probs{2}) - dormant_probs{2};


fb = cwtfilterbank('SignalLength',numel(dormant_probs{2}),'SamplingFrequency',30,'FrequencyLimits',[0.25 1]);

savgp = scaleSpectrum(fb,dormant_probs{2});

savgp = scaleSpectrum(fb,

nsavgp = normalize(savgp);

tarr = abs(round(diff(dormant_probs{2})).*round(diff(dormant_thor)));

boom = normalize(tsavgp).*normalize(savgp);
find(boom)

43493
43418


test_pumps = tsSnap{2};
idxs = labeled_signasl.prob{1}.ROILimits;

clf
for i=1:size(idxs,1)
 
    plot(test_pumps.distance_origin_prob(idxs(i,1):idxs(i,2)),'k')
    
    pause
end


%to calculate a 5 sec windows for correlation

prob_corr = wsSnap{1}.Fun_distance_origin_prob(1:30*5:end);
thor_corr = wsSnap{1}.Fun_distance_origin_thor_post(1:30*5:end);


 iteration = floor(numel(wsSnap{1}.Fun_distance_origin_prob)/150);
 idx_arr = 1:150:numel(wsSnap{1}.Fun_distance_origin_prob);
for i=1:iteration
    prob_corr(:,i) = tsSnap{1}.distance_origin_prob(idx_arr(i):idx_arr(i+1));
    thor_corr(:,i) = tsSnap{1}.distance_origin_thor_post(idx_arr(i):idx_arr(i+1));
end


for i=1:195
    arr = sort(unique(corrcoef([prob_corr(:,i),thor_corr(:,i)])));
    diff_r(i) = arr(1);
end


for i=1:size(R,1)/2
    rR(i) = R(i,i+195);
    
end

    


