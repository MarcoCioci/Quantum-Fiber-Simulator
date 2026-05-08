function test_global_depolarizing_channel()
% TEST_GLOBAL_DEPOLARIZING_CHANNEL  Validate the two-qubit depolarizing channel.
%
% Objective:
%   Verify that global_depolarizing_channel correctly implements the
%   effective global depolarizing map introduced in the new channel layer:
%
%       ρ_out = (1 - p) * ρ + (p / 4) * I_4
%
%   The following cases are tested:
%
%       1. Identity limit:
%          for p = 0, the output must equal the input state
%
%       2. Maximally mixed limit:
%          for p = 1, the output must equal I_4 / 4
%
%       3. Hermiticity preservation:
%          the output state must remain Hermitian
%
%       4. Trace preservation:
%          the output state must have trace equal to 1
%
%       5. Analytical agreement:
%          for Bell-state input and intermediate p, the numerical result
%          must match the analytical formula exactly
%
% Input:
%   None
%
% Output:
%   None
%
% Notes:
%   The test raises an error if any expected property is not matched within
%   numerical tolerance. If all checks pass, a success message is printed.

    % =========================
    % Test configuration
    % =========================

    tolerance = 1e-12;

    fprintf('Running test_global_depolarizing_channel...\n');


    % =========================
    % Test setup
    % =========================

    psi_bell = bell_state('psi_plus');
    rho_bell = state_to_density_matrix(psi_bell);


    % =========================
    % Test 1: Identity limit (p = 0)
    % =========================

    rho_p0 = global_depolarizing_channel(rho_bell, 0.0);

    assert(norm(rho_p0 - rho_bell, 'fro') < tolerance, ...
        'test_global_depolarizing_channel:IdentityLimitFailed', ...
        'For p = 0, the output state should equal the input state.');


    % =========================
    % Test 2: Maximally mixed limit (p = 1)
    % =========================

    rho_expected_mixed = eye(4) / 4;
    rho_p1 = global_depolarizing_channel(rho_bell, 1.0);

    assert(norm(rho_p1 - rho_expected_mixed, 'fro') < tolerance, ...
        'test_global_depolarizing_channel:MaximallyMixedLimitFailed', ...
        'For p = 1, the output state should equal I_4 / 4.');


    % =========================
    % Test 3: Hermiticity preservation
    % =========================

    p_test = 0.37;
    rho_test = global_depolarizing_channel(rho_bell, p_test);

    assert(norm(rho_test - rho_test', 'fro') < tolerance, ...
        'test_global_depolarizing_channel:HermiticityFailed', ...
        'The output state should remain Hermitian.');


    % =========================
    % Test 4: Trace preservation
    % =========================

    assert(abs(trace(rho_test) - 1.0) < tolerance, ...
        'test_global_depolarizing_channel:TraceFailed', ...
        'The output state should have trace equal to 1.');


    % =========================
    % Test 5: Analytical agreement
    % =========================

    rho_expected = (1 - p_test) * rho_bell + (p_test / 4) * eye(4);

    assert(norm(rho_test - rho_expected, 'fro') < tolerance, ...
        'test_global_depolarizing_channel:AnalyticalAgreementFailed', ...
        'The numerical output does not match the analytical depolarizing formula.');


    % =========================
    % Success message
    % =========================

    fprintf('test_global_depolarizing_channel passed.\n');

end