function expectation_value_density = expectation_value_density(rho, O)
% EXPECTATION_VALUE_DENSITY  Compute the expectation value of an observable
% for a two-qubit state represented by a density matrix.
%
% Objective:
%   Given a 4x4 density operator rho and a 4x4 observable O, compute the
%   corresponding expectation value using the density-matrix formula
%
%       <O> = Tr(rho * O)
%
%   This function is the density-operator counterpart of the pure-state
%   expectation value function used in Experiment 1.
%
% Input:
%   rho - 4x4 complex density matrix representing a two-qubit quantum state
%         in the computational basis:
%
%         {|00>, |01>, |10>, |11>}
%
%   O   - 4x4 complex matrix representing a two-qubit observable operator
%
% Output:
%   expectation_value_density - scalar expectation value associated with the observable O
%
% Notes:
%   This function is intended for Experiment 2 and later stages of the
%   simulator, where the state may be mixed due to ensemble averaging,
%   decoherence, or noisy-channel effects.
%
%   If rho corresponds to a pure state, i.e.
%
%       rho = |psi><psi|,
%
%   then this formula is equivalent to the standard pure-state expectation
%   value
%
%       <O> = <psi|O|psi>.
%
%   For Hermitian observables and valid density matrices, the expectation
%   value should be real up to numerical roundoff.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 2
        error('expectation_value_density:InvalidNumInputs', ...
              'Expected exactly 2 input arguments: rho and O.');
    end

    if ~isnumeric(rho)
        error('expectation_value_density:InvalidTypeRho', ...
              'rho must be numeric.');
    end

    if ~isnumeric(O)
        error('expectation_value_density:InvalidTypeObservable', ...
              'O must be numeric.');
    end

    if isempty(rho)
        error('expectation_value_density:EmptyRho', ...
              'rho must be non-empty.');
    end

    if isempty(O)
        error('expectation_value_density:EmptyObservable', ...
              'O must be non-empty.');
    end

    if ~isequal(size(rho), [4, 4])
        error('expectation_value_density:InvalidSizeRho', ...
              'rho must be a 4x4 matrix.');
    end

    if ~isequal(size(O), [4, 4])
        error('expectation_value_density:InvalidSizeObservable', ...
              'O must be a 4x4 matrix.');
    end

    if any(~isfinite(rho), 'all')
        error('expectation_value_density:NonFiniteRho', ...
              'rho must contain only finite values.');
    end

    if any(~isfinite(O), 'all')
        error('expectation_value_density:NonFiniteObservable', ...
              'O must contain only finite values.');
    end

    tol = 1e-10;

    if norm(rho - rho', 'fro') > tol
        error('expectation_value_density:NonHermitianRho', ...
              'rho must be Hermitian within numerical tolerance.');
    end

    if abs(trace(rho) - 1) > tol
        error('expectation_value_density:InvalidTraceRho', ...
              'rho must have unit trace within numerical tolerance.');
    end

    if norm(O - O', 'fro') > tol
        error('expectation_value_density:NonHermitianObservable', ...
              'O must be Hermitian within numerical tolerance.');
    end

    rho_eigenvalues = eig(rho);
    if any(real(rho_eigenvalues) < -tol)
        error('expectation_value_density:NonPositiveRho', ...
              'rho must be positive semidefinite within numerical tolerance.');
    end

    if max(abs(imag(rho_eigenvalues))) > tol
        error('expectation_value_density:ComplexEigenvaluesRho', ...
              'rho has eigenvalues with non-negligible imaginary part.');
    end


    % =========================
    % Main computations
    % =========================

    expectation_value_density = trace(rho * O);

    if abs(imag(expectation_value_density)) < tol
        expectation_value_density = real(expectation_value_density);
    else
        error('expectation_value_density:ComplexExpectationValue', ...
              'The expectation value must be real within numerical tolerance.');
    end

end