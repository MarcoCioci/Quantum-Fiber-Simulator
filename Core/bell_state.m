function psi = bell_state(type)
% BELL_STATE  Generate a Bell state of a two-qubit system.
%
% Objective:
%   Return one of the four maximally entangled Bell states,
%   selected via the input parameter 'type'.
%
%   The states are defined in the computational basis:
%
%       {|00>, |01>, |10>, |11>}
%
% Input:
%   type  - string or char specifying the Bell state:
%           'psi_plus', 'psi_minus', 'phi_plus', 'phi_minus'
%
% Output:
%   psi   - 4x1 complex column vector representing the chosen Bell state
%
% Notes:
%   The output state is normalized by construction.
%   This function is the standard entry point for state preparation
%   in the simulator.

    % =========================
    % Robustness checks
    % =========================

    if nargin ~= 1
        error('bell_state:InvalidNumInputs', ...
            'Expected exactly 1 input argument: type.');
    end

    if ~(ischar(type) || isstring(type))
        error('bell_state:InvalidType', ...
            'type must be a string or character array.');
    end

    type = char(type);  % normalize input

    % =========================
    % Main computation
    % =========================

    switch type

        case 'psi_plus'
            psi = [0; 1; 1; 0];

        case 'psi_minus'
            psi = [0; 1; -1; 0];

        case 'phi_plus'
            psi = [1; 0; 0; 1];

        case 'phi_minus'
            psi = [1; 0; 0; -1];

        otherwise
            error('bell_state:InvalidState', ...
                ['Invalid Bell state type. Use one of: ', ...
                 'psi_plus, psi_minus, phi_plus, phi_minus.']);
    end

    % Normalize explicitly 
    psi = psi / sqrt(2);

    % Force complex type for consistency across simulator
    psi = complex(psi);

end