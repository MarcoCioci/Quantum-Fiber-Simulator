clear;
clc;

% Adding tree structure to current path
addpath(genpath(pwd));

% ==========================================
% Experiment 1 - Phase Baseline Sweep
% ==========================================
% results_experiment_1 = run_experiment_1_phase_baseline_sweep([], true);

% ==========================================
% Experiment 2 - Random Phase Ensemble State
% ==========================================
results_experiment_2_all = run_experiment_2_random_phase();