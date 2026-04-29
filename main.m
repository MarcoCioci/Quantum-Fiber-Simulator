% MAIN  Run experiments on Quantum Fiber Simulator
clear;
clc;

% Adding tree structure to current path
addpath(genpath(pwd));

% Plots requirement
do_summary_plot = true; 
do_tensor_plot = true;

% % ==========================================
% % Experiment 1 - Phase Baseline Sweep
% % ==========================================
%     results_experiment_1 = run_experiment_1_phase_baseline_sweep([], do_summary_plot, do_tensor_plot);

% % ==========================================
% % Experiment 2 - Random Phase Ensemble State
% % ==========================================
%     results_experiment_2 = run_experiment_2_random_phase([], do_summary_plot, do_tensor_plot);

% % ==========================================
% % Experiment 3 - Random Phase Ensemble State
% % ==========================================
%     results_experiment_3 = run_experiment_3_depolarization(do_summary_plot);

% ==========================================
% Experiment 4 - Random Phase Ensemble State
% ==========================================
    run_experiment_4_chsh_nonlocality([], [], true, true, []);