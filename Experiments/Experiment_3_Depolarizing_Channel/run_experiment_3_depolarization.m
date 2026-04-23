function results_experiment_3 = run_experiment_3_depolarization(p_values, do_plot)
% RUN_EXPERIMENT_3_DEPOLARIZATION  Sweep Bell-state degradation under depolarizing noise.
%
% Objective:
%   Run Experiment 3 by applying the two-qubit depolarizing channel to the
%   reference Bell state |Psi+> over a user-defined set of depolarization
%   parameters p, and compute the corresponding state metrics and
%   correlation observables.
%
%   For each value of p, the experiment constructs
%
%       rho(p) = (1 - p) * rho_0 + (p / 4) * I_4
%
%   where rho_0 = |Psi+><Psi+| is the density operator of the reference
%   Bell state.
%
% Input:
%   p_values - optional real numeric vector containing depolarization
%              parameters, with each entry satisfying 0 <= p <= 1.
%              If omitted or empty, a default uniform grid with N = 100
%              samples in [0, 1] is used.
%
%   do_plot  - optional logical scalar. If true, the function calls
%              plot_depolarization_summary(results_experiment_3) at the end.
%              Default: false
%
% Output:
%   results_experiment_3 - structure containing:
%
%       .experiment_name         - descriptive experiment name
%       .reference_state_label   - Bell-state label used as input
%       .channel_model           - channel model identifier
%       .p_values                - sampled depolarization parameters
%       .rho_0                   - reference Bell-state density matrix
%       .rho                     - cell array of output density matrices
%       .purity_global           - global purity values
%       .purity_A                - reduced purity of subsystem A
%       .purity_B                - reduced purity of subsystem B
%       .fidelity_psi_plus       - fidelity with respect to |Psi+>
%       .concurrence             - concurrence values
%       .c_xx                    - <sigma_x \otimes sigma_x>
%       .c_yy                    - <sigma_y \otimes sigma_y>
%       .c_zz                    - <sigma_z \otimes sigma_z>
%       .analytical              - structure containing analytical predictions
%
% Notes:
%   This runner acts at experiment level and reuses the existing Core
%   routines for density-matrix manipulation, partial traces, purity,
%   fidelity, concurrence, and correlation evaluation.
%
%   The reference input state is the Bell state |Psi+>, consistent with the
%   theoretical development of the depolarizing model in the thesis guide.

    % =========================
    % Robustness checks
    % =========================

    if nargin == 0
        p_values = linspace(0, 1, 100);
        do_plot = false;
        fprintf('No inputs provided, sampling p with N = 100 uniformly in [0,1].\n');

    elseif nargin == 1
        if islogical(p_values) && isscalar(p_values)
            do_plot = p_values;
            p_values = linspace(0, 1, 100);
            fprintf('No p_values provided, sampling p with N = 100 uniformly in [0,1].\n');
        else
            do_plot = false;
        end

    elseif nargin == 2
        % keep provided p_values and do_plot
    else
        error('run_experiment_3_depolarization:InvalidNumInputs', ...
              'Expected zero, one, or two input arguments: p_values, do_plot.');
    end

    if isempty(p_values)
        p_values = linspace(0, 1, 100);
        fprintf('Empty p_values provided, sampling p with N = 100 uniformly in [0,1].\n');
    end

    if ~isnumeric(p_values) || ~isvector(p_values) || ~isreal(p_values)
        error('run_experiment_3_depolarization:InvalidType', ...
              'p_values must be a real numeric vector.');
    end

    if any(p_values < 0) || any(p_values > 1)
        error('run_experiment_3_depolarization:InvalidRange', ...
              'All entries of p_values must satisfy 0 <= p <= 1.');
    end

    if ~islogical(do_plot) || ~isscalar(do_plot)
        error('run_experiment_3_depolarization:InvalidPlotFlag', ...
              'do_plot must be a logical scalar.');
    end


    % =========================
    % Main computation
    % =========================

    p_values = p_values(:).';   % enforce row-vector storage

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
    results_experiment_3.c_xx = zeros(1, num_p);
    results_experiment_3.c_yy = zeros(1, num_p);
    results_experiment_3.c_zz = zeros(1, num_p);

    results_experiment_3.analytical.purity_global = zeros(1, num_p);
    results_experiment_3.analytical.purity_A = zeros(1, num_p);
    results_experiment_3.analytical.purity_B = zeros(1, num_p);
    results_experiment_3.analytical.fidelity_psi_plus = zeros(1, num_p);
    results_experiment_3.analytical.concurrence = zeros(1, num_p);
    results_experiment_3.analytical.c_xx = zeros(1, num_p);
    results_experiment_3.analytical.c_yy = zeros(1, num_p);
    results_experiment_3.analytical.c_zz = zeros(1, num_p);

    for i = 1:num_p
        p = p_values(i);

        rho_AB = depolarizing_channel_two_qubits(rho_0, p);
        results_experiment_3.rho{i} = rho_AB;

        results_experiment_3.purity_global(i) = compute_purity(rho_AB);

        rho_A = partial_trace_A(rho_AB);
        rho_B = partial_trace_B(rho_AB);

        results_experiment_3.purity_A(i) = compute_purity(rho_A);
        results_experiment_3.purity_B(i) = compute_purity(rho_B);

        results_experiment_3.fidelity_psi_plus(i) = compute_fidelity(rho_AB, psi_plus);
        results_experiment_3.concurrence(i) = compute_concurrence(rho_AB);

        correlations = compute_correlations(rho_AB);
        results_experiment_3.c_xx(i) = correlations.c_xx;
        results_experiment_3.c_yy(i) = correlations.c_yy;
        results_experiment_3.c_zz(i) = correlations.c_zz;

        % Analytical predictions
        results_experiment_3.analytical.purity_global(i) = 1 - (3/2) * p + (3/4) * p^2;
        results_experiment_3.analytical.purity_A(i) = 1/2;
        results_experiment_3.analytical.purity_B(i) = 1/2;
        results_experiment_3.analytical.fidelity_psi_plus(i) = 1 - (3/4) * p;
        results_experiment_3.analytical.concurrence(i) = max(0, 1 - (3/2) * p);
        results_experiment_3.analytical.c_xx(i) = 1 - p;
        results_experiment_3.analytical.c_yy(i) = 1 - p;
        results_experiment_3.analytical.c_zz(i) = -(1 - p);
    end


    % =========================
    % Console monitoring
    % =========================

    fprintf('\n');
    fprintf('==========================================\n');
    fprintf('Experiment 3 - Depolarizing Channel Summary\n');
    fprintf('Monitoring summary\n');
    fprintf('==========================================\n');

    fprintf('p sweep           : N = %d, min = %.6f, max = %.6f\n', ...
        numel(p_values), min(p_values), max(p_values));

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

    fprintf('c_xx max |err|    : %.3e\n', ...
        max(abs(results_experiment_3.c_xx - results_experiment_3.analytical.c_xx)));

    fprintf('c_yy max |err|    : %.3e\n', ...
        max(abs(results_experiment_3.c_yy - results_experiment_3.analytical.c_yy)));

    fprintf('c_zz max |err|    : %.3e\n', ...
        max(abs(results_experiment_3.c_zz - results_experiment_3.analytical.c_zz)));


    % =========================
    % Optional plotting
    % =========================

    if do_plot
        plot_depolarization_summary(results_experiment_3);
    end

end