# Quantum Fiber Simulator — MATLAB Implementation
This README is a Markdown document that provides an overview of the MATLAB-based Quantum Fiber Simulator, describing its structure, design choices, current implementation stage, and usage, with the aim of making the codebase clear, navigable, and aligned with the accompanying theoretical guide.

## Scope and Positioning

This repository contains the **MATLAB implementation of a two-photon polarization entanglement simulator**, focused on modeling **fiber-induced transformations** and their impact on **correlation observables**.

- The implementation is **code-first**, with a **modular architecture** designed for extensibility.
- The **theoretical formalism** is developed separately in the LaTeX guide: `Text/thesis_guide_20_03_26.pdf`

 

This document should be considered the **formal reference** for notation, derivations, and physical interpretation.

---

## Design Principles

### 1. Separation of Concerns

The simulator is structured into distinct layers:

| Layer        | Role |
|--------------|------|
| `Core/`      | Fundamental quantum operations (state, operators, expectations) |
| `Models/`    | Physical models (e.g., fiber unitary transformations) |
| `Experiments/` | Reproducible simulation scenarios |
| `Utils/`     | Auxiliary utilities (validation, plotting, sampling) |

This separation ensures:
- clarity of responsibilities,
- minimal coupling,
- ease of extension (e.g., adding noise models or metrics).

---

### 2. Explicit Mathematical Mapping

All operations follow a direct mapping:

| Mathematical Object | MATLAB Representation |
|--------------------|----------------------|
| State \(|\psi\rangle\) | `4x1` complex vector |
| Density matrix \(\rho\) | `4x4` complex matrix |
| Operator \(O\) | `4x4` matrix |
| Expectation \(\langle O \rangle\) | scalar via `psi' * O * psi` |

This ensures:
- traceability between code and theory,
- consistency with the thesis formalism.

---

### 3. Progressive Complexity

The implementation follows a **bottom-up strategy**:

1. Pure states
2. Deterministic unitary evolution
3. Correlation observables
4. Ensemble averaging (effective noise)

Mixed-state formalism is already partially supported and will be extended.

---

## Repository Structure

 

Core/
Models/
Experiments/
Utils/

 

### Core Modules

Provide the **minimal quantum toolbox**:

- `bell_state.m`  
  Generates Bell states in computational basis.

- `pauli_matrices.m`  
  Returns \(\sigma_x, \sigma_y, \sigma_z\).

- `apply_unitary.m`  
  Applies \(U_A \otimes U_B\) to a state.

- `expectation_value.m`  
  Computes \(\langle \psi | O | \psi \rangle\).

- `correlation_operator.m`  
  Constructs \( \sigma_i \otimes \sigma_j \).

- `compute_correlations.m`  
  Evaluates:
  - \( \langle \sigma_x \otimes \sigma_x \rangle \)
  - \( \langle \sigma_y \otimes \sigma_y \rangle \)
  - \( \langle \sigma_z \otimes \sigma_z \rangle \)

- Density-based counterparts:
  - `state_to_density_matrix.m`
  - `expectation_value_density.m`
  - `compute_correlations_density.m`

These enable a **smooth transition to mixed-state simulations**.

---

### Models

- `phase_unitary.m`

Implements the **minimal fiber model**:

- Single-qubit unitary:
  
  \[
  U(\theta) = \begin{pmatrix} 1 & 0 \\ 0 & e^{i\theta} \end{pmatrix}
  \]

- Used to model **relative phase accumulation due to birefringence**.

This corresponds to the **controlled simplification** described in the thesis:
fiber → residual rotation around Z axis.

---

### Experiments

#### Experiment 1 — Phase Baseline

 

Experiment_1_Phase_Baseline/

 

Objective:
- Validate analytical predictions for a **pure phase model**.

Pipeline:
1. Generate Bell state
2. Apply phase unitary
3. Sweep \(\theta\)
4. Compute correlations
5. Compare with theory

Outputs:
- `Images/Experiment_1/`
  - correlation trends
  - theory vs simulation comparison

---

#### Experiment 2 — Random Phase Noise

 

Experiment_2_Random_Phase_Noise/

 

Objective:
- Model **ensemble of random phase realizations**.

Key idea:
- Fiber ≈ random unitary → effective decoherence after averaging

Components:
- `random_phase_ensemble_state.m`  
  Generates averaged state over sampled \(\theta\)

- `generate_theta_samples.m` (Utils)  
  Supports:
  - uniform
  - normal
  - constant distributions

Outputs:
- `Images/Experiment_2/`
  - comparison across distributions

---

### Utils

- `tensor_product.m`  
  Wrapper around Kronecker product for clarity.

- `is_unitary.m`, `is_normalized.m`  
  Validation utilities.

- `plot_correlations.m`  
  Flexible plotting of selected observables.

- `generate_theta_samples.m`  
  Sampling engine for stochastic models.

---

## Execution Workflow

Main entry point:

main.m

At the current stage of development, `main.m` is responsible for orchestrating
the execution of both implemented experiments:

- Experiment 1 — Phase Baseline Sweep
- Experiment 2 — Random Phase Ensemble Analysis

Specifically, it:

1. Initializes the environment and adds all subfolders to the MATLAB path
2. Executes the deterministic phase sweep (Experiment 1)
3. Iterates over multiple random-phase configurations (Experiment 2),
   including:
   - constant phase
   - uniform distribution
   - gaussian distribution
4. Collects results and triggers associated plotting routines

Typical workflow:

1. Define initial state (internally handled by experiment scripts)
2. Select physical model (phase unitary)
3. Run experiments via `main.m`
4. Analyze generated plots and outputs

Experiments are **self-contained and reproducible**, while `main.m`
acts as the centralized driver for batch execution and comparative analysis.

---

## Coding Standards

All functions follow a consistent structure defined in:

- `Extra/code_format.txt`

Key features:
- explicit input/output specification,
- robustness checks,
- clear separation:
  - validation
  - computation

This ensures:
- readability,
- maintainability,
- uniform interface across modules.

---

## Current Capabilities

### Implemented

- Bell state generation
- Local unitary evolution
- Phase-based fiber model
- Correlation observables:
  - \( \sigma_x \otimes \sigma_x \)
  - \( \sigma_y \otimes \sigma_y \)
  - \( \sigma_z \otimes \sigma_z \)
- Ensemble averaging (phase noise)
- Density matrix support (partial)

---

### Not Yet Implemented

Planned extensions (aligned with thesis):

- General unitary fiber model (random axes)
- Partial trace and reduced density matrices
- Stokes parameters (single-arm characterization)
- Entanglement metrics:
  - concurrence
  - entropy
- Bell inequality (CHSH parameter)
- Frequency-dependent effects (PMD-inspired models)

---

## Design Rationale

### Why Phase-Only Model First

The fiber is reduced to:

- dominant residual effect after alignment,
- physically meaningful,
- analytically tractable,
- ideal for validating the simulator.

This provides a **controlled baseline** before introducing complexity.

---

### Why Correlation-Centric Approach

The simulator focuses on:

- measurable quantities,
- direct experimental relevance,
- compatibility with measurement via waveplates + fixed basis detectors.

---

### Why Modular Expansion Strategy

Future features (noise, metrics, PMD) can be added without modifying:

- `Core/` (stable layer),
- experiment interfaces.

This avoids refactoring and preserves reproducibility.

---

## Relation to Thesis

The simulator implements the pipeline:

 

Source → Channel → Measurement

 

as formalized in thesis guide.

 

Specifically:

- `Core/` ↔ Hilbert space formalism
- `Models/` ↔ physical channel modeling
- `Experiments/` ↔ observable extraction

The code is intended to **validate and complement** the theoretical and practical laboratory development.

---

## Summary

This repository provides an **initial implementation stage** of a simulator for entangled photon propagation in optical fibers.

At the current stage, it offers:

- a **controlled baseline model**, focused on phase-induced transformations,
- a **modular architecture** designed to support progressive extensions,
- a **validated starting point** for studying correlation observables under simple unitary evolution,
- a **structured foundation** for future inclusion of more realistic effects (noise, decoherence, experimental metrics).

The present implementation is intentionally limited in terms of **optimization and performance**, while maintaining a **complete and consistent modeling scope** for the current development stage.

The priority is placed on:
- clarity of the physical-to-mathematical mapping,
- correctness and transparency of the core simulation pipeline,
- consistency with the theoretical framework developed in the accompanying thesis.