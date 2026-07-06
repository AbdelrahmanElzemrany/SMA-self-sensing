
# Real-Time-Self-Sensing-SMA-Bending-Wire

An end-to-end multi-rate calibration framework and closed-loop thermal observer for Shape Memory Alloy (SMA) bending wire actuators, built using MATLAB and Simulink.

## 📝 Project Overview

Highly sensitive Shape Memory Alloy (SMA) actuators undergo material phase transitions that change their shape based on temperature. To control these actuators precisely, you need real-time temperature feedback. 

However, standard physical thermocouples suffer from an inherent **230ms response delay**. This massive latency introduces severe measurement lag, creating huge errors that critically degrade control over key physical outputs like curvature, strain, and angular position. 

This project solves this problem by bypassing physical thermocouples entirely during active control. It establishes a real-time **self-sensing methodology** that utilizes a fast current sensor (**1ms response time**). By continuously monitoring the dynamic electrical resistance changes that occur across the material's phases on the fly, the system calculates the active martensite volume fraction and estimates wire temperature in real time. 

## 🛠️ Pipeline & File Architecture

The repository is structured sequentially to move from raw multi-rate data to robust closed-loop tracking:

### 1. Multi-Rate Data Collection
* **`Step_1_Observer_Calibration_Experiment.slx`**: Runs the uncalibrated observer model under zero external load to generate high-frequency 1ms electrical readings against sparse 230ms thermocouple benchmarks.

### 2. Hysteresis Characterization
* **`Step_3_FORC_Extraction_Model.slx`**: Executes tracking challenges to generate multi-loop reversal data across deliberate temperature calculation offsets and mechanical loads.
* **`Step_4_FORC_Initialization.m`**: Builds the primary material trajectory constraints and initializes baseline tracking limits.
* **`Step_4_FORC_Visualization.m`**: Plots First-Order Reversal Curves (FORC) to expose data gaps and evaluate structural hysteresis behavior.

### 3. Feedforward Control & Verification
* **`Step_5_FeedForward_LUTs_Extraction.m`**: Extracts trajectory Look-Up Tables (LUTs) by matching input voltage and convection cooling configurations against eliminated tracking errors.
* **`Step_6_Robustness_Analysis.slx`**: The final closed-loop controller testing framework evaluating system resilience across variable loads and supply voltage levels (2V, 4.5V, and 6V).

### 4. Calibration & Dataset Assets
* Contains the core mathematical data arrays (`alpha_values.mat`, `beta_values.mat`, `valid_idx.mat`) along with mapped structural matrix boundaries (`forc_matrix.mat`, `raw_forc_data.mat`, `sma_pure_1d_switching.mat`) to initialize the observer.

---

## ⚠️ Thermal Observer Tracking Constraints Note

To prevent severe actuation errors under rapid temperature transitions, the thermal observer should be calibrated directly at the specific voltage level required for execution. Operating too far from the initial low-voltage calibration threshold incrementally increases steady-state tracking offsets along the cooling paths.
