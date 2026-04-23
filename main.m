clear;
clc;

% Adding tree structure to current path
addpath(genpath(pwd));

% Plots requirement
do_plot = true; 

% ==========================================
% Experiment 1 - Phase Baseline Sweep
% ==========================================
results_experiment_1 = run_experiment_1_phase_baseline_sweep([], do_plot);

% ==========================================
% Experiment 2 - Random Phase Ensemble State
% ==========================================
results_experiment_2 = run_experiment_2_random_phase(do_plot);

% ==========================================
% Experiment 3 - Random Phase Ensemble State
% ==========================================
results = run_experiment_3_depolarization(do_plot);