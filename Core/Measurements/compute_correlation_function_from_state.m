function E_ab = compute_correlation_function_from_state(state, a, b)
% COMPUTE_CORRELATION_FUNCTION_FROM_STATE Compute two-qubit correlation along arbitrary local axes.
%
% Objective:
%   Compute the arbitrary-axis two-qubit correlation function
%
%       E(a,b) = ⟨ σ(a) ⊗ σ(b) ⟩
%
%   for a bipartite quantum state represented either as a pure state vector
%   or as a density matrix.
%
% Input:
%   state - quantum state of the two-qubit system. Accepted formats:
%
%             4x1 complex vector      pure state ket |ψ⟩
%             4x4 complex matrix      density matrix ρ_AB
%
%   a     - real numeric vector with 3 components representing the local
%           measurement direction on subsystem A.
%
%   b     - real numeric vector with 3 components representing the local
%           measurement direction on subsystem B.
%
% Output:
%   E_ab  - real scalar correlation value associated with
%
%              σ(a) ⊗ σ(b)
%
% Notes:
%   This function implements the operational correlation quantity introduced
%   in Section 3.6:
%
%       E(a,b) = Tr[ρ_AB * (σ(a) ⊗ σ(b))]
%
%   If the input state is a pure vector, it is internally converted to the
%   corresponding density matrix before evaluating the expectation value.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 3
        error('compute_correlation_function_from_state:InvalidNumInputs', ...
              'Expected exactly 3 input arguments.');
    end

    if ~isnumeric(state)
        error('compute_correlation_function_from_state:InvalidStateType', ...
              'state must be numeric.');
    end

    if ~(isvector(state) || ismatrix(state))
        error('compute_correlation_function_from_state:InvalidStateShape', ...
              'state must be either a state vector or a density matrix.');
    end

    if isvector(state)
        if ~isequal(size(state), [4, 1])
            error('compute_correlation_function_from_state:InvalidStateVectorShape', ...
                  'Pure state input must be a 4x1 ket vector. Row vectors are not accepted.');
        end

        normalization_tolerance = 1e-12;

        if abs(norm(state) - 1) > normalization_tolerance
            error('compute_correlation_function_from_state:StateNotNormalized', ...
                  'Pure state input must be normalized.');
        end

    elseif ismatrix(state)
        if ~isequal(size(state), [4, 4])
            error('compute_correlation_function_from_state:InvalidDensityMatrixSize', ...
                  'Density matrix input must be 4x4.');
        end

        hermiticity_tolerance = 1e-12;

        if norm(state - state', 'fro') > hermiticity_tolerance
            error('compute_correlation_function_from_state:DensityMatrixNotHermitian', ...
                  'Density matrix input must be Hermitian.');
        end

        if abs(trace(state) - 1) > hermiticity_tolerance
            error('compute_correlation_function_from_state:DensityMatrixTraceInvalid', ...
                  'Density matrix input must have trace equal to 1.');
        end
    end

    if ~isnumeric(a)
        error('compute_correlation_function_from_state:InvalidTypeA', ...
              'a must be a numeric vector.');
    end

    if ~isnumeric(b)
        error('compute_correlation_function_from_state:InvalidTypeB', ...
              'b must be a numeric vector.');
    end

    if ~isreal(a)
        error('compute_correlation_function_from_state:InvalidComplexInputA', ...
              'a must be real.');
    end

    if ~isreal(b)
        error('compute_correlation_function_from_state:InvalidComplexInputB', ...
              'b must be real.');
    end

    if ~isvector(a)
        error('compute_correlation_function_from_state:InvalidShapeA', ...
              'a must be a vector with 3 components.');
    end

    if ~isvector(b)
        error('compute_correlation_function_from_state:InvalidShapeB', ...
              'b must be a vector with 3 components.');
    end

    if numel(a) ~= 3
        error('compute_correlation_function_from_state:InvalidSizeA', ...
              'a must contain exactly 3 components.');
    end

    if numel(b) ~= 3
        error('compute_correlation_function_from_state:InvalidSizeB', ...
              'b must contain exactly 3 components.');
    end


    % =========================
    % Main computation
    % =========================

    if isequal(size(state), [4,1])
        rho_AB = state_to_density_matrix(state);
    else
        rho_AB = state;
    end

    O_ab = local_correlation_operator(a, b);

    E_ab = expectation_value(rho_AB, O_ab);

    realness_tolerance = 1e-10;
    if abs(imag(E_ab)) > realness_tolerance
        error('compute_correlation_function_from_state:NotReal', ...
              'E_ab must be real-valued.');
    end

    E_ab = real(E_ab); % Numerical clean up

    range_tolerance = 1e-10;
    if abs((E_ab)) > 1 + range_tolerance
        error('compute_correlation_from_state:OutOfRange', ...
              'E_ab must be real-valued.');
    end

end