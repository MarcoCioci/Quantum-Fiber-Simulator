function results_experiment_5 = run_experiment_5_composite_fiber_channel_pure(theta_values, p_A, p_B, do_plot, do_save)
% RUN_EXPERIMENT_5_COMPOSITE_FIBER_CHANNEL_PURE
% Study single-realization phase evolution combined with local two-arm depolarization.
%
% Objective:
%   Run Experiment 5 by applying the pure-branch composite fiber channel
%
%       ρ_out = (D_pA ⊗ D_pB)[U_θ ρ_in U_θ†]
%
%   to the reference Bell state |Ψ⁺⟩ over a sweep of phase values θ.
%
% Input:
%   theta_values - optional real numeric vector of phase values.
%                  Default: linspace(0, 2*pi, 361)
%
%   p_A          - optional depolarization parameter on subsystem A.
%                  Default: 0.20
%
%   p_B          - optional depolarization parameter on subsystem B.
%                  Default: 0.35
%
%   do_plot      - optional logical scalar controlling automatic plotting.
%                  Default: false
%
%   do_save      - optional logical scalar controlling figure export.
%                  Default: false
%
% Output:
%   results_experiment_5 - structure containing numerical and analytical
%                          results for the pure composite channel.
%
% Notes:
%   This version of Experiment 5 treats the single-realization branch of the
%   composite channel. Statistical phase ensembles are handled separately.

    % =========================
    % Default input handling
    % =========================

    if nargin < 1 || isempty(theta_values)
        theta_values = linspace(0, 2*pi, 361);
    end

    if nargin < 2 || isempty(p_A)
        p_A = 0.20;
    end

    if nargin < 3 || isempty(p_B)
        p_B = 0.35;
    end

    if nargin < 4 || isempty(do_plot)
        do_plot = false;
    end

    if nargin < 5 || isempty(do_save)
        do_save = false;
    end


    % =========================
    % Robustness checks
    % =========================

    if ~isnumeric(theta_values) || ~isvector(theta_values) || ~isreal(theta_values)
        error('run_experiment_5_composite_fiber_channel_pure:InvalidThetaValues', ...
              'theta_values must be a real numeric vector.');
    end

    if any(~isfinite(theta_values))
        error('run_experiment_5_composite_fiber_channel_pure:NonFiniteThetaValues', ...
              'theta_values must contain only finite values.');
    end

    if ~isnumeric(p_A) || ~isscalar(p_A) || ~isreal(p_A) || ~isfinite(p_A)
        error('run_experiment_5_composite_fiber_channel_pure:InvalidParameterA', ...
              'p_A must be a finite real numeric scalar.');
    end

    if ~isnumeric(p_B) || ~isscalar(p_B) || ~isreal(p_B) || ~isfinite(p_B)
        error('run_experiment_5_composite_fiber_channel_pure:InvalidParameterB', ...
              'p_B must be a finite real numeric scalar.');
    end

    if p_A < 0 || p_A > 1
        error('run_experiment_5_composite_fiber_channel_pure:InvalidRangeA', ...
              'p_A must satisfy 0 <= p_A <= 1.');
    end

    if p_B < 0 || p_B > 1
        error('run_experiment_5_composite_fiber_channel_pure:InvalidRangeB', ...
              'p_B must satisfy 0 <= p_B <= 1.');
    end

    if ~islogical(do_plot) || ~isscalar(do_plot)
        error('run_experiment_5_composite_fiber_channel_pure:InvalidPlotFlag', ...
              'do_plot must be a logical scalar.');
    end

    if ~islogical(do_save) || ~isscalar(do_save)
        error('run_experiment_5_composite_fiber_channel_pure:InvalidSaveFlag', ...
              'do_save must be a logical scalar.');
    end


    % =========================
    % Initialization
    % =========================

    theta_values = theta_values(:).';
    N_theta = numel(theta_values);

    psi_plus = bell_state('psi_plus');
    rho_0 = state_to_density_matrix(psi_plus);

    analytics = analytical_values_experiment_5(theta_values, p_A, p_B, 'pure');

    results_experiment_5.experiment_name = 'Experiment 5 - Composite Fiber Channel';
    results_experiment_5.reference_state_label = 'psi_plus';
    results_experiment_5.model_name = 'pure_phase_local_two_arm_depolarization';

    results_experiment_5.theta_values = theta_values;

    results_experiment_5.p_A = p_A;
    results_experiment_5.p_B = p_B;
    results_experiment_5.eta = analytics.eta;

    results_experiment_5.rho_0 = rho_0;
    results_experiment_5.rho = cell(1, N_theta);

    results_experiment_5.correlation_tensor = zeros(3, 3, N_theta);

    results_experiment_5.c_xx = zeros(1, N_theta);
    results_experiment_5.c_yy = zeros(1, N_theta);
    results_experiment_5.c_zz = zeros(1, N_theta);

    results_experiment_5.purity_global = zeros(1, N_theta);
    results_experiment_5.purity_A = zeros(1, N_theta);
    results_experiment_5.purity_B = zeros(1, N_theta);

    results_experiment_5.fidelity_psi_plus = zeros(1, N_theta);
    results_experiment_5.concurrence = zeros(1, N_theta);

    results_experiment_5.S_max = zeros(1, N_theta);

    results_experiment_5.analytical = analytics;


    % =========================
    % Main computation
    % =========================

    correlation_tensor = zeros(3, 3, N_theta);

    c_xx = zeros(1, N_theta);
    c_yy = zeros(1, N_theta);
    c_zz = zeros(1, N_theta);

    purity_global = zeros(1, N_theta);
    purity_A = zeros(1, N_theta);
    purity_B = zeros(1, N_theta);

    fidelity_psi_plus = zeros(1, N_theta);
    concurrence = zeros(1, N_theta);

    S_max = zeros(1, N_theta);


    for idx = 1:N_theta

        theta = theta_values(idx);

        % =========================
        % Composite fiber channel
        % =========================

        rho_out = composite_fiber_channel(rho_0, theta, p_A, p_B);

        results_experiment_5.rho{idx} = rho_out;


        % =========================
        % Reduced states
        % =========================

        rho_A = partial_trace_B(rho_out);
        rho_B = partial_trace_A(rho_out);


        % =========================
        % Correlation tensor
        % =========================

        T = compute_correlation_tensor(rho_out);

        correlation_tensor(:, :, idx) = T;

        c_xx(idx) = T(1,1);
        c_yy(idx) = T(2,2);
        c_zz(idx) = T(3,3);


        % =========================
        % State metrics
        % =========================

        purity_global(idx) = compute_purity(rho_out);
        purity_A(idx) = compute_purity(rho_A);
        purity_B(idx) = compute_purity(rho_B);

        fidelity_psi_plus(idx) = compute_fidelity(rho_out, psi_plus);

        concurrence(idx) = compute_concurrence(rho_out);


        % =========================
        % CHSH nonlocality
        % =========================

        S_max(idx) = compute_chsh_max_from_tensor(T);

    end


    % =========================
    % Store results
    % =========================

    results_experiment_5.correlation_tensor = correlation_tensor;

    results_experiment_5.c_xx = c_xx;
    results_experiment_5.c_yy = c_yy;
    results_experiment_5.c_zz = c_zz;

    results_experiment_5.purity_global = purity_global;
    results_experiment_5.purity_A = purity_A;
    results_experiment_5.purity_B = purity_B;

    results_experiment_5.fidelity_psi_plus = fidelity_psi_plus;

    results_experiment_5.concurrence = concurrence;

    results_experiment_5.S_max = S_max;


    % =========================
    % Console monitoring
    % =========================

    tensor_errors = zeros(1, N_theta);

    for idx = 1:N_theta

        tensor_errors(idx) = norm( ...
            results_experiment_5.correlation_tensor(:, :, idx) - ...
            results_experiment_5.analytical.correlation_tensor(:, :, idx), ...
            'fro');

    end

    fprintf('\n\n');

    fprintf('==========================================\n');
    fprintf('Experiment 5 - Composite Fiber Channel Pure State\n');
    fprintf('Pure State\n');
    fprintf('Monitoring summary\n');
    fprintf('==========================================\n\n');

    fprintf('theta sweep            : N = %d, min = %.6f, max = %.6f\n', ...
        N_theta, min(theta_values), max(theta_values));

    fprintf('p_A                    : %.6f\n', p_A);
    fprintf('p_B                    : %.6f\n', p_B);
    fprintf('eta                    : %.6f\n', results_experiment_5.eta);

    fprintf('T tensor max ||err||_F : %.3e\n', max(tensor_errors));

    fprintf('c_xx max |err|         : %.3e\n', ...
        max(abs(results_experiment_5.c_xx - results_experiment_5.analytical.c_xx)));

    fprintf('c_yy max |err|         : %.3e\n', ...
        max(abs(results_experiment_5.c_yy - results_experiment_5.analytical.c_yy)));

    fprintf('c_zz max |err|         : %.3e\n', ...
        max(abs(results_experiment_5.c_zz - results_experiment_5.analytical.c_zz)));

    fprintf('gamma_AB max |err|     : %.3e\n', ...
        max(abs(results_experiment_5.purity_global - results_experiment_5.analytical.purity_global)));

    fprintf('gamma_A max |err|      : %.3e\n', ...
        max(abs(results_experiment_5.purity_A - results_experiment_5.analytical.purity_A)));

    fprintf('gamma_B max |err|      : %.3e\n', ...
        max(abs(results_experiment_5.purity_B - results_experiment_5.analytical.purity_B)));

    fprintf('F_psi+ max |err|       : %.3e\n', ...
        max(abs(results_experiment_5.fidelity_psi_plus - results_experiment_5.analytical.fidelity_psi_plus)));

    fprintf('C max |err|            : %.3e\n', ...
        max(abs(results_experiment_5.concurrence - results_experiment_5.analytical.concurrence)));

    fprintf('S_max min              : %.6f\n', min(results_experiment_5.S_max));
    fprintf('S_max max              : %.6f\n', max(results_experiment_5.S_max));

    fprintf('S_max expected         : %.6f\n', ...
        results_experiment_5.analytical.S_max(1));

    fprintf('S_max max |err|        : %.3e\n', ...
        max(abs(results_experiment_5.S_max - results_experiment_5.analytical.S_max)));


    % =========================
    % Optional plotting
    % =========================

    if do_plot

        % TODO:
        %
        % plot_composite_fiber_summary(results_experiment_5, do_save)

    end

end