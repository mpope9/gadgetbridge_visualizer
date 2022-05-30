// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
//import "../css/main.css"

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
//import "phoenix_html"
//// Establish Phoenix Socket and LiveView configuration.
//import {Socket} from "phoenix"
//import {LiveSocket} from "phoenix_live_view"
//
//let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
//let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})
//
//// Show progress bar on live navigation and form submits
//topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
//window.addEventListener("phx:page-loading-start", info => topbar.show())
//window.addEventListener("phx:page-loading-stop", info => topbar.hide())
//
//// connect if there are any LiveViews on the page
//liveSocket.connect()
//
//// expose liveSocket on window for web console debug logs and latency simulation:
//// >> liveSocket.enableDebug()
//// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
//// >> liveSocket.disableLatencySim()
//window.liveSocket = liveSocket
//

import * as echarts from 'echarts';

// Heart Rate Chart
var heartRateDom = document.getElementById('heart-rate-chart');
var heartRateChart = echarts.init(heartRateDom);
var heartRateOption;

heartRateOption = {
  xAxis: {
    type: 'category',
    data: ['1pm', '2pm', '3pm', '4pm', '5pm', '6pm', '7pm']
  },
  yAxis: {
    type: 'value'
  },
  series: [
    {
      data: [60, 62, 120, 50, 51, 60, 63],
      type: 'line'
    }
  ]
};

heartRateOption && heartRateChart.setOption(heartRateOption);

// Sleep Chart
var sleepDom = document.getElementById('sleep-chart');
var sleepChart = echarts.init(sleepDom);
var sleepOptions;

sleepOptions = {
  tooltip: {
    trigger: 'item'
  },
  legend: {
    top: '5%',
    left: 'center'
  },
  series: [
    {
      name: 'Access From',
      type: 'pie',
      radius: ['40%', '70%'],
      avoidLabelOverlap: false,
      label: {
        show: false,
        position: 'center'
      },
      emphasis: {
        label: {
          show: true,
          fontSize: '40',
          fontWeight: 'bold'
        }
      },
      labelLine: {
        show: false
      },
      data: [
        { value: 120, name: 'Deep Sleep' },
        { value: 10, name: 'Light Sleep' }
      ]
    }
  ]
};

sleepOptions && sleepChart.setOption(sleepOptions);


