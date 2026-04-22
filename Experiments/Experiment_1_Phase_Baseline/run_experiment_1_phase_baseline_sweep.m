function results_experiment_1 = run_experiment_1_phase_baseline_sweep(theta_values, do_plot)
% RUN_EXPERIMENT_1_PHASE_BASELINE_SWEEP  Execute Experiment 1 baseline workflow.
%
% Objective:
%   Run the first validation experiment of the simulator, based on a
%   deterministic sweep of the relative phase theta introduced by the
%   reduced fiber model.
%
%   This function:
%       - generates numerical data through phase_baseline_sweep
%       - optionally plots the raw numerical correlations
%       - optionally plots the comparison between numerical and analytical
%         correlation results
%       - optionally plots state metrics associated with the sweep
%
% Input:
%   theta_values - numeric vector of phase values in radians
%                  (optional; default handled by phase_baseline_sweep)
%
%   do_plot      - logical flag controlling automatic plotting
%                  (optional; default = true)
%
% Output:
%   results_experiment_1 - structure containing the numerical results of
%                          the phase sweep experiment
%
% Notes:
%   This is an experiment-level runner.
%   It orchestrates the workflow of Experiment 1 but does not implement
%   low-level numerical routines itself.
%
%   The expected analytical reference curves for the correlation sector are:
%       c_xx(theta) = cos(theta)
%       c_yy(theta) = cos(theta)
%       c_zz(theta) = -1
%
%   In the extended state-characterization layer, the expected quantities are:
%       purity_global(theta)    = 1
%       purity_A(theta)         = 1/2
%       purity_B(theta)         = 1/2
%       fidelity_psi_plus(theta)= (1 + cos(theta)) / 2
%       concurrence(theta)      = 1

    % =========================
    % Default input handling
    % =========================

    if nargin < 2
        do_plot = true;
    end


    % =========================
    % Robustness checks
    % =========================

    if nargin >= 1 && ~isempty(theta_values)
        if ~isnumeric(theta_values) || ~isvector(theta_values)
            error('run_experiment_1_phase_baseline_sweep:InvalidThetaValues', ...
                'theta_values must be a numeric vector.');
        end

        if ~isreal(theta_values)
            error('run_experiment_1_phase_baseline_sweep:ComplexThetaValues', ...
                'theta_values must be real-valued.');
        end

        if any(~isfinite(theta_values))
            error('run_experiment_1_phase_baseline_sweep:NonFiniteThetaValues', ...
                'theta_values must contain only finite values.');
        end
    end

    if ~islogical(do_plot) || ~isscalar(do_plot)
        error('run_experiment_1_phase_baseline_sweep:InvalidPlotFlag', ...
            'do_plot must be a logical scalar.');
    end


    % =========================
    % Generate numerical data
    % =========================

    if nargin < 1 || isempty(theta_values)
        results_experiment_1 = phase_baseline_sweep();
    else
        results_experiment_1 = phase_baseline_sweep(theta_values);
    end


    % =========================
    % Console monitoring
    % =========================

    theta_values_out = results_experiment_1.theta_values(:).';

    c_xx_num = real(results_experiment_1.c_xx(:).');
    c_yy_num = real(results_experiment_1.c_yy(:).');
    c_zz_num = real(results_experiment_1.c_zz(:).');

    purity_global_num = real(results_experiment_1.purity_global(:).');
    purity_A_num = real(results_experiment_1.purity_A(:).');
    purity_B_num = real(results_experiment_1.purity_B(:).');
    fidelity_num = real(results_experiment_1.fidelity_psi_plus(:).');
    concurrence_num = real(results_experiment_1.concurrence(:).');

    c_xx_theory = cos(theta_values_out);
    c_yy_theory = cos(theta_values_out);
    c_zz_theory = -ones(size(theta_values_out));

    purity_global_theory = ones(size(theta_values_out));
    purity_A_theory = 0.5 * ones(size(theta_values_out));
    purity_B_theory = 0.5 * ones(size(theta_values_out));
    fidelity_theory = (1 + cos(theta_values_out)) / 2;
    concurrence_theory = ones(size(theta_values_out));

    fprintf('\n');
    fprintf('==========================================\n');
    fprintf('Experiment 1 - Monitoring summary\n');
    fprintf('==========================================\n');
    fprintf('theta sweep       : N = %d, min = %.6f, max = %.6f\n', ...
        numel(theta_values_out), min(theta_values_out), max(theta_values_out));
    fprintf('c_xx max |err|    : %.3e\n', max(abs(c_xx_num - c_xx_theory)));
    fprintf('c_yy max |err|    : %.3e\n', max(abs(c_yy_num - c_yy_theory)));
    fprintf('c_zz max |err|    : %.3e\n', max(abs(c_zz_num - c_zz_theory)));
    fprintf('gamma_AB max |err|: %.3e\n', max(abs(purity_global_num - purity_global_theory)));
    fprintf('gamma_A max |err| : %.3e\n', max(abs(purity_A_num - purity_A_theory)));
    fprintf('gamma_B max |err| : %.3e\n', max(abs(purity_B_num - purity_B_theory)));
    fprintf('F_Psi+ max |err|  : %.3e\n', max(abs(fidelity_num - fidelity_theory)));
    fprintf('C max |err|       : %.3e\n', max(abs(concurrence_num - concurrence_theory)));


    % =========================
    % Optional plotting
    % =========================

    if do_plot
        % Plot raw numerical correlations
        % correlations_to_plot = {'c_xx', 'c_yy', 'c_zz'};
        % plot_correlations(results_experiment_1, correlations_to_plot);

        % Plot numerical vs theory comparison
        plot_phase_baseline_comparison(results_experiment_1);
        plot_phase_baseline_state_metrics(results_experiment_1);
    end

end