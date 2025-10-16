document.addEventListener("DOMContentLoaded", function () {
  // Create a container for the chart

  function fetchData(symbol) {

    const chartContainer = document.getElementById("chart-container");

    // Create a new chart
    const chart = LightweightCharts.createChart(chartContainer, {
      width: chartContainer.clientWidth,
      height: chartContainer.clientHeight - 15,
    });

    // Create line series for the data and prediction
    const lineSeries = chart.addLineSeries({ color: 'blue' });
    const predSeries = chart.addLineSeries({ color: 'red' });

    console.log(symbol)
    // Fetch data for the "data" series
    fetch(`/chart-data-${symbol}`)
      .then(response => response.json())
      .then(data => {
        // Set the data for the "data" series
        lineSeries.setData(data);
      });

    // Fetch data for the "prediction" series
    fetch(`/pred-${symbol}`)
      .then(response => response.json())
      .then(data => {
        // Set the data for the "prediction" series
        predSeries.setData(data);
      });
  }

  fetchData('nifty50')

  function updateData(symbol) {
    // Clear existing chart container and legend
    const chartContainer = document.getElementById('chart-container');
    chartContainer.innerHTML = '';

    fetchData(symbol);
  }

  const symbolRows = document.getElementsByClassName('symbol-row');
  console.log(symbolRows);
  Array.from(symbolRows).forEach(row => {
    row.addEventListener('click', function () {
      selectedSymbol = this.dataset.symbol;
      console.log(selectedSymbol)
      updateData(selectedSymbol)
    });
  });

});
