function test_arbitrary_axis_correlations()
% TEST_ARBITRARY_AXIS_CORRELATIONS  Validate arbitrary-axis correlation routines.
%
% Objective:
%   Test the implementation of arbitrary local measurement axes by checking:
%
%       1) axis-based Pauli operators
%       2) local two-qubit correlation operators
%       3) arbitrary-axis correlation values
%       4) consistency with the correlation tensor shortcut
%
% Notes:
%   These tests validate the numerical implementation of Section 3.6 and
%   ensure consistency with the previous aligned-Pauli correlation routines.

    disp('Running test_arbitrary_axis_correlations...');

    % =========================
    % Test parameters
    % =========================

    tolerance = 1e-10;

    x_axis = [1; 0; 0];
    y_axis = [0; 1; 0];
    z_axis = [0; 0; 1];


    % =========================
    % Test 1: single-axis Pauli operators
    % =========================

    [sigma_x, sigma_y, sigma_z] = pauli_matrices();

    sigma_x_axis = measurement_operator_axis(x_axis);
    sigma_y_axis = measurement_operator_axis(y_axis);
    sigma_z_axis = measurement_operator_axis(z_axis);

    assert(norm(sigma_x_axis - sigma_x, 'fro') < tolerance, ...
           'measurement_operator_axis failed for x-axis.');

    assert(norm(sigma_y_axis - sigma_y, 'fro') < tolerance, ...
           'measurement_operator_axis failed for y-axis.');

    assert(norm(sigma_z_axis - sigma_z, 'fro') < tolerance, ...
           'measurement_operator_axis failed for z-axis.');


    % =========================
    % Test 2: two-qubit local correlation operators
    % =========================

    O_xx = local_correlation_operator(x_axis, x_axis);
    O_yy = local_correlation_operator(y_axis, y_axis);
    O_zz = local_correlation_operator(z_axis, z_axis);

    O_xx_expected = tensor_product(sigma_x, sigma_x);
    O_yy_expected = tensor_product(sigma_y, sigma_y);
    O_zz_expected = tensor_product(sigma_z, sigma_z);

    assert(norm(O_xx - O_xx_expected, 'fro') < tolerance, ...
           'local_correlation_operator failed for x-x axes.');

    assert(norm(O_yy - O_yy_expected, 'fro') < tolerance, ...
           'local_correlation_operator failed for y-y axes.');

    assert(norm(O_zz - O_zz_expected, 'fro') < tolerance, ...
           'local_correlation_operator failed for z-z axes.');


    % =========================
    % Test 3: aligned correlations for Bell state |Psi+>
    % =========================

    psi_plus = bell_state('psi_plus');

    E_xx = compute_correlation_function_from_state(psi_plus, x_axis, x_axis);
    E_yy = compute_correlation_function_from_state(psi_plus, y_axis, y_axis);
    E_zz = compute_correlation_function_from_state(psi_plus, z_axis, z_axis);

    assert(abs(E_xx - 1) < tolerance, ...
           'compute_correlation_function_from_state failed for E_xx of |Psi+>.');

    assert(abs(E_yy - 1) < tolerance, ...
           'compute_correlation_function_from_state failed for E_yy of |Psi+>.');

    assert(abs(E_zz + 1) < tolerance, ...
           'compute_correlation_function_from_state failed for E_zz of |Psi+>.');


    % =========================
    % Test 4: arbitrary axes direct computation
    % =========================

    a = [1; 1; 0];
    a = a / norm(a);

    b = [0; 1; 1];
    b = b / norm(b);

    E_direct = compute_correlation_function_from_state(psi_plus, a, b);

    T = compute_correlation_tensor(psi_plus);
    E_tensor = compute_correlation_function_from_tensor(T, a, b);

    assert(abs(E_direct - E_tensor) < tolerance, ...
           'Direct arbitrary-axis correlation and tensor shortcut do not agree.');


    % =========================
    % Test 5: density-matrix input consistency
    % =========================

    rho_plus = state_to_density_matrix(psi_plus);

    E_vector = compute_correlation_function_from_state(psi_plus, a, b);
    E_density = compute_correlation_function_from_state(rho_plus, a, b);

    assert(abs(E_vector - E_density) < tolerance, ...
           'Vector-input and density-matrix-input arbitrary-axis correlations do not agree.');


    % =========================
    % Test 6: phase-evolved Bell state analytical check
    % =========================

    theta = pi / 4;

    psi_theta = ( ...
        computational_basis('01') + ...
        exp(1i * theta) * computational_basis('10') ...
    ) / sqrt(2);

    E_xx_theta = compute_correlation_function_from_state(psi_theta, x_axis, x_axis);
    E_yy_theta = compute_correlation_function_from_state(psi_theta, y_axis, y_axis);
    E_zz_theta = compute_correlation_function_from_state(psi_theta, z_axis, z_axis);

    assert(abs(E_xx_theta - cos(theta)) < tolerance, ...
           'Phase-evolved Bell state failed for E_xx.');

    assert(abs(E_yy_theta - cos(theta)) < tolerance, ...
           'Phase-evolved Bell state failed for E_yy.');

    assert(abs(E_zz_theta + 1) < tolerance, ...
           'Phase-evolved Bell state failed for E_zz.');


    % =========================
    % Test 7: equatorial analytical formula
    % =========================

    alpha = pi / 6;
    beta  = pi / 3;

    a_eq = [cos(alpha); sin(alpha); 0];
    b_eq = [cos(beta);  sin(beta);  0];

    E_eq = compute_correlation_function_from_state(psi_theta, a_eq, b_eq);

    E_eq_expected = cos(theta + beta - alpha);

    assert(abs(E_eq - E_eq_expected) < tolerance, ...
           'Equatorial arbitrary-axis formula failed.');


    disp('test_arbitrary_axis_correlations passed.');

end