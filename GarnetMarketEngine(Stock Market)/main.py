from flask import Flask, render_template, jsonify
import pandas as pd
from datetime import datetime, timedelta
import json
import yfinance as yf

app = Flask(__name__)

symbol_list = ["Nifty 50", "Nifty Bank", "Nifty Financial Services", "Reliance"]
dict_list = ["nifty50", "niftybank", "niftyfin", "reliance"]
n = len(dict_list)


@app.route("/")
def index():
    return render_template(
        "index.html", symbol_list=symbol_list, dict_list=dict_list, n=n
    )


chart_data = [
    {"time": "2023-10-23", "value": 19281.75},
    {"time": "2023-10-24", "value": 19290},
]


@app.route("/chart-data-nifty50")
def get_nifty50_chart_data():
    print(r"\x1b[1;36mGetting Dates\x1b[0m\n")
    end_date = datetime.now()
    start_date = end_date - timedelta(500)
    print(
        f'\x1b[1;36mStart Date        \x1b[1;32m{start_date.strftime("%Y-%b-%d")}\x1b[0m'
    )
    print(
        f'\x1b[1;36mEnd Date          \x1b[1;32m{end_date.strftime("%Y-%b-%d")}\x1b[0m\n'
    )

    df_nifty50 = yf.download("^NSEI", start=start_date, end=end_date)
    df_nifty50 = df_nifty50.reset_index()
    df_nifty50.columns = df_nifty50.columns.get_level_values(0)
    # df_nifty50 = df_nifty50.tail(30).reset_index(drop=True)
    df_nifty50.drop(
        ["Open", "High", "Low", "Adj Close", "Volume"], axis=1, inplace=True
    )
    df_nifty50["Date"] = pd.to_datetime(df_nifty50["Date"])
    chart_data = [
        {"time": date.strftime("%Y-%m-%d"), "value": close} for date, close in zip(df_nifty50["Date"], df_nifty50["Close"])
    ]
    return jsonify(chart_data)


@app.route("/pred-nifty50")
def get_nifty50_pred():
    end_date = datetime.now()
    start_date = end_date - timedelta(500)
    start_timestamp = int(round(datetime.timestamp(start_date), 0))
    end_timestamp = int(round(datetime.timestamp(end_date), 0))
    print(
        f'\x1b[1;36mStart Date        \x1b[1;32m{start_date.strftime("%Y-%b-%d")}\x1b[0m'
    )
    print(
        f'\x1b[1;36mEnd Date          \x1b[1;32m{end_date.strftime("%Y-%b-%d")}\x1b[0m\n'
    )
    df_nifty50 = yf.download("^NSEI", start=start_date, end=end_date)
    df_nifty50 = df_nifty50.reset_index()
    df_nifty50.columns = df_nifty50.columns.get_level_values(0)
    # df_nifty50 = df_nifty50.tail(30).reset_index(drop=True)
    df_nifty50.drop(
        ["Open", "High", "Low", "Adj Close", "Volume"], axis=1, inplace=True
    )
    df_nifty50["Date"] = pd.to_datetime(df_nifty50["Date"])
    df_nifty50 = df_nifty50.tail(1)
    df_nifty50.dropna(inplace=True)
    with open("src/prediction.json", "r") as json_file:
        data = json.load(json_file)
    new_row = {"Date": end_date + timedelta(1), "Close": data["pred_nifty50"]}
    df_nifty50.loc[len(df_nifty50)] = new_row
    chart_data = [
        {"time": date.strftime("%Y-%m-%d"), "value": close}
        for date, close in zip(df_nifty50["Date"], df_nifty50["Close"])
    ]
    return jsonify(chart_data)


@app.route("/chart-data-niftybank")
def get_niftybank_chart_data():
    print(f"\x1b[1;36mGetting Dates\x1b[0m\n")
    end_date = datetime.now()
    start_date = end_date - timedelta(500)
    print(
        f'\x1b[1;36mStart Date        \x1b[1;32m{start_date.strftime("%Y-%b-%d")}\x1b[0m'
    )
    print(
        f'\x1b[1;36mEnd Date          \x1b[1;32m{end_date.strftime("%Y-%b-%d")}\x1b[0m\n'
    )
    df_niftybank = yf.download("^NSEBANK", start=start_date, end=end_date)
    df_niftybank = df_niftybank.reset_index()
    df_niftybank.columns = df_niftybank.columns.get_level_values(0)
    df_niftybank.drop(
        ["Open", "High", "Low", "Adj Close", "Volume"], axis=1, inplace=True
    )
    df_niftybank["Date"] = pd.to_datetime(df_niftybank["Date"])
    df_niftybank.dropna(inplace=True)
    chart_data = [
        {"time": date.strftime("%Y-%m-%d"), "value": close}
        for date, close in zip(df_niftybank["Date"], df_niftybank["Close"])
    ]
    return jsonify(chart_data)


@app.route("/pred-niftybank")
def get_niftybank_pred():
    end_date = datetime.now()
    start_date = end_date - timedelta(500)
    print(
        f'\x1b[1;36mStart Date        \x1b[1;32m{start_date.strftime("%Y-%b-%d")}\x1b[0m'
    )
    print(
        f'\x1b[1;36mEnd Date          \x1b[1;32m{end_date.strftime("%Y-%b-%d")}\x1b[0m\n'
    )
    df_niftybank = yf.download("^NSEBANK", start=start_date, end=end_date)
    df_niftybank = df_niftybank.reset_index()
    df_niftybank.columns = df_niftybank.columns.get_level_values(0)

    df_niftybank.drop(
        ["Open", "High", "Low", "Adj Close", "Volume"], axis=1, inplace=True
    )
    df_niftybank["Date"] = pd.to_datetime(df_niftybank["Date"])
    df_niftybank = df_niftybank.tail(1)
    with open("src/prediction.json", "r") as json_file:
        data = json.load(json_file)
    new_row = {"Date": end_date + timedelta(1), "Close": data["pred_niftybank"]}
    df_niftybank.loc[len(df_niftybank)] = new_row
    chart_data = [
        {"time": date.strftime("%Y-%m-%d"), "value": close}
        for date, close in zip(df_niftybank["Date"], df_niftybank["Close"])
    ]
    return jsonify(chart_data)


@app.route("/chart-data-niftyfin")
def get_niftyfin_chart_data():
    print(f"\x1b[1;36mGetting Dates\x1b[0m\n")
    end_date = datetime.now()
    start_date = end_date - timedelta(500)
    print(
        f'\x1b[1;36mStart Date        \x1b[1;32m{start_date.strftime("%Y-%b-%d")}\x1b[0m'
    )
    print(
        f'\x1b[1;36mEnd Date          \x1b[1;32m{end_date.strftime("%Y-%b-%d")}\x1b[0m\n'
    )

    df_niftyfin = yf.download("NIFTY_FIN_SERVICE.NS", start=start_date, end=end_date)
    df_niftyfin = df_niftyfin.reset_index()
    df_niftyfin.columns = df_niftyfin.columns.get_level_values(0)
    df_niftyfin.drop(
        ["Open", "High", "Low", "Adj Close", "Volume"], axis=1, inplace=True
    )
    df_niftyfin["Date"] = pd.to_datetime(df_niftyfin["Date"])
    df_niftyfin.dropna(inplace=True)
    chart_data = [
        {"time": date.strftime("%Y-%m-%d"), "value": close}
        for date, close in zip(df_niftyfin["Date"], df_niftyfin["Close"])
    ]
    return jsonify(chart_data)


@app.route("/pred-niftyfin")
def get_niftyfin_pred():
    end_date = datetime.now()
    start_date = end_date - timedelta(500)
    print(
        f'\x1b[1;36mStart Date        \x1b[1;32m{start_date.strftime("%Y-%b-%d")}\x1b[0m'
    )
    print(
        f'\x1b[1;36mEnd Date          \x1b[1;32m{end_date.strftime("%Y-%b-%d")}\x1b[0m\n'
    )
    df_niftyfin = yf.download("NIFTY_FIN_SERVICE.NS", start=start_date, end=end_date)
    df_niftyfin = df_niftyfin.reset_index()
    df_niftyfin.columns = df_niftyfin.columns.get_level_values(0)
    df_niftyfin.drop(
        ["Open", "High", "Low", "Adj Close", "Volume"], axis=1, inplace=True
    )
    df_niftyfin["Date"] = pd.to_datetime(df_niftyfin["Date"])
    df_niftyfin = df_niftyfin.tail(1)
    with open("src/prediction.json", "r") as json_file:
        data = json.load(json_file)
    new_row = {"Date": end_date + timedelta(1), "Close": data["pred_niftyfin"]}
    df_niftyfin.loc[len(df_niftyfin)] = new_row
    chart_data = [
        {"time": date.strftime("%Y-%m-%d"), "value": close}
        for date, close in zip(df_niftyfin["Date"], df_niftyfin["Close"])
    ]
    return jsonify(chart_data)


@app.route("/chart-data-reliance")
def get_reliance_chart_data():
    print(f"\x1b[1;36mGetting Dates\x1b[0m\n")
    end_date = datetime.now()
    start_date = end_date - timedelta(500)
    start_timestamp = int(round(datetime.timestamp(start_date), 0))
    end_timestamp = int(round(datetime.timestamp(end_date), 0))
    print(
        f'\x1b[1;36mStart Date        \x1b[1;32m{start_date.strftime("%Y-%b-%d")}\x1b[0m'
    )
    print(
        f'\x1b[1;36mEnd Date          \x1b[1;32m{end_date.strftime("%Y-%b-%d")}\x1b[0m\n'
    )

    df_reliance = yf.download("RELIANCE.NS", start=start_date, end=end_date)
    df_reliance = df_reliance.reset_index()
    df_reliance.columns = df_reliance.columns.get_level_values(0)
    df_reliance.drop(
        ["Open", "High", "Low", "Adj Close", "Volume"], axis=1, inplace=True
    )
    df_reliance["Date"] = pd.to_datetime(df_reliance["Date"])
    df_reliance.dropna(inplace=True)
    chart_data = [
        {"time": date.strftime("%Y-%m-%d"), "value": close}
        for date, close in zip(df_reliance["Date"], df_reliance["Close"])
    ]
    return jsonify(chart_data)


@app.route("/pred-reliance")
def get_reliance_pred():
    end_date = datetime.now()
    start_date = end_date - timedelta(500)
    print(
        f'\x1b[1;36mStart Date        \x1b[1;32m{start_date.strftime("%Y-%b-%d")}\x1b[0m'
    )
    print(
        f'\x1b[1;36mEnd Date          \x1b[1;32m{end_date.strftime("%Y-%b-%d")}\x1b[0m\n'
    )

    df_reliance = yf.download("RELIANCE.NS", start=start_date, end=end_date)
    df_reliance = df_reliance.reset_index()
    df_reliance.columns = df_reliance.columns.get_level_values(0)

    df_reliance.drop(
        ["Open", "High", "Low", "Adj Close", "Volume"], axis=1, inplace=True
    )
    df_reliance["Date"] = pd.to_datetime(df_reliance["Date"])
    df_reliance = df_reliance.tail(1)
    with open("src/prediction.json", "r") as json_file:
        data = json.load(json_file)
    new_row = {"Date": end_date + timedelta(1), "Close": data["pred_reliance"]}
    df_reliance.loc[len(df_reliance)] = new_row
    chart_data = [
        {"time": date.strftime("%Y-%m-%d"), "value": close}
        for date, close in zip(df_reliance["Date"], df_reliance["Close"])
    ]
    return jsonify(chart_data)


app.run(host="0.0.0.0", port=5000)
