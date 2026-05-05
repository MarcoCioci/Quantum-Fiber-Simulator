function results_experiment_3 = run_experiment_3_depolarization(p_values, do_plot, do_save)
% RUN_EXPERIMENT_3_DEPOLARIZATION  Sweep Bell-state degradation under depolarizing noise.
%
% Objective:
%   Run Experiment 3 by applying the two-qubit depolarizing channel to the
%   reference Bell state |Ψ⁺⟩ over a user-defined set of depolarization
%   parameters p, and compute the corresponding state metrics, correlation
%   observables, and correlation tensor.
%
%   For each value of p, the experiment constructs
%
%       ρ(p) = (1 - p) ρ_0 + (p / 4) I_4
%
%   where ρ_0 = |Ψ⁺⟩⟨Ψ⁺| is the density operator of the reference
%   Bell state.
%
% Input:
%   p_values - optional real numeric vector containing depolarization
%              parameters, with each entry satisfying 0 <= p <= 1.
%              If omitted or empty, a default uniform grid with N = 100
%              samples in [0, 1] is used.
%
%   do_plot  - optional logical scalar controlling automatic plotting.
%              Default value: true.
%
%   do_save  - optional logical scalar controlling figure export.
%              Default value: false.
%
% Output:
%   results_experiment_3 - structure containing Experiment 3 results

    % =========================
    % Default input handling
    % =========================

    if nargin < 1 || isempty(p_values)
        p_values = linspace(0, 1, 100);
        fprintf('No p_values provided, sampling p with N = 100 uniformly in [0,1].\n');
    end

    if nargin < 2 || isempty(do_plot)
        do_plot = true;
    end

    if nargin < 3 || isempty(do_save)
        do_save = false;
    end


    % =========================
    % Robustness checks
    % =========================

    if ~isnumeric(p_values) || ~isvector(p_values) || ~isreal(p_values)
        error('run_experiment_3_depolarization:InvalidPValuesType', ...
              'p_values must be a real numeric vector.');
    end

    if any(~isfinite(p_values))
        error('run_experiment_3_depolarization:InvalidPValues', ...
              'p_values must contain only finite values.');
    end

    if any(p_values < 0) || any(p_values > 1)
        error('run_experiment_3_depolarization:InvalidPValuesRange', ...
              'All entries of p_values must satisfy 0 <= p <= 1.');
    end

    if ~islogical(do_plot) || ~isscalar(do_plot)
        error('run_experiment_3_depolarization:InvalidPlotFlag', ...
              'do_plot must be a logical scalar.');
    end

    if ~islogical(do_save) || ~isscalar(do_save)
        error('run_experiment_3_depolarization:InvalidSaveFlag', ...
              'do_save must be a logical scalar.');
    end


    % =========================
    % Initialization
    % =========================

    p_values = p_values(:).';

    psi_plus = bell_state('psi_plus');
    rho_0 = state_to_density_matrix(psi_plus);
    num_p = numel(p_values);

    results_experiment_3.experiment_name = 'Experiment 3 - Depolarizing Channel';
    results_experiment_3.reference_state_label = 'psi_plus';
    results_experiment_3.channel_model = 'global_two_qubit_depolarizing';
    results_experiment_3.p_values = p_values;
    results_experiment_3.rho_0 = rho_0;

    results_experiment_3.rho = cell(1, num_p);

    results_experiment_3.purity_global = zeros(1, num_p);
    results_experiment_3.purity_A = zeros(1, num_p);
    results_experiment_3.purity_B = zeros(1, num_p);
    results_experiment_3.fidelity_psi_plus = zeros(1, num_p);
    results_experiment_3.concurrence = zeros(1, num_p);

    results_experiment_3.T = cell(1, num_p);
    results_experiment_3.c_xx = zeros(1, num_p);
    results_experiment_3.c_yy = zeros(1, num_p);
    results_experiment_3.c_zz = zeros(1, num_p);

    results_experiment_3.analytical.purity_global = zeros(1, num_p);
    results_experiment_3.analytical.purity_A = zeros(1, num_p);
    results_experiment_3.analytical.purity_B = zeros(1, num_p);
    results_experiment_3.analytical.fidelity_psi_plus = zeros(1, num_p);
    results_experiment_3.analytical.concurrence = zeros(1, num_p);

    results_experiment_3.analytical.T = cell(1, num_p);
    results_experiment_3.analytical.c_xx = zeros(1, num_p);
    results_experiment_3.analytical.c_yy = zeros(1, num_p);
    results_experiment_3.analytical.c_zz = zeros(1, num_p);

    T_psi_plus = diag([1, 1, -1]);


    % =========================
    % Main loop
    % =========================

    for idx = 1:num_p

        p = p_values(idx);

        rho_AB = global_depolarizing_channel(rho_0, p);

        rho_A = partial_trace_B(rho_AB);
        rho_B = partial_trace_A(rho_AB);

        T = compute_correlation_tensor(rho_AB);

        T_analytical = (1 - p) * T_psi_plus;


        % =========================
        % Store numerical results
        % =========================

        results_experiment_3.rho{idx} = rho_AB;

        results_experiment_3.purity_global(idx) = compute_purity(rho_AB);
        results_experiment_3.purity_A(idx) = compute_purity(rho_A);
        results_experiment_3.purity_B(idx) = compute_purity(rho_B);

        results_experiment_3.fidelity_psi_plus(idx) = compute_fidelity(rho_AB, psi_plus);
        results_experiment_3.concurrence(idx) = compute_concurrence(rho_AB);

        results_experiment_3.T{idx} = T;

        results_experiment_3.c_xx(idx) = T(1, 1);
        results_experiment_3.c_yy(idx) = T(2, 2);
        results_experiment_3.c_zz(idx) = T(3, 3);


        % =========================
        % Store analytical results
        % =========================

        results_experiment_3.analytical.purity_global(idx) = ...
            1 - (3/2) * p + (3/4) * p^2;

        results_experiment_3.analytical.purity_A(idx) = 1/2;
        results_experiment_3.analytical.purity_B(idx) = 1/2;

        results_experiment_3.analytical.fidelity_psi_plus(idx) = ...
            1 - (3/4) * p;

        results_experiment_3.analytical.concurrence(idx) = ...
            max(0, 1 - (3/2) * p);

        results_experiment_3.analytical.T{idx} = T_analytical;

        results_experiment_3.analytical.c_xx(idx) = T_analytical(1, 1);
        results_experiment_3.analytical.c_yy(idx) = T_analytical(2, 2);
        results_experiment_3.analytical.c_zz(idx) = T_analytical(3, 3);

    end


    % =========================
    % Console monitoring
    % =========================

    T_max_error = 0;

    for idx = 1:num_p
        T_error = norm( ...
            results_experiment_3.T{idx} - results_experiment_3.analytical.T{idx}, ...
            'fro');

        T_max_error = max(T_max_error, T_error);
    end

    fprintf('\n');
    fprintf('==========================================\n');
    fprintf('Experiment 3 - Depolarizing Channel Summary\n');
    fprintf('Monitoring summary\n');
    fprintf('==========================================\n');

    fprintf('p sweep           : N = %d, min = %.6f, max = %.6f\n', ...
        num_p, min(p_values), max(p_values));

    fprintf('gamma_AB max |err|: %.3e\n', ...
        max(abs(results_experiment_3.purity_global - results_experiment_3.analytical.purity_global)));

    fprintf('gamma_A max |err| : %.3e\n', ...
        max(abs(results_experiment_3.purity_A - results_experiment_3.analytical.purity_A)));

    fprintf('gamma_B max |err| : %.3e\n', ...
        max(abs(results_experiment_3.purity_B - results_experiment_3.analytical.purity_B)));

    fprintf('F_Psi+ max |err|  : %.3e\n', ...
        max(abs(results_experiment_3.fidelity_psi_plus - results_experiment_3.analytical.fidelity_psi_plus)));

    fprintf('C max |err|       : %.3e\n', ...
        max(abs(results_experiment_3.concurrence - results_experiment_3.analytical.concurrence)));

    fprintf('T max Fro err     : %.3e\n', T_max_error);

    fprintf('c_xx max |err|    : %.3e\n', ...
        max(abs(results_experiment_3.c_xx - results_experiment_3.analytical.c_xx)));

    fprintf('c_yy max |err|    : %.3e\n', ...
        max(abs(results_experiment_3.c_yy - results_experiment_3.analytical.c_yy)));

    fprintf('c_zz max |err|    : %.3e\n', ...
        max(abs(results_experiment_3.c_zz - results_experiment_3.analytical.c_zz)));


    % =========================
    % Plotting
    % =========================

    if do_plot
        plot_depolarization_summary(results_experiment_3, do_save);
    end

end