% MAIN  Run experiments on Quantum Fiber Simulator
clear;
clc;

% Adding tree structure to current path
addpath(genpath(pwd));

% Plots requirement
do_summary_plot = true; 
do_tensor_plot = true;
do_save = true;

% ==========================================
% Experiment 1 - Phase Baseline Sweep
% ==========================================
results_experiment_1 = run_experiment_1_phase_baseline_sweep( ...
    [], ...                 % θ values (default grid)
    do_summary_plot, ...    % summary plot 
    do_tensor_plot, ...     % tensor entries T(i,j) plots
    do_save);               % export figures

% ==========================================
% Experiment 2 - Random Phase Ensemble State
% ==========================================
results_experiment_2 = run_experiment_2_random_phase( ...
    [], ...                 % default cell array of case structures (constant, uniform, gaussian)
    do_summary_plot, ...    % summary plot 
    do_tensor_plot, ...     % tensor heatmap
    do_save);               % export figures

% ==========================================
% Experiment 3 - Random Phase Ensemble State
% ==========================================
results_experiment_3 = run_experiment_3_depolarization( ...
    [], ...                 % p values (default grid)
    do_summary_plot, ...    % summary plot
    do_save);               % export figures

% ==========================================
% Experiment 4 - CHSH Nonlocality
% ==========================================

results_experiment_4 = run_experiment_4_chsh_nonlocality( ...
    [], ...                 % θ values (default grid)
    [], ...                 % p values (default grid)
    do_summary_plot, ...    % summary plot
    do_tensor_plot, ...     % Bloch axes plot
    [], ...                 % CHSH axes (default optimal for |ψ⁺⟩)
    do_save);               % export figures