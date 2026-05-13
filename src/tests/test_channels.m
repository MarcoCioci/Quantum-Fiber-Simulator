function test_channels()
% TEST_CHANNELS  Validate the depolarizing-channel implementations.
%
% Objective:
%   Validate the correctness of the quantum-channel routines:
%
%       1. global_depolarizing_channel
%       2. local_depolarizing_channel
%       3. two_arm_depolarizing_channel
%
%   The tests verify:
%
%       - identity limits
%       - complete depolarization limits
%       - Hermiticity preservation
%       - trace preservation (for density matrices)
%       - analytical agreement
%       - tensor-contraction behavior
%       - distinction between global and local depolarization
%
% Input:
%   None
%
% Output:
%   None
%
% Notes:
%   The test raises an error if any expected property is violated within
%   numerical tolerance.

    % =====================================================
    % Test configuration
    % =====================================================

    tolerance = 1e-12;

    % =====================================================
    % Common test setup
    % =====================================================

    psi_bell = bell_state('psi_plus');
    rho_bell = state_to_density_matrix(psi_bell);

    I2 = eye(2);
    I4 = eye(4);

    fprintf('Running test_channels...\n');

    % =====================================================
    % SECTION 1 — GLOBAL DEPOLARIZING CHANNEL
    % =====================================================

    % -----------------------------------------------------
    % Test 1.1 — Identity limit
    % -----------------------------------------------------

    rho_p0 = global_depolarizing_channel(rho_bell, 0.0);

    assert(norm(rho_p0 - rho_bell, 'fro') < tolerance, ...
        'test_channels:GlobalIdentityLimitFailed', ...
        'Global channel failed identity limit test.');


    % -----------------------------------------------------
    % Test 1.2 — Maximally mixed limit
    % -----------------------------------------------------

    rho_expected_mixed = I4 / 4;

    rho_p1 = global_depolarizing_channel(rho_bell, 1.0);

    assert(norm(rho_p1 - rho_expected_mixed, 'fro') < tolerance, ...
        'test_channels:GlobalMaximallyMixedLimitFailed', ...
        'Global channel failed maximally mixed limit test.');


    % -----------------------------------------------------
    % Test 1.3 — Hermiticity preservation
    % -----------------------------------------------------

    p_test = 0.37;

    rho_test = global_depolarizing_channel(rho_bell, p_test);

    assert(norm(rho_test - rho_test', 'fro') < tolerance, ...
        'test_channels:GlobalHermiticityFailed', ...
        'Global channel does not preserve Hermiticity.');


    % -----------------------------------------------------
    % Test 1.4 — Trace preservation
    % -----------------------------------------------------

    assert(abs(trace(rho_test) - 1.0) < tolerance, ...
        'test_channels:GlobalTraceFailed', ...
        'Global channel does not preserve trace.');


    % -----------------------------------------------------
    % Test 1.5 — Analytical agreement
    % -----------------------------------------------------

    rho_expected = (1 - p_test) * rho_bell ...
                 + (p_test / 4) * I4;

    assert(norm(rho_test - rho_expected, 'fro') < tolerance, ...
        'test_channels:GlobalAnalyticalAgreementFailed', ...
        'Global depolarization analytical agreement failed.');


    % =====================================================
    % SECTION 2 — LOCAL SINGLE-QUBIT CHANNEL
    % =====================================================

    % -----------------------------------------------------
    % Test 2.1 — Identity limit
    % -----------------------------------------------------

    rho0 = [1 0; 0 0];

    rho_local_p0 = local_depolarizing_channel(rho0, 0.0);

    assert(norm(rho_local_p0 - rho0, 'fro') < tolerance, ...
        'test_channels:LocalIdentityLimitFailed', ...
        'Local channel failed identity limit test.');


    % -----------------------------------------------------
    % Test 2.2 — Complete depolarization limit
    % -----------------------------------------------------

    rho_local_p1 = local_depolarizing_channel(rho0, 1.0);

    assert(norm(rho_local_p1 - I2/2, 'fro') < tolerance, ...
        'test_channels:LocalCompleteDepolarizationFailed', ...
        'Local channel failed complete depolarization test.');


    % -----------------------------------------------------
    % Test 2.3 — Pauli contraction
    % -----------------------------------------------------

    [sigma_x, ~, ~] = pauli_matrices();

    p_local = 0.23;

    sigma_x_out = local_depolarizing_channel(sigma_x, p_local);

    sigma_x_expected = (1 - p_local) * sigma_x;

    assert(norm(sigma_x_out - sigma_x_expected, 'fro') < tolerance, ...
        'test_channels:LocalPauliContractionFailed', ...
        'Local channel failed Pauli contraction test.');


    % =====================================================
    % SECTION 3 — TWO-ARM DEPOLARIZING CHANNEL
    % =====================================================

    % -----------------------------------------------------
    % Test 3.1 — Identity limit
    % -----------------------------------------------------

    rho_twoarm_p0 = two_arm_depolarizing_channel(rho_bell, 0.0, 0.0);

    assert(norm(rho_twoarm_p0 - rho_bell, 'fro') < tolerance, ...
        'test_channels:TwoArmIdentityLimitFailed', ...
        'Two-arm channel failed identity limit test.');


    % -----------------------------------------------------
    % Test 3.2 — Complete depolarization limit
    % -----------------------------------------------------

    rho_twoarm_p1 = two_arm_depolarizing_channel(rho_bell, 1.0, 1.0);

    assert(norm(rho_twoarm_p1 - I4/4, 'fro') < tolerance, ...
        'test_channels:TwoArmCompleteDepolarizationFailed', ...
        'Two-arm channel failed complete depolarization test.');


    % -----------------------------------------------------
    % Test 3.3 — Hermiticity preservation
    % -----------------------------------------------------

    p_A = 0.21;
    p_B = 0.44;

    rho_twoarm = two_arm_depolarizing_channel(rho_bell, p_A, p_B);

    assert(norm(rho_twoarm - rho_twoarm', 'fro') < tolerance, ...
        'test_channels:TwoArmHermiticityFailed', ...
        'Two-arm channel does not preserve Hermiticity.');


    % -----------------------------------------------------
    % Test 3.4 — Trace preservation
    % -----------------------------------------------------

    assert(abs(trace(rho_twoarm) - 1.0) < tolerance, ...
        'test_channels:TwoArmTraceFailed', ...
        'Two-arm channel does not preserve trace.');


    % -----------------------------------------------------
    % Test 3.5 — Correlation-tensor contraction
    % -----------------------------------------------------

    T_in  = compute_correlation_tensor(rho_bell);
    T_out = compute_correlation_tensor(rho_twoarm);

    eta = (1 - p_A) * (1 - p_B);

    T_expected = eta * T_in;

    assert(norm(T_out - T_expected, 'fro') < tolerance, ...
        'test_channels:TwoArmTensorContractionFailed', ...
        'Two-arm tensor contraction law failed.');


    % -----------------------------------------------------
    % Test 3.6 — Distinction from global depolarization
    % -----------------------------------------------------

    p_compare = 0.4;

    rho_global = global_depolarizing_channel(rho_bell, p_compare);

    rho_local  = two_arm_depolarizing_channel( ...
                    rho_bell, ...
                    p_compare, ...
                    p_compare);

    assert(norm(rho_global - rho_local, 'fro') > tolerance, ...
        'test_channels:GlobalLocalDistinctionFailed', ...
        'Global and local depolarization should not be identical.');

    % =====================================================
    % Final success message
    % =====================================================

    fprintf('test_channels passed.\n');

end