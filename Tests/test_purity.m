function test_depolarizing_channel_two_qubits()
% TEST_DEPOLARIZING_CHANNEL_TWO_QUBITS  Validate the two-qubit depolarizing channel.
%
% Objective:
%   Verify that depolarizing_channel_two_qubits correctly implements the
%   effective global depolarizing map introduced in Chapter 3.
%
%   The following cases are tested:
%
%       1. Identity limit (p = 0):
%          rho_out = rho
%
%       2. Maximally mixed limit (p = 1):
%          rho_out = I_4 / 4
%
%       3. Trace preservation:
%          Tr(rho_out) = 1
%
%       4. Hermiticity preservation:
%          rho_out = rho_out^dagger
%
%       5. Bell-state analytical behavior:
%          rho(p) = (1 - p) rho_0 + (p/4) I_4
%
% Input:
%   None
%
% Output:
%   None
%
% Notes:
%   The test raises an error if any expected value is not matched within
%   numerical tolerance. If all checks pass, a success message is printed.


    % =========================
    % Test configuration
    % =========================

    tolerance = 1e-12;

    fprintf('Running test_depolarizing_channel_two_qubits...\n');


    % =========================
    % Test 1: Identity limit (p = 0)
    % =========================

    psi_bell = bell_state('psi_plus');
    rho_in = state_to_density_matrix(psi_bell);

    rho_out = depolarizing_channel_two_qubits(rho_in, 0.0);

    assert(norm(rho_out - rho_in, 'fro') < tolerance, ...
        'test_depolarizing_channel:IdentityFailed', ...
        'For p = 0, the output state should equal the input state.');


    % =========================
    % Test 2: Maximally mixed limit (p = 1)
    % =========================

    rho_expected = eye(4) / 4;
    rho_out = depolarizing_channel_two_qubits(rho_in, 1.0);

    assert(norm(rho_out - rho_expected, 'fro') < tolerance, ...
        'test_depolarizing_channel:MaxMixedFailed', ...
        'For p = 1, the output state should be I_4 / 4.');


    % =========================
    % Test 3: Trace preservation
    % =========================

    p_test = 0.37;
    rho_out = depolarizing_channel_two_qubits(rho_in, p_test);

    assert(abs(trace(rho_out) - 1) < tolerance, ...
        'test_depolarizing_channel:TraceFailed', ...
        'The output state must have unit trace.');


    % =========================
    % Test 4: Hermiticity preservation
    % =========================

    assert(norm(rho_out - rho_out', 'fro') < tolerance, ...
        'test_depolarizing_channel:HermiticityFailed', ...
        'The output state must be Hermitian.');


    % =========================
    % Test 5: Bell-state analytical behavior
    % =========================

    rho_expected = (1 - p_test) * rho_in + (p_test / 4) * eye(4);

    assert(norm(rho_out - rho_expected, 'fro') < tolerance, ...
        'test_depolarizing_channel:AnalyticalMismatch', ...
        'The output state does not match the analytical depolarizing formula.');


    % =========================
    % Success message
    % =========================

    fprintf('test_depolarizing_channel_two_qubits passed.\n');

end