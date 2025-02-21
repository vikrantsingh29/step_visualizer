# Step Visualizer

A Flutter project to visualize raw sensor data and predict step counts for the left and right foot. Step predictions are generated using a combination of signal processing (Butterworth low-pass filtering and SciPy peak detection) and machine learning models.

## Overview

- **Prediction Models:**
  - **Sequential Models (Time-Series):**
    - **UnifiedCountLSTM:** 2-layer LSTM with dropout and ReLU.
    - **SimpleLSTM:** Single-layer LSTM for simplicity.
    - **CNN-LSTM:** 1D CNN (with max pooling) + LSTM to capture local and temporal features.
    - **UnifiedCountGRU:** GRU-based model with faster convergence.
  - **Aggregated-Feature Models:**
    - **Random Forest Regressor**
    - **XGBoost Regressor**

- **Comparison:**  
  Learning curves and MSE for the sequential models (displayed in a 2×2 grid) and error metrics (MAE) for the aggregated models were used to select the best approach.

- **Data Processing:**  
  Raw data is preprocessed by standardizing timestamps, filtering the acceleration magnitude using a Butterworth low-pass filter, and extracting key features. Peak detection on the filtered signal yields surrogate step labels for training.

## How to Run

1. Clean and fetch Flutter dependencies:
    ```bash
    flutter clean
    flutter pub get
    ```
2. Run the project on Chrome:
    ```bash
    flutter chrome -d run
    ```

For detailed code, see [stepcount.ipynb](https://github.com/vikrantsingh29/step_visualizer/blob/master/stepcount.ipynb) and for full documentation, refer to [StepCountEversion.pdf](https://github.com/vikrantsingh29/step_visualizer/blob/master/StepCountEversion.pdf).
