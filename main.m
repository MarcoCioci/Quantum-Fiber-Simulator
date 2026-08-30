% MAIN  Run selected thesis experiments on Quantum Fiber Simulator.

clear;
clc;
close all;


% =========================
% Project path
% =========================

project_root = ...
    fileparts(mfilename('fullpath'));

addpath(project_root);
addpath(genpath(fullfile(project_root, 'src')));


% =========================
% Experiment selection
% =========================

actives = [2];


% =========================
% Plot and save options
% =========================

do_summary_plot = true;
do_regime_map = true;
do_save = true;


% =========================
% Run experiments
% =========================

for experiment_id = actives

    switch experiment_id

        case 1

            results_experiment_1 = ...
                run_experiment_1_single_segment_pmd( ...
                    do_summary_plot, ...
                    do_regime_map, ...
                    do_save);


        case 2

            results_experiment_2 = ...
                run_experiment_2_two_arm_pmd_spectral_correlations( ...
                    do_summary_plot, ...
                    do_regime_map, ...
                    do_save);


        otherwise

            error( ...
                'main:UnknownExperiment', ...
                'Unknown thesis experiment identifier: %d.', ...
                experiment_id);

    end

end