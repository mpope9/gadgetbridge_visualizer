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

var colorPalette = ['#ffa600', '#ff6361', '#bc5090', '#58508d', '#003f5c'].reverse();
var colorPaletteDichotomy = ['#ffa600', '#58508d'];

// Chart that draws the heart rates time series.
window.drawHeartRateChart = function(data, labels) {
    var heartRateDom = document.getElementById('heart-rate-chart');
    var heartRateChart = echarts.init(heartRateDom);
    var heartRateOption;

    heartRateOption = {
        toolbox: {
            show: true,
            feature: {
                saveAsImage: {show: true},
                dataView : {show: true, readOnly: false},
            }
        },
        dataZoom: [
            {
                type: 'slider',
                show: true,
                realtime: true,
                start: 0,
                end: 100,
                top: 25
            },
            {
                type: 'inside',
                realtime: true,
                start: 0,
                end: 100,
                top: 25
            }
        ],
        tooltip: {
            trigger: 'axis',
            formatter: (params) => { 
                return `Heart Rate: ${params[0].data}`;
            },
            axisPointer: {
                type: 'cross',
                animation: false,
                label: {
                    backgroundColor: '#505765'
                }
            }
        },
        xAxis: {
            data: labels,
            type: 'category',
            boundryGap: false,
            axisLine: {
                onZero: false
            },
            axisLabel: {
                rotate: 45
            }
        },
        yAxis: {
            type: 'value'
        },
        series: [
            {
                data: data,
                color: '#ff6361',
                smooth: true,
                type: 'line'
            }
        ]
    };
    heartRateOption && heartRateChart.setOption(heartRateOption);
};


// Sleep Chart
window.sleepChart = function() {
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
                color: colorPaletteDichotomy,
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
};


// Steps Per Day
window.stepsPerDayChart = function(data, labels) {
    var stepsPerDayDom = document.getElementById('steps-per-day-chart');
    var stepsPerDayChart = echarts.init(stepsPerDayDom);
    var stepsPerDayOptions;

    stepsPerDayOptions = {
        xAxis: {
            data: labels,
            type: 'category',
        },
        tooltip: {
            trigger: 'axis',
            axisPointer: {
                type: 'shadow'
            },
            formatter: function (params) {
                var tar = params[0];
                return tar.name + '<br/>' + tar.seriesName + ' : ' + tar.value;
            }
        },
        yAxis: {
            type: 'value'
        },
        series: [
            {
                name: "Steps / day",
                color: colorPalette,
                label: {
                    show: true,
                    position: 'inside'
                },
                data: data,
                type: 'bar'
            }
        ]
    };

    stepsPerDayOptions && stepsPerDayChart.setOption(stepsPerDayOptions);
};

// Steps total
window.stepsGoal = function(stepsTotal, daysTotal) {
    var stepsGoalDom = document.getElementById('steps-goal-chart');
    var stepsGoalChart = echarts.init(stepsGoalDom);
    var stepsGoalOptions;

    var data;
    var stepGoal = 8000;

    if (daysTotal < 1 && stepsTotal > stepGoal) {
        data = [
            { value: stepsTotal, name: 'Steps Made'}
        ];
    }
    if (daysTotal < 1 && stepsTotal < stepGoal) {
        data = [
            { value: stepsTotal, name: 'Steps Made'},
            { value: 8000 - stepsTotal, name: 'Steps Missed'}
        ];
    }
    if (daysTotal >= 1 && stepsTotal > (stepGoal * daysTotal)) {
        data = [
            { value: stepsTotal, name: 'Steps Made'}
        ];
    } else {
        data = [
            { value: stepsTotal, name: 'Steps Made'},
            { value: (8000 * daysTotal) - stepsTotal, name: 'Steps Missed'}
        ];
    }

    stepsGoalOptions = {
        tooltip: {
            trigger: 'item'
        },
        legend: {
            orient: 'vertical',
            left: 'left'
        },
        series: [
            {
                name: 'Access From',
                color: colorPaletteDichotomy,
                type: 'pie',
                radius: ['40%', '70%'],
                data: data,
                emphasis: {
                    itemStyle: {
                        shadowBlur: 10,
                        shadowOffsetX: 0,
                        shadowColor: 'rgba(0, 0, 0, 0.5)'
                    }
                }
            }
        ]
    };

    stepsGoalOptions && stepsGoalChart.setOption(stepsGoalOptions);
};
