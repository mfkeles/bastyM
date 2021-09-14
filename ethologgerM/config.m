% Defaults.
CFG.ANNOTATION_PRIORITY = [
    "Haltere Switch",
    "Proboscis Pumping",
    "Postural Adjustment",
    "Grooming",
    "Twitching",
    "Muscle Relaxation",
    "Stop",
];
CFG.ADAPTIVE_LLH_THRESHOLD = 0.2;
CFG.MEDIAN_FILTER_SIZE = 6;
CFG.MOVING_THRESHOLD_ARGS = containers.Map(["n_components","threshold_idx","key"], {2,1,"local_max"});
CFG.REST_INTERVALS_ARGS = containers.Map(["min_rest","tol_duration","tol_percent","winsize"],{300,60,0.4,180});

CFG.ACTIVITY_THRESHOLD_ARGS = containers.Map(["n_components","threshold_idx","key"], {2,1,"local_max"});

CFG.ACTIVITY_DATUMS_LIST = {
    ["pose.halt_x", "pose.halt_y"],
    ["distance.thor_post-halt"],
    ["pose.prob_x", "pose.prob_y"],
    ["distance.head-prob"],
    ["pose.thor_post_x", "pose.thor_post_y"],
    ["distance.avg(thor_post-joint1,thor_post-joint2,thor_post-joint3)"],
};
% DECISION_TREE_ARGS = {
%     "criterion": "entropy",
%     "splitter": "random",
%     "max_features": "auto",
%     "min_samples_leaf": 10 ** 3
%     ## "max_depth": 5,
% }
% UMAP_ARGS = {
%     "n_neighbors": 70,
%     "min_dist": 0.00,
%     "spread": 0.9,
%     "n_components": 2,
%     "metric": "hellinger",
%     "low_memory": False,
% }
% HDBSCAN_ARGS = {
%     "min_cluster_size": 4500,
%     "min_samples": 1,
%     "cluster_selection_epsilon": 0.013,
%     "approx_min_span_tree": True,
%     "cluster_selection_method": "leaf",
%     "prediction_data": False,
% }
% POSTPROCESSING_ARGS = {
%     "winsize": 60,
%     "tol_percent": 0.1,
%     "count_inactive": False,
%     "verbose": True,
% }
% SERIAL_DEPENDENCY_ARGS = {"winsize": 30 * 20, "stepsize": 30 * 10}
