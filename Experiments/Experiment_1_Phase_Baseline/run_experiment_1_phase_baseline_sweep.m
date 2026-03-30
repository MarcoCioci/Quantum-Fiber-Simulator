function results_experiment_1 = run_experiment_1_phase_baseline_sweep(theta_values)
% RUN_PHASE_BASELINE_SWEEP  Execute Experiment 1 baseline workflow.
%
% Objective:
%   Run the first validation experiment of the simulator, based on a
%   deterministic sweep of the relative phase theta introduced by the
%   reduced fiber model.
%
%   This function:
%       - generates numerical correlation data through phase_baseline_sweep
%       - plots the raw numerical correlations
%       - plots the comparison between numerical and analytical results
%
% Input:
%   theta_values - numeric vector of phase values in radians
%                  (optional; default handled by phase_baseline_sweep)
%
% Output:
%   results_experiment_1 - structure containing the numerical results of
%                            the phase sweep experiment
%
% Notes:
%   This is an experiment-level runner.
%   It orchestrates the workflow of Experiment 1 but does not implement
%   low-level numerical routines itself.
%
%   The expected analytical reference curves for this experiment are:
%       c_xx(theta) = cos(theta)
%       c_yy(theta) = cos(theta)
%       c_zz(theta) = -1

    % =========================
    % Generate numerical data
    % =========================
    if nargin < 1
        results_experiment_1 = phase_baseline_sweep();
    else
        results_experiment_1 = phase_baseline_sweep(theta_values);
    end

    % =========================
    % Plot raw numerical correlations
    % =========================

    % correlations_to_plot = {'c_xx', 'c_yy', 'c_zz'};
    % plot_correlations(results_experiment_1, correlations_to_plot);

    % =========================
    % Plot numerical vs theory comparison
    % =========================
    plot_phase_baseline_comparison(results_experiment_1);

end