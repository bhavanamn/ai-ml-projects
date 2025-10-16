# Importing Libraries

import json
import os
from min_max import min_max_scaling_inverse, min_max_scaling_with_bias
from tensorflow.keras.models import load_model
import pandas as pd
from datetime import datetime, timedelta
import numpy as np
import yfinance as yf
from tensorflow.keras import losses

# Main Function


def main():
    # Loading Saved Values

    print(f"\n\x1b[1;36mLoading Saved Values\x1b[0m\n")
    input_file_path = "min_max_values.json"
    with open(input_file_path, "r") as json_file:
        min_max_values = json.load(json_file)

    # Fetching Saved Values

    print(f"\n\x1b[1;36mFetching Saved Values\x1b[0m\n")
    min_nifty50_val = min_max_values["nifty50"]["min"]
    max_nifty50_val = min_max_values["nifty50"]["max"]
    min_niftybank_val = min_max_values["niftybank"]["min"]
    max_niftybank_val = min_max_values["niftybank"]["max"]
    min_niftyfin_val = min_max_values["niftyfin"]["min"]
    max_niftyfin_val = min_max_values["niftyfin"]["max"]
    min_reliance_val = min_max_values["reliance"]["min"]
    max_reliance_val = min_max_values["reliance"]["max"]

    # Getting Dates

    print(f"\x1b[1;36mGetting Dates\x1b[0m\n")
    end_date = datetime.now()
    start_date = end_date - timedelta(60)
    start_timestamp = int(round(datetime.timestamp(start_date), 0))
    end_timestamp = int(round(datetime.timestamp(end_date), 0))
    print(
        f'\x1b[1;36mStart Date        \x1b[1;32m{start_date.strftime("%Y-%b-%d")}\x1b[0m'
    )
    print(
        f'\x1b[1;36mEnd Date          \x1b[1;32m{end_date.strftime("%Y-%b-%d")}\x1b[0m\n'
    )

    # Starting Yahoo Instance

    print(f"\x1b[1;36mStarting Yahoo Instance\x1b[0m\n")

    df_nifty50 = yf.download("^NSEI", start=start_date, end=end_date)
    df_niftybank = yf.download("^NSEBANK", start=start_date, end=end_date)
    df_niftyfin = yf.download("NIFTY_FIN_SERVICE.NS", start=start_date, end=end_date)
    df_reliance = yf.download("RELIANCE.NS", start=start_date, end=end_date)

    print(f"\x1b[1;32mNifty 50\x1b[0m")
    print(f"\x1b[1;32mNifty Bank\x1b[0m")
    print(f"\x1b[1;32mNifty Financial Services\x1b[0m")
    print(f"\x1b[1;32mReliance\x1b[0m\n")

    # Cleaning the Data

    print(f"\n\x1b[1;36mCleaning the Data\x1b[0m\n")

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

    df_nifty50 = df_nifty50.tail(30).reset_index(drop=True)
    df_niftybank = df_niftybank.tail(30).reset_index(drop=True)
    df_niftyfin = df_niftyfin.tail(30).reset_index(drop=True)
    df_reliance = df_reliance.tail(30).reset_index(drop=True)

    # Loading the Model

    print(f"\n\x1b[1;36mLoading the Models\x1b[0m\n")
    model_nifty50 = load_model(
        "../src/models/model_nifty50.h5",
        custom_objects={"mse": losses.MeanSquaredError()},
    )
    model_niftybank = load_model(
        "../src/models/model_niftybank.h5",
        custom_objects={"mse": losses.MeanSquaredError()},
    )
    model_niftyfin = load_model(
        "../src/models/model_niftyfin.h5",
        custom_objects={"mse": losses.MeanSquaredError()},
    )
    model_reliance = load_model(
        "../src/models/model_reliance.h5",
        custom_objects={"mse": losses.MeanSquaredError()},
    )

    # Approriately Scaling the Data

    print(f"\n\x1b[1;36mApproriately Scaling the Data\x1b[0m\n")
    scaled_nifty50, temp1, temp2 = min_max_scaling_with_bias(
        df_nifty50["Close"], min_nifty50_val, max_nifty50_val
    )
    scaled_niftybank, temp1, temp2 = min_max_scaling_with_bias(
        df_niftybank["Close"], min_niftybank_val, max_niftybank_val
    )
    scaled_niftyfin, temp1, temp2 = min_max_scaling_with_bias(
        df_niftyfin["Close"], min_niftyfin_val, max_niftyfin_val
    )
    scaled_reliance, temp1, temp2 = min_max_scaling_with_bias(
        df_reliance["Close"], min_reliance_val, max_reliance_val
    )

    # Predicting

    print(f"\n\x1b[1;36mPredicting\x1b[0m\n")
    pred_nifty50 = model_nifty50.predict(np.array([scaled_nifty50]))
    pred_niftybank = model_nifty50.predict(np.array([scaled_niftybank]))
    pred_niftyfin = model_nifty50.predict(np.array([scaled_niftyfin]))
    pred_reliance = model_nifty50.predict(np.array([scaled_reliance]))

    unscaled_pred_nifty50 = round(
        min_max_scaling_inverse(
            pred_nifty50,
            min_nifty50_val - 1000,
            max_nifty50_val + 1000,
            bias_min=1000,
            bias_max=1000,
        )[0][0],
        2,
    ).item()
    unscaled_pred_niftybank = round(
        min_max_scaling_inverse(
            pred_niftybank,
            min_niftybank_val - 1000,
            max_niftybank_val + 1000,
            bias_min=1000,
            bias_max=1000,
        )[0][0],
        2,
    ).item()
    unscaled_pred_niftyfin = round(
        min_max_scaling_inverse(
            pred_niftyfin,
            min_niftyfin_val - 1000,
            max_niftyfin_val + 1000,
            bias_min=1000,
            bias_max=1000,
        )[0][0],
        2,
    ).item()
    unscaled_pred_reliance = round(
        min_max_scaling_inverse(
            pred_reliance,
            min_reliance_val - 1000,
            max_reliance_val + 1000,
            bias_min=1000,
            bias_max=1000,
        )[0][0],
        2,
    ).item()

    # Saving the predictions

    print(f"\n\x1b[1;32mSaving the Predictions\x1b[0m\n")
    # Create a dictionary to store the values
    data = {
        "pred_nifty50": unscaled_pred_nifty50,
        "pred_niftybank": unscaled_pred_niftybank,
        "pred_niftyfin": unscaled_pred_niftyfin,
        "pred_reliance": unscaled_pred_reliance,
    }

    # Specify the name of the JSON file
    json_file = "prediction.json"

    # Write the data to the JSON file
    with open(json_file, "w") as f:
        json.dump(data, f)


if __name__ == "__main__":
    main()

