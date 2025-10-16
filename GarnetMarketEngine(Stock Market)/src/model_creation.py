# Importing Libraries
import numpy as np
import pandas as pd
import tensorflow as tf
import os
from tensorflow.keras.callbacks import ModelCheckpoint
import matplotlib.pyplot as plt
from keras.models import load_model
from datetime import datetime, date
from pytz import timezone
from sklearn.preprocessing import MinMaxScaler
from sklearn.model_selection import train_test_split
from tqdm import tqdm
from tensorflow.keras.models import Sequential
from tensorflow.keras.layers import Conv1D, MaxPooling1D, LSTM, Dense, Flatten
from sklearn.metrics import mean_squared_error
from tensorflow.keras.models import save_model
import json
import yfinance as yf


def main():
    tizone = r"Asia/Kolkata"
    print(f"\x1b[1;36mGetting Timezone ... {tizone}\x1b[0m")
    ist = timezone(tizone)

    print(f"\x1b[1;36mGetting Dates\x1b[0m\n")
    start_date = datetime(2018, 1, 1)
    end_date = datetime.now()
    start_timestamp = int(round(datetime.timestamp(start_date), 0))
    end_timestamp = int(round(datetime.timestamp(end_date), 0))
    print(
        f'\x1b[1;36mStart Date        \x1b[1;32m{start_date.strftime("%Y-%b-%d")}\x1b[0m'
    )
    print(
        f'\x1b[1;36mEnd Date          \x1b[1;32m{end_date.strftime("%Y-%b-%d")}\x1b[0m\n'
    )

    print(f"\x1b[1;36mStarting Yahoo Instance\x1b[0m\n")

    df_nifty50 = yf.download("^NSEI", start=start_date, end=end_date)
    df_niftybank = yf.download("^NSEBANK", start=start_date, end=end_date)
    df_niftyfin = yf.download("NIFTY_FIN_SERVICE.NS", start=start_date, end=end_date)
    df_reliance = yf.download("RELIANCE.NS", start=start_date, end=end_date)

    print(f"\x1b[1;32mNifty 50\x1b[0m")
    print(f"\x1b[1;32mNifty Bank\x1b[0m")
    print(f"\x1b[1;32mNifty Financial Services\x1b[0m")
    print(f"\x1b[1;32mReliance\x1b[0m\n")

    print(f"\n\x1b[1;36mCleaning the Data\x1b[0m\n")

    df_nifty50 = df_nifty50.reset_index()
    df_niftybank = df_niftybank.reset_index()
    df_niftyfin = df_niftyfin.reset_index()
    df_reliance = df_reliance.reset_index()

    df_nifty50.columns = df_nifty50.columns.get_level_values(0)
    df_niftybank.columns = df_niftybank.columns.get_level_values(0)
    df_niftyfin.columns = df_niftyfin.columns.get_level_values(0)
    df_reliance.columns = df_reliance.columns.get_level_values(0)

    # Remove Missing Values

    df_nifty50.dropna(inplace=True)
    df_niftybank.dropna(inplace=True)
    df_niftyfin.dropna(inplace=True)
    df_reliance.dropna(inplace=True)

    print(f"\x1b[1;32mRemoved missing values\x1b[0m")

    # Round data to 2 decimal places

    df_nifty50 = df_nifty50.round(2)
    df_niftybank = df_niftybank.round(2)
    df_niftyfin = df_niftyfin.round(2)
    df_reliance = df_reliance.round(2)

    print(f"\x1b[1;32mRounded the data to 2 decimal place\x1b[0m")

    # Removing Extra Rows

    df_nifty50.drop(["Volume", "Adj Close"], axis=1, inplace=True)
    df_niftybank.drop(["Volume", "Adj Close"], axis=1, inplace=True)
    df_niftyfin.drop(["Volume", "Adj Close"], axis=1, inplace=True)
    df_reliance.drop(["Volume", "Adj Close"], axis=1, inplace=True)

    print(f"\x1b[1;32mRemoved Extra Rows\x1b[0m\n")

    print(f"\n\x1b[1;36mScaling the Data\x1b[0m\n")

    # function to perform Min-Max scaling with bias
    def min_max_scaling_with_bias(column, bias_min=None, bias_max=None):
        # calculate the minimum and maximum values of the column
        column_min = column.min()
        column_max = column.max()

        # add bias to the minimum and maximum values if specified
        if bias_min is not None:
            column_min -= bias_min
        if bias_max is not None:
            column_max += bias_max

        # perform Min-Max scaling
        column_scaled = (column - column_min) / (column_max - column_min)

        return column_scaled, column_min, column_max

    # function to perform inverse transformation and return the original values
    def min_max_scaling_inverse(
        column_scaled, column_min, column_max, bias_min=None, bias_max=None
    ):
        # remove bias from the minimum and maximum values if specified
        if bias_min is not None:
            column_min += bias_min
        if bias_max is not None:
            column_max -= bias_max

        # perform inverse transformation
        column_unscaled = column_scaled * (column_max - column_min) + column_min

        return column_unscaled

    print(f"\x1b[1;32mSelecting Column\x1b[0m")
    col = "Close"
    scaled_nifty50, min_nifty50_val, max_nifty50_val = min_max_scaling_with_bias(
        df_nifty50[col], bias_min=1000, bias_max=1000
    )
    scaled_niftybank, min_niftybank_val, max_niftybank_val = min_max_scaling_with_bias(
        df_niftybank[col], bias_min=1000, bias_max=1000
    )
    scaled_niftyfin, min_niftyfin_val, max_niftyfin_val = min_max_scaling_with_bias(
        df_niftyfin[col], bias_min=1000, bias_max=1000
    )
    scaled_reliance, min_reliance_val, max_reliance_val = min_max_scaling_with_bias(
        df_reliance[col], bias_min=1000, bias_max=1000
    )
    print(f"\x1b[1;32mData Scaled Successfully\x1b[0m\n")

    # Save minimum and maximum values in a dictionary
    min_max_values = {
        "nifty50": {
            "min": min_nifty50_val,
            "max": max_nifty50_val,
        },
        "niftybank": {
            "min": min_niftybank_val,
            "max": max_niftybank_val,
        },
        "niftyfin": {
            "min": min_niftyfin_val,
            "max": max_niftyfin_val,
        },
        "reliance": {
            "min": min_reliance_val,
            "max": max_reliance_val,
        },
    }

    # Specify the path where you want to save the JSON file
    output_file_path = "min_max_values.json"

    # Write the dictionary to a JSON file
    with open(output_file_path, "w") as json_file:
        json.dump(min_max_values, json_file)

    print(f"\x1b[1;32Minimum and Maximum values saved to {output_file_path}\x1b[0m\n")

    print(f"\n\x1b[1;36mPreprocessing the Data\x1b[0m\n")

    input_seq_len = 30
    output_seq_len = 1

    # Nifty 50

    X_nifty50 = []
    y_nifty50 = []

    for i in tqdm(
        range(len(scaled_nifty50) - input_seq_len - output_seq_len),
        desc="\x1b[1;32mNifty 50\x1b[0m",
    ):
        X_nifty50.append(scaled_nifty50[i : i + input_seq_len])
        y_nifty50.append(
            scaled_nifty50[i + input_seq_len : i + input_seq_len + output_seq_len]
        )

    X_nifty50 = np.array(X_nifty50)
    y_nifty50 = np.array(y_nifty50)

    # Nifty Bank

    X_niftybank = []
    y_niftybank = []

    for i in tqdm(
        range(len(scaled_niftybank) - input_seq_len - output_seq_len),
        desc="\x1b[1;32mNifty Bank\x1b[0m",
    ):
        X_niftybank.append(scaled_niftybank[i : i + input_seq_len])
        y_niftybank.append(
            scaled_niftybank[i + input_seq_len : i + input_seq_len + output_seq_len]
        )

    X_niftybank = np.array(X_niftybank)
    y_niftybank = np.array(y_niftybank)

    # Nifty Financial Services

    X_niftyfin = []
    y_niftyfin = []

    for i in tqdm(
        range(len(scaled_niftyfin) - input_seq_len - output_seq_len),
        desc="\x1b[1;32mNifty Financial Services\x1b[0m",
    ):
        X_niftyfin.append(scaled_niftyfin[i : i + input_seq_len])
        y_niftyfin.append(
            scaled_niftyfin[i + input_seq_len : i + input_seq_len + output_seq_len]
        )

    X_niftyfin = np.array(X_niftyfin)
    y_niftyfin = np.array(y_niftyfin)

    # Reliance

    X_reliance = []
    y_reliance = []

    for i in tqdm(
        range(len(scaled_reliance) - input_seq_len - output_seq_len),
        desc="\x1b[1;32mReliance\x1b[0m",
    ):
        X_reliance.append(scaled_reliance[i : i + input_seq_len])
        y_reliance.append(
            scaled_reliance[i + input_seq_len : i + input_seq_len + output_seq_len]
        )

    X_reliance = np.array(X_reliance)
    y_reliance = np.array(y_reliance)

    print(f"\n\x1b[1;36mSplitting the data appropriately\x1b[0m\n")

    # Splitting Nifty 50 data
    X_nifty50_train, X_nifty50_test, y_nifty50_train, y_nifty50_test = train_test_split(
        X_nifty50, y_nifty50, test_size=0.2, random_state=42
    )

    # Splitting Nifty Bank data
    X_niftybank_train, X_niftybank_test, y_niftybank_train, y_niftybank_test = (
        train_test_split(X_niftybank, y_niftybank, test_size=0.2, random_state=42)
    )

    # Splitting Nifty Financial Services data
    X_niftyfin_train, X_niftyfin_test, y_niftyfin_train, y_niftyfin_test = (
        train_test_split(X_niftyfin, y_niftyfin, test_size=0.2, random_state=42)
    )

    # Splitting Reliance data
    X_reliance_train, X_reliance_test, y_reliance_train, y_reliance_test = (
        train_test_split(X_reliance, y_reliance, test_size=0.2, random_state=42)
    )

    print(f"\n\x1b[1;36mCreating Models\x1b[0m\n")

    # Clear any existing TensorFlow graph
    tf.keras.backend.clear_session()

    # Nifty 50

    model_nifty50 = Sequential(
        [
            Conv1D(filters=32, kernel_size=3, activation="relu", input_shape=(30, 1)),
            MaxPooling1D(pool_size=2),
            LSTM(64, return_sequences=True),
            Flatten(),
            Dense(128, activation="relu"),
            Dense(
                1, activation="sigmoid"
            ),  # Adjust the number of output units for your task
        ]
    )
    print(f"\x1b[1;32mFor Nifty 50\x1b[0m")
    model_nifty50.summary()
    model_nifty50.compile(loss="mse", optimizer="adam")

    # Nifty Bank

    model_niftybank = Sequential(
        [
            Conv1D(filters=32, kernel_size=3, activation="relu", input_shape=(30, 1)),
            MaxPooling1D(pool_size=2),
            LSTM(64, return_sequences=True),
            Flatten(),
            Dense(128, activation="relu"),
            Dense(
                1, activation="sigmoid"
            ),  # Adjust the number of output units for your task
        ]
    )
    print(f"\x1b[1;32mFor Nifty Bank\x1b[0m")
    model_niftybank.summary()
    model_niftybank.compile(loss="mse", optimizer="adam")

    # Nifty Financial Services

    model_niftyfin = Sequential(
        [
            Conv1D(filters=32, kernel_size=3, activation="relu", input_shape=(30, 1)),
            MaxPooling1D(pool_size=2),
            LSTM(64, return_sequences=True),
            Flatten(),
            Dense(128, activation="relu"),
            Dense(
                1, activation="sigmoid"
            ),  # Adjust the number of output units for your task
        ]
    )
    print(f"\x1b[1;32mFor Nifty Financial Services\x1b[0m")
    model_niftyfin.summary()
    model_niftyfin.compile(loss="mse", optimizer="adam")

    # Reliance

    model_reliance = Sequential(
        [
            Conv1D(filters=32, kernel_size=3, activation="relu", input_shape=(30, 1)),
            MaxPooling1D(pool_size=2),
            LSTM(64, return_sequences=True),
            Flatten(),
            Dense(128, activation="relu"),
            Dense(
                1, activation="sigmoid"
            ),  # Adjust the number of output units for your task
        ]
    )
    print(f"\x1b[1;32mFor Reliance\x1b[0m")
    model_reliance.summary()
    model_reliance.compile(loss="mse", optimizer="adam")

    print(f"\n\x1b[1;36mTraining Model\x1b[0m\n")

    model_nifty50.fit(X_nifty50_train, y_nifty50_train, epochs=100)
    model_niftybank.fit(X_nifty50_train, y_nifty50_train, epochs=100)
    model_niftyfin.fit(X_nifty50_train, y_nifty50_train, epochs=100)
    model_reliance.fit(X_nifty50_train, y_nifty50_train, epochs=100)

    print(f"\n\x1b[1;32mModel Trained Successfully\x1b[0m\n")

    # Make predictions on the test dataset
    y_pred_nifty50 = model_nifty50.predict(X_nifty50_test)
    y_pred_niftybank = model_niftybank.predict(X_niftybank_test)
    y_pred_niftyfin = model_niftyfin.predict(X_niftyfin_test)
    y_pred_reliance = model_reliance.predict(X_reliance_test)

    # Calculate the MSE
    mse_nifty50 = mean_squared_error(y_nifty50_test, y_pred_nifty50)
    mse_niftybank = mean_squared_error(y_niftybank_test, y_pred_niftybank)
    mse_niftyfin = mean_squared_error(y_niftyfin_test, y_pred_niftyfin)
    mse_reliance = mean_squared_error(y_reliance_test, y_pred_reliance)

    # Print the MSE
    print(
        f"\n\n\x1b[1;36mMean Squared Error (Nifty 50): \x1b[1;32m{mse_nifty50}\x1b[0m"
    )
    print(
        f"\x1b[1;36mMean Squared Error (Nifty Bank): \x1b[1;32m{mse_niftybank}\x1b[0m"
    )
    print(
        f"\x1b[1;36mMean Squared Error (Nifty Financial Services): \x1b[1;32m{mse_niftyfin}\x1b[0m"
    )
    print(f"\x1b[1;36mMean Squared Error (Reliance): \x1b[1;32m{mse_reliance}\x1b[0m\n")

    print(f"\n\x1b[1;36mSaving Models\x1b[0m\n")

    src_directory = ""

    # Check if "models" directory exists in "src"; if not, create it
    models_directory = os.path.join(src_directory, "models")
    if not os.path.exists(models_directory):
        os.mkdir(models_directory)

    # Save your models in the "models" directory
    model_nifty50.save(os.path.join(models_directory, "model_nifty50.h5"))
    model_niftybank.save(os.path.join(models_directory, "model_niftybank.h5"))
    model_niftyfin.save(os.path.join(models_directory, "model_niftyfin.h5"))
    model_reliance.save(os.path.join(models_directory, "model_reliance.h5"))

    print(f"\n\x1b[1;32mModels Saved Successfully\x1b[0m\n")


if __name__ == "__main__":
    main()
