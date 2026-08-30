function results_experiment_5 = run_experiment_5_composite_fiber_channel_ensemble(experiment_5_cases, p_A, p_B, do_summary_plot, do_tensor_plot, do_save)
% RUN_EXPERIMENT_5_COMPOSITE_FIBER_CHANNEL_ENSEMBLE
% Study statistical phase ensembles combined with local two-arm depolarization.

    % =========================
    % Default input handling
    % =========================

    fprintf('\n\n==========================================\n');
    fprintf('Experiment 5 - Composite Fiber Channel\n');
    fprintf('Ensemble - Monitoring summary\n');
    fprintf('==========================================\n');

    num_samples = 100;

    if nargin < 1 || isempty(experiment_5_cases)
        experiment_5_cases = {
            struct('distribution_type','constant','num_samples',num_samples,'parameters',{{pi/4}}, ...
                'label','constant | θ = π/4'); ...

            struct('distribution_type','uniform','num_samples',num_samples,'parameters',{{0,2*pi}}, ...
                'label','uniform | θ ∈ [0, 2π]'); ...

            struct('distribution_type','gaussian','num_samples',num_samples,'parameters',{{0,1}}, ...
                'label','gaussian | θ ~ N(0,1)')
        };
    end

    if nargin < 2 || isempty(p_A)
        p_A = 0.20;
    end

    if nargin < 3 || isempty(p_B)
        p_B = 0.35;
    end

    if nargin < 4 || isempty(do_summary_plot)
        do_summary_plot = false;
    end

    if nargin < 5 || isempty(do_tensor_plot)
        do_tensor_plot = false;
    end

    if nargin < 6 || isempty(do_save)
        do_save = false;
    end


    % =========================
    % Robustness checks
    % =========================

    if ~iscell(experiment_5_cases)
        error('run_experiment_5_composite_fiber_channel_ensemble:InvalidCasesType', ...
              'experiment_5_cases must be a cell array.');
    end

    if ~isnumeric(p_A) || ~isscalar(p_A) || ~isreal(p_A) || ~isfinite(p_A)
        error('run_experiment_5_composite_fiber_channel_ensemble:InvalidParameterA', ...
              'p_A must be a finite real numeric scalar.');
    end

    if ~isnumeric(p_B) || ~isscalar(p_B) || ~isreal(p_B) || ~isfinite(p_B)
        error('run_experiment_5_composite_fiber_channel_ensemble:InvalidParameterB', ...
              'p_B must be a finite real numeric scalar.');
    end

    if p_A < 0 || p_A > 1
        error('run_experiment_5_composite_fiber_channel_ensemble:InvalidRangeA', ...
              'p_A must satisfy 0 <= p_A <= 1.');
    end

    if p_B < 0 || p_B > 1
        error('run_experiment_5_composite_fiber_channel_ensemble:InvalidRangeB', ...
              'p_B must satisfy 0 <= p_B <= 1.');
    end

    if ~islogical(do_summary_plot) || ~isscalar(do_summary_plot)
        error('run_experiment_5_composite_fiber_channel_ensemble:InvalidSummaryPlotFlag', ...
              'do_summary_plot must be a logical scalar.');
    end

    if ~islogical(do_tensor_plot) || ~isscalar(do_tensor_plot)
        error('run_experiment_5_composite_fiber_channel_ensemble:InvalidTensorPlotFlag', ...
              'do_tensor_plot must be a logical scalar.');
    end

    if ~islogical(do_save) || ~isscalar(do_save)
        error('run_experiment_5_composite_fiber_channel_ensemble:InvalidSaveFlag', ...
              'do_save must be a logical scalar.');
    end


    % =========================
    % Initialization
    % =========================

    psi_plus = bell_state('psi_plus');
    rho_0 = state_to_density_matrix(psi_plus);

    num_cases = numel(experiment_5_cases);
    eta = (1 - p_A) * (1 - p_B);

    results_experiment_5.experiment_name = 'Experiment 5 - Composite Fiber Channel Ensemble';
    results_experiment_5.reference_state_label = 'psi_plus';
    results_experiment_5.model_name = 'statistical_phase_local_two_arm_depolarization';

    results_experiment_5.p_A = p_A;
    results_experiment_5.p_B = p_B;
    results_experiment_5.eta = eta;

    results_experiment_5.num_cases = num_cases;
    results_experiment_5.cases = cell(1, num_cases);


    % =========================
    % Main loop
    % =========================

    for case_idx = 1:num_cases

        current_case = experiment_5_cases{case_idx};

        required_case_fields = { ...
            'distribution_type', ...
            'num_samples', ...
            'parameters', ...
            'label' ...
        };

        check_required_fields(current_case, required_case_fields, ...
            'run_experiment_5_composite_fiber_channel_ensemble:MissingCaseField');

        distribution_type = char(current_case.distribution_type);
        case_label = char(current_case.label);

        fprintf('\n==========================================\n');
        fprintf('Distribution: %s\n', case_label);
        fprintf('==========================================\n');


        % =========================
        % Sampling
        % =========================

        theta_samples = generate_theta_samples( ...
            distribution_type, ...
            current_case.num_samples, ...
            current_case.parameters{:});

        theta_samples = theta_samples(:).';


        % =========================
        % Ensemble composite state
        % =========================

        rho_accumulator = zeros(4, 4);

        for sample_idx = 1:numel(theta_samples)
            theta_k = theta_samples(sample_idx);

            rho_k = composite_fiber_channel(rho_0, theta_k, p_A, p_B);

            rho_accumulator = rho_accumulator + rho_k;
        end

        rho_ensemble = rho_accumulator / numel(theta_samples);

        rho_ensemble = (rho_ensemble + rho_ensemble') / 2;


        % =========================
        % Reduced states
        % =========================

        rho_A = partial_trace_B(rho_ensemble);
        rho_B = partial_trace_A(rho_ensemble);


        % =========================
        % Observables
        % =========================

        correlation_tensor = compute_correlation_tensor(rho_ensemble);
        correlations = compute_correlations(rho_ensemble);

        purity_global = compute_purity(rho_ensemble);
        purity_A = compute_purity(rho_A);
        purity_B = compute_purity(rho_B);

        fidelity_psi_plus = compute_fidelity(rho_ensemble, psi_plus);
        concurrence = compute_concurrence(rho_ensemble);

        S_max = compute_chsh_max_from_tensor(correlation_tensor);


        % =========================
        % Analytical quantities
        % =========================

        analytics = analytical_values_experiment_5(theta_samples, p_A, p_B, 'ensemble');

        analytical_tensor = analytics.correlation_tensor;

        analytical_c_xx = analytics.c_xx;
        analytical_c_yy = analytics.c_yy;
        analytical_c_zz = analytics.c_zz;

        analytical_purity_global = analytics.purity_global;
        analytical_purity_A = analytics.purity_A;
        analytical_purity_B = analytics.purity_B;

        analytical_fidelity = analytics.fidelity_psi_plus;
        analytical_concurrence = analytics.concurrence;
        analytical_S_max = analytics.S_max;


        % =========================
        % Console monitoring
        % =========================

        fprintf('num_samples            : %d\n', numel(theta_samples));
        fprintf('p_A                    : %.6f\n', p_A);
        fprintf('p_B                    : %.6f\n', p_B);
        fprintf('eta                    : %.6f\n', eta);
        fprintf('|mu|                   : %.6f\n', analytics.mu_abs);

        fprintf('c_xx |err|             : %.3e\n', abs(correlations.c_xx - analytical_c_xx));
        fprintf('c_yy |err|             : %.3e\n', abs(correlations.c_yy - analytical_c_yy));
        fprintf('c_zz |err|             : %.3e\n', abs(correlations.c_zz - analytical_c_zz));

        fprintf('T tensor ||err||_F     : %.3e\n', norm(correlation_tensor - analytical_tensor, 'fro'));

        fprintf('gamma_AB |err|         : %.3e\n', abs(purity_global - analytical_purity_global));
        fprintf('gamma_A |err|          : %.3e\n', abs(purity_A - analytical_purity_A));
        fprintf('gamma_B |err|          : %.3e\n', abs(purity_B - analytical_purity_B));

        fprintf('F_psi+ |err|           : %.3e\n', abs(fidelity_psi_plus - analytical_fidelity));
        fprintf('C |err|                : %.3e\n', abs(concurrence - analytical_concurrence));
        fprintf('S_max |err|            : %.3e\n', abs(S_max - analytical_S_max));


        % =========================
        % Store results
        % =========================

        results_current = struct();

        results_current.case_label = case_label;
        results_current.distribution_type = distribution_type;
        results_current.theta_samples = theta_samples;

        results_current.p_A = p_A;
        results_current.p_B = p_B;
        results_current.eta = eta;

        results_current.rho = rho_ensemble;
        results_current.rho_A = rho_A;
        results_current.rho_B = rho_B;

        results_current.c_xx = correlations.c_xx;
        results_current.c_yy = correlations.c_yy;
        results_current.c_zz = correlations.c_zz;

        results_current.correlation_tensor = correlation_tensor;

        results_current.purity_global = purity_global;
        results_current.purity_A = purity_A;
        results_current.purity_B = purity_B;

        results_current.fidelity_psi_plus = fidelity_psi_plus;
        results_current.concurrence = concurrence;
        results_current.S_max = S_max;

        results_current.sample_mean_cos_theta = analytics.mu_real;
        results_current.sample_mean_sin_theta = analytics.mu_imag;
        results_current.sample_mean_exp_i_theta = analytics.mu;
        results_current.sample_abs_exp_i_theta = analytics.mu_abs;

        results_current.analytical = analytics;

        results_current.analytical.correlation_tensor = analytics.correlation_tensor;
        results_current.analytical.purity_global = analytics.purity_global;
        results_current.analytical.purity_A = analytics.purity_A;
        results_current.analytical.purity_B = analytics.purity_B;
        results_current.analytical.fidelity_psi_plus = analytics.fidelity_psi_plus;
        results_current.analytical.concurrence = analytics.concurrence;

        results_experiment_5.cases{case_idx} = results_current;


        % =========================
        % Plotting
        % =========================

        if do_summary_plot
            plot_composite_ensemble_summary(results_current, do_save);
        end
        
        if do_tensor_plot
            plot_composite_ensemble_tensor_snapshot(results_current, do_save);
        end

    end

end

