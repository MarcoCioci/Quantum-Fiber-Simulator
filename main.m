clear;
clc;

addpath('Core');
addpath('Models');
addpath('Utils');
addpath('Experiments');

results_sweep_phase = sweep_phase();

correlations_to_plot = {'c_xx', 'c_yy', 'c_zz'};
plot_correlations(results_sweep_phase, correlations_to_plot);