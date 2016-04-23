# Pingo by Brett Terpstra <http://brettterpstra.com>
# Change the server as needed
# Defaults to a 10-ping average run every 5 minutes
command: "ping -c 10 199.19.85.141 | tail -n 2"
refreshFrequency: 10000
render: (output) -> """
<style>
  @-webkit-keyframes floatPing{
     from{top: 0px}
     to{top: 5px}
  }
</style>
<div class="master">
  <div id="pingo">
    <h1></h1>
    <h2></h2>
    <div id="chart"></div>
  </div>
</div>
"""

update: (output, domEl) ->
  max_rows = 26
  $container = $(domEl).find '#pingo'
  $chart = $container.find '#chart'
  packet_loss_threshold = 0.2

  packet_loss = /(\d+\.\d+)% packet loss/.exec(output)[1]
  pings = /([\d\.]+)\/([\d\.]+)\/([\d\.]+)\/([\d\.]+)/.exec(output)
  ping_avg = pings[2]

  if parseFloat packet_loss > packet_loss_threshold
    colorclass = 'dropping'
  else
    colorclass = 'perfect'

  # If the chart container is empty, set up bars
  if $chart.find('.bar').length != max_rows
    $chart.empty()
    i = 0
    while i < max_rows
      $chart.append('<div class="bar">')
      i++

  $container.find('h1').text ping_avg.substring(0, 6)+" ms"
  $container.find('h2').removeClass()
  $container.find('h2').addClass colorclass
  $container.find('h2').text packet_loss + '%'

  storageKey = 'com.brettterpstra.storedPingVal'

  totals = JSON.parse(localStorage.getItem(storageKey))
  if totals == null
    totals = []

  # Turn array strings into floating point values
  totals = totals.map (v, a, i) ->
    parseFloat(v)

  # Add the current load result to the load values array
  totals.push parseFloat ping_avg

  # Trim the array to match the number of bars we want
  totals = totals.slice(-max_rows)

  # Store the ammended array
  localStorage.setItem(storageKey, JSON.stringify(totals))


  # Create a new array and sort it to determine min/max values
  sorted = totals.slice(0)
  sorted.sort (a,b) ->
    a-b
  max = sorted[sorted.length - 1]
  min = sorted[0]
  div = (max - min) / (1000 / max_rows) / .15

  i = 0
  while i < max_rows
    load = totals[i]
    value = ((load - min) / div)

    $bar = $($chart.find('.bar').get(i))

    $bar.css
      paddingTop: value + 2 + '%'
      left: (i * 7.5) + 'px'
    i++

style: """
left 250px
top 265px
width 192px
height 45px
padding 5px
z-index:25

.master
  position: relative
  animation-iteration-count: infinite
  animation-timing-function: ease
  animation-direction: alternate
  animation-name: floatPing
  animation-duration: 2s

h1, h2
  font-size 24px
  font-family: Helvetica Neue
  font-weight: 100
h1
  color rgba(#fff,1)
  line-height 1
  margin 0
  padding 0 0px 0 4px
  float left
h2
  color rgba(#aaa,1)
  line-height 1
  margin 0 0 0 12px
  padding  0 0 0 12px
  float left
  border-left solid 2px rgba(#ccc,0.3)
  &.dropping
    color rgba(#f18383, .8)

#chart
  position absolute
  top 20px
  left 0
  padding 6px 0 0 6px
  height 20px
  width 100%
  box-sizing border-box
  border-radius 0px
  border-bottom solid 1px rgba(#fff,1)

.bar
  color rgba(#fff,1)
  font-size 10px
  text-align center
  display block
  font-family Menlo
  border-left 4px solid white
  width 9px
  bottom 0
  padding 0
  line-height 1
  position absolute

&.animated .bar
  -webkit-backface-visibility hidden;
  -webkit-perspective 1000;
  -webkit-transform translate3d(0, 0, 0);
  transition all 4s linear

.bar
  opacity 1

"""
