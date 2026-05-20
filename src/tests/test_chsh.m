function test_chsh()
% TEST_CHSH  Validate CHSH routines for fixed-axis and maximal violation.
%
% Objective:
%   Verify that the CHSH implementation correctly evaluates:
%
%       1. Fixed-axis CHSH values from state and tensor representations
%       2. Maximal CHSH value from the correlation tensor
%       3. Analytical behavior for Bell states
%       4. Analytical behavior under fixed-phase evolution
%       5. Analytical behavior under two-qubit depolarization
%       6. Vanishing CHSH value for the maximally mixed state
%
% Input:
%   None
%
% Output:
%   None
%

    % =========================
    % Test configuration
    % =========================

    tolerance = 1e-10;

    fprintf('Running test_chsh...\n');


    % =========================
    % Test setup
    % =========================

    psi_plus = bell_state('psi_plus');
    rho_plus = state_to_density_matrix(psi_plus);

    x_axis = [1; 0; 0];
    y_axis = [0; 1; 0];

    % Optimal fixed CHSH axes for T = diag(1, 1, -1)
    a1 = x_axis;
    a2 = y_axis;
    b1 = (x_axis + y_axis) / sqrt(2);
    b2 = (x_axis - y_axis) / sqrt(2);


    % =========================
    % Test 1: State-based and tensor-based CHSH consistency
    % =========================

    T_plus = compute_correlation_tensor(rho_plus);

    S_from_state = compute_chsh_from_state(rho_plus, a1, a2, b1, b2);
    S_from_tensor = compute_chsh_from_tensor(T_plus, a1, a2, b1, b2);

    assert(abs(S_from_state - S_from_tensor) < tolerance, ...
        'test_chsh:StateTensorCHSHMismatch', ...
        'CHSH computed from state and tensor should agree.');


    % =========================
    % Test 2: Maximal CHSH value for Bell state
    % =========================

    S_max_plus = compute_chsh_max_from_tensor(T_plus);
    S_max_expected = 2 * sqrt(2);

    assert(abs(S_max_plus - S_max_expected) < tolerance, ...
        'test_chsh:BellStateMaxCHSHFailed', ...
        'For a Bell state, S_max should be equal to 2 * sqrt(2).');


    % =========================
    % Test 3: Fixed-axis CHSH reaches Tsirelson bound for selected axes
    % =========================

    S_expected = 2 * sqrt(2);

    assert(abs(S_from_tensor - S_expected) < tolerance, ...
        'test_chsh:FixedAxisTsirelsonFailed', ...
        'For the selected optimal axes, fixed-axis CHSH should reach 2 * sqrt(2).');


    % =========================
    % Test 4: Phase-evolved Bell state preserves maximal CHSH value
    % =========================

    theta_values = linspace(0, 2*pi, 9);

    for k = 1:numel(theta_values)
        theta = theta_values(k);

        U_A = eye(2);
        U_B = phase_unitary(theta);

        psi_theta = apply_unitary(U_A, U_B, psi_plus);
        rho_theta = state_to_density_matrix(psi_theta);

        T_theta = compute_correlation_tensor(rho_theta);
        S_max_theta = compute_chsh_max_from_tensor(T_theta);

        assert(abs(S_max_theta - S_max_expected) < tolerance, ...
            'test_chsh:PhaseSweepMaxCHSHFailed', ...
            'Phase-evolved Bell states should preserve S_max = 2 * sqrt(2).');
    end


    % =========================
    % Test 5: Depolarizing channel analytical agreement
    % =========================

    p_values = [0.0, 0.1, 0.25, 0.5, 1.0];

    for k = 1:numel(p_values)
        p = p_values(k);

        rho_dep = global_depolarizing_channel(rho_plus, p);
        T_dep = compute_correlation_tensor(rho_dep);

        S_max_dep = compute_chsh_max_from_tensor(T_dep);
        S_max_dep_expected = 2 * sqrt(2) * (1 - p);

        assert(abs(S_max_dep - S_max_dep_expected) < tolerance, ...
            'test_chsh:DepolarizingMaxCHSHFailed', ...
            'For depolarized Bell states, S_max should equal 2 * sqrt(2) * (1 - p).');
    end


    % =========================
    % Test 6: Maximally mixed state gives zero maximal CHSH value
    % =========================

    rho_mixed = eye(4) / 4;
    T_mixed = compute_correlation_tensor(rho_mixed);

    S_max_mixed = compute_chsh_max_from_tensor(T_mixed);

    assert(abs(S_max_mixed) < tolerance, ...
        'test_chsh:MaximallyMixedCHSHFailed', ...
        'For the maximally mixed state, S_max should be zero.');


    % =========================
    % Test 7: Fixed-axis CHSH remains inside algebraic bound
    % =========================

    S_test = compute_chsh_from_tensor(T_plus, x_axis, y_axis, x_axis, y_axis);

    assert(abs(S_test) <= 4 + tolerance, ...
        'test_chsh:AlgebraicBoundFailed', ...
        'Fixed-axis CHSH should satisfy the algebraic bound |S| <= 4.');


    % =========================
    % Success message
    % =========================

    fprintf('test_chsh passed.\n');

end