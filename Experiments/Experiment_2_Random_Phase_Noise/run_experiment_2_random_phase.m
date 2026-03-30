function results_experiment_2 = run_experiment_2_random_phase(theta_samples)
% RUN_EXPERIMENT_2_RANDOM_PHASE  Execute Experiment 2 random-phase workflow.
%
% Objective:
%   Run the first mixed-state validation experiment of the simulator, based
%   on an externally provided set of sampled relative phases.
%
%   This function:
%       - builds the ensemble-averaged density matrix through
%         random_phase_ensemble_state
%       - computes the aligned two-qubit Pauli correlations for the mixed
%         state
%       - assembles the main experiment results into a single structure
%       - plots the numerical results against the analytical ensemble model
%
% Input:
%   theta_samples - numeric vector of sampled phase values in radians
%
% Output:
%   results_experiment_2 - structure containing:
%       .theta_samples
%       .num_samples
%       .rho_ensemble
%       .correlations
%       .c_xx
%       .c_yy
%       .c_zz
%
% Notes:
%   This is an experiment-level runner.
%   It orchestrates the workflow of Experiment 2 but does not implement
%   low-level state construction or observable evaluation itself.
%
%   The phase samples are intentionally provided externally:
%       - reproducibility is preserved
%       - testing is simplified
%       - phase sampling remains separate from experiment execution
%
%   The comparison plot is generated automatically at the end of the
%   workflow through plot_random_phase_comparison.

    % =========================
    % Robustness checks
    % =========================
    if nargin ~= 1
        error('run_experiment_2_random_phase:InvalidNumInputs', ...
            'Expected exactly 1 input argument: theta_samples.');
    end

    if ~isnumeric(theta_samples) || ~isvector(theta_samples)
        error('run_experiment_2_random_phase:InvalidInputType', ...
            'theta_samples must be a numeric vector.');
    end

    if isempty(theta_samples)
        error('run_experiment_2_random_phase:EmptyInput', ...
            'theta_samples must not be empty.');
    end

    if ~isreal(theta_samples)
        error('run_experiment_2_random_phase:ComplexInput', ...
            'theta_samples must be a real-valued vector.');
    end

    if any(~isfinite(theta_samples))
        error('run_experiment_2_random_phase:NonFiniteInput', ...
            'theta_samples must contain only finite values.');
    end

    theta_samples = theta_samples(:).';   % force row vector

    % =========================
    % Generate ensemble state
    % =========================
    rho_ensemble = random_phase_ensemble_state(theta_samples);

    % =========================
    % Compute mixed-state correlations
    % =========================
    correlations = compute_correlations_density(rho_ensemble);

    % =========================
    % Assemble output structure
    % =========================
    results_experiment_2 = struct();
    results_experiment_2.theta_samples = theta_samples;
    results_experiment_2.num_samples   = numel(theta_samples);
    results_experiment_2.rho_ensemble  = rho_ensemble;
    results_experiment_2.correlations  = correlations;
    results_experiment_2.c_xx          = real(correlations.c_xx);
    results_experiment_2.c_yy          = real(correlations.c_yy);
    results_experiment_2.c_zz          = real(correlations.c_zz);

    % =========================
    % Plot numerical vs theory comparison
    % =========================
    plot_random_phase_comparison(results_experiment_2);

end