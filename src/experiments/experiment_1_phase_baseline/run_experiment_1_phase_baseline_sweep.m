function results_experiment_1 = run_experiment_1_phase_baseline_sweep(theta_values, do_summary_plot, do_tensor_plot, do_save)
% RUN_EXPERIMENT_1_PHASE_BASELINE_SWEEP  Sweep Bell-state evolution under the reduced phase model.
%
% Objective:
%   Run Experiment 1 by propagating the reference Bell state |Ψ⁺⟩ through
%   the reduced deterministic phase model over a user-defined set of phase
%   values θ, and compute the corresponding correlation observables,
%   full correlation tensor, and state metrics.
%
% Input:
%   theta_values     - optional real numeric vector containing phase values in
%                      radians. If omitted, a default grid is handled by
%                      phase_baseline_sweep.
%
%   do_summary_plot  - optional logical scalar controlling automatic plotting.
%                      Default value: true.
%
%   do_tensor_plot   - optional logical scalar controlling plotting of the
%                      full correlation tensor. Default value: false.
%
%   do_save          - optional logical scalar controlling figure export.
%                      The same value is passed to all plot functions.
%                      Default value: false.
%
% Output:
%   results_experiment_1 - structure containing:
%       .experiment_name
%       .reference_state_label
%       .model_name
%       .theta_values
%       .correlation_tensor
%       .purity_global
%       .purity_A
%       .purity_B
%       .fidelity_psi_plus
%       .concurrence
%       .c_xx
%       .c_yy
%       .c_zz
%       .analytical
%
% Notes:
%   For the reduced phase model, the expected analytical quantities are:
%
%       c_xx(θ)              = cos(θ)
%       c_yy(θ)              = cos(θ)
%       c_zz(θ)              = -1
%       purity_global(θ)     = 1
%       purity_A(θ)          = 1/2
%       purity_B(θ)          = 1/2
%       fidelity_psi_plus(θ) = (1 + cos(θ)) / 2
%       concurrence(θ)       = 1
%
%   The full expected correlation tensor is:
%
%       T(θ) =
%       [ cos(θ), -sin(θ),   0
%         sin(θ),  cos(θ),   0
%         0,            0,  -1]

    % =========================
    % Default input handling
    % =========================

    if nargin < 2 || isempty(do_summary_plot)
        do_summary_plot = true;
    end

    if nargin < 3 || isempty(do_tensor_plot)
        do_tensor_plot = false;
    end

    if nargin < 4 || isempty(do_save)
        do_save = false;
    end


    % =========================
    % Robustness checks
    % =========================

    if nargin >= 1 && ~isempty(theta_values)
        if ~isnumeric(theta_values) || ~isvector(theta_values) || ~isreal(theta_values)
            error('run_experiment_1_phase_baseline_sweep:InvalidThetaValues', ...
                  'theta_values must be a real numeric vector.');
        end

        if any(~isfinite(theta_values))
            error('run_experiment_1_phase_baseline_sweep:NonFiniteThetaValues', ...
                  'theta_values must contain only finite values.');
        end
    end

    if ~islogical(do_summary_plot) || ~isscalar(do_summary_plot)
        error('run_experiment_1_phase_baseline_sweep:InvalidPlotFlag', ...
              'do_summary_plot must be a logical scalar.');
    end

    if ~islogical(do_tensor_plot) || ~isscalar(do_tensor_plot)
        error('run_experiment_1_phase_baseline_sweep:InvalidTensorPlotFlag', ...
              'do_tensor_plot must be a logical scalar.');
    end

    if ~islogical(do_save) || ~isscalar(do_save)
        error('run_experiment_1_phase_baseline_sweep:InvalidSaveFlag', ...
              'do_save must be a logical scalar.');
    end


    % =========================
    % Main computation
    % =========================

    if nargin < 1 || isempty(theta_values)
        results_experiment_1 = phase_baseline_sweep();
    else
        results_experiment_1 = phase_baseline_sweep(theta_values);
    end

    theta_values_out = results_experiment_1.theta_values(:).';
    N = numel(theta_values_out);

    results_experiment_1.experiment_name = 'Experiment 1 - Phase Baseline Sweep';
    results_experiment_1.reference_state_label = 'psi_plus';
    results_experiment_1.model_name = 'reduced_phase_model';
    results_experiment_1.theta_values = theta_values_out;

    results_experiment_1.c_xx = real(results_experiment_1.c_xx(:).');
    results_experiment_1.c_yy = real(results_experiment_1.c_yy(:).');
    results_experiment_1.c_zz = real(results_experiment_1.c_zz(:).');

    if ~isfield(results_experiment_1, 'correlation_tensor')
        error('run_experiment_1_phase_baseline_sweep:MissingCorrelationTensor', ...
              'results_experiment_1 must contain correlation_tensor.');
    end

    if ~isequal(size(results_experiment_1.correlation_tensor), [3, 3, N])
        error('run_experiment_1_phase_baseline_sweep:InvalidTensorSize', ...
              'correlation_tensor must have size 3x3xN.');
    end

    results_experiment_1.correlation_tensor = real(results_experiment_1.correlation_tensor);

    results_experiment_1.purity_global = real(results_experiment_1.purity_global(:).');
    results_experiment_1.purity_A = real(results_experiment_1.purity_A(:).');
    results_experiment_1.purity_B = real(results_experiment_1.purity_B(:).');
    results_experiment_1.fidelity_psi_plus = real(results_experiment_1.fidelity_psi_plus(:).');
    results_experiment_1.concurrence = real(results_experiment_1.concurrence(:).');

    results_experiment_1.analytical.c_xx = cos(theta_values_out);
    results_experiment_1.analytical.c_yy = cos(theta_values_out);
    results_experiment_1.analytical.c_zz = -ones(size(theta_values_out));

    results_experiment_1.analytical.correlation_tensor = zeros(3, 3, N);

    for idx = 1:N
        theta = theta_values_out(idx);

        results_experiment_1.analytical.correlation_tensor(:, :, idx) = [ ...
             cos(theta), -sin(theta),  0; ...
             sin(theta),  cos(theta),  0; ...
             0,           0,          -1 ...
        ];
    end

    results_experiment_1.analytical.purity_global = ones(size(theta_values_out));
    results_experiment_1.analytical.purity_A = 0.5 * ones(size(theta_values_out));
    results_experiment_1.analytical.purity_B = 0.5 * ones(size(theta_values_out));
    results_experiment_1.analytical.fidelity_psi_plus = (1 + cos(theta_values_out)) / 2;
    results_experiment_1.analytical.concurrence = ones(size(theta_values_out));


    % =========================
    % Console monitoring
    % =========================

    tensor_errors = zeros(1, N);

    for idx = 1:N
        tensor_errors(idx) = norm( ...
            results_experiment_1.correlation_tensor(:, :, idx) - ...
            results_experiment_1.analytical.correlation_tensor(:, :, idx), ...
            'fro');
    end

    fprintf('\n\n');
    fprintf('==========================================\n');
    fprintf('Experiment 1 - Monitoring Summary\n');
    fprintf('==========================================\n\n');
    fprintf('theta sweep            : N = %d, min = %.6f, max = %.6f\n', ...
        N, min(theta_values_out), max(theta_values_out));
    fprintf('c_xx max |err|         : %.3e\n', ...
        max(abs(results_experiment_1.c_xx - results_experiment_1.analytical.c_xx)));
    fprintf('c_yy max |err|         : %.3e\n', ...
        max(abs(results_experiment_1.c_yy - results_experiment_1.analytical.c_yy)));
    fprintf('c_zz max |err|         : %.3e\n', ...
        max(abs(results_experiment_1.c_zz - results_experiment_1.analytical.c_zz)));
    fprintf('T tensor max ||err||_F : %.3e\n', max(tensor_errors));
    fprintf('gamma_AB max |err|     : %.3e\n', ...
        max(abs(results_experiment_1.purity_global - results_experiment_1.analytical.purity_global)));
    fprintf('gamma_A max |err|      : %.3e\n', ...
        max(abs(results_experiment_1.purity_A - results_experiment_1.analytical.purity_A)));
    fprintf('gamma_B max |err|      : %.3e\n', ...
        max(abs(results_experiment_1.purity_B - results_experiment_1.analytical.purity_B)));
    fprintf('F_psi+ max |err|       : %.3e\n', ...
        max(abs(results_experiment_1.fidelity_psi_plus - results_experiment_1.analytical.fidelity_psi_plus)));
    fprintf('C max |err|            : %.3e\n', ...
        max(abs(results_experiment_1.concurrence - results_experiment_1.analytical.concurrence)));


    % =========================
    % Optional plotting
    % =========================

    if do_summary_plot
        plot_phase_baseline_comparison(results_experiment_1, do_save);
        plot_phase_baseline_state_metrics(results_experiment_1, do_save);
    end

    if do_tensor_plot
        plot_phase_baseline_tensor(results_experiment_1, do_save);
    end

end