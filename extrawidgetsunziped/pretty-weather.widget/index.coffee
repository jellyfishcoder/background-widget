apiKey: 'b9da17ac380819a4fbca4ce5b26adab4' # put your forcast.io api key inside the quotes here

refreshFrequency: 60000 # Defaults to one minute
position:
  position: "absolute"
  top: "50%"
  left: "50%"
  right: "auto"
  bottom: "auto"
z_index: 12
# IF YOU DO NOT HAVE SAN FRANSICO FONT OR APPLE DEVELOPER ACCOUNT
font: "'Helvetica Neue', sans-serif"
# IF YOU HAVE APPLE DEV ACCOUNT AND DOWNLOADED SAN FRANSICO FONT (SanFran is default system font but only those with dev account can use it for other things):
# font: "'SF UI Text', sans-serif"
font_color: "rgba(255,255,255, 1)"

style: """
  position: #{@style.position.position}
	top: #{@style.position.top}
	bottom: #{@style.position.bottom}
	right: #{@style.position.right}
	left: #{@style.position.left}
	font-family: #{@style.font}
	color: #{@style.font_color}
	z-index: #{@style.z_index}

  transform: translate(-50%, -50%);

  .master
    position: relative
    animation-iteration-count: infinite
    animation-timing-function: ease
    animation-direction: alternate
    animation-name: floatWeather
    animation-duration: 3s

  @font-face
    font-family Weather
    src url(background.widget/extra-widgets/pretty-weather.widget/icons.svg) format('svg')

  .icon
    font-family: Weather
    font-size: 72px
    text-anchor: middle
    alignment-baseline: middle
    max-width: 200px
    text-transform: uppercase
    font-weight: 100
  	letter-spacing: 0.025em
  	font-smoothing: antialiased
    text-shadow: 1px 1px 0px rgba(0, 0, 0, .4)


  .temp
    font-size: 72px
    font-family: Helvetica Neue
    max-width: 200px
    text-transform: uppercase
    font-weight: 100
  	letter-spacing: 0.025em
  	font-smoothing: antialiased
  	line-height: 0.9em
    text-shadow: 1px 1px 0px rgba(0, 0, 0, .4)

    text-anchor: middle
    alignment-baseline: left

  .outline
    fill: none
    stroke: #fff
    stroke-width: 0.5

  .icon-bg
    fill: rgba(#fff, 0.95)

  .summary
    text-align: center
    border-top: 1px solid rgba(255,255,255, 1)
    padding: 12px 0 0 0
    margin-top: -20px
    font-size: 20px
    max-width: 200px
    font-weight: 200
  	letter-spacing: 0.025em
  	font-smoothing: antialiased
  	line-height: 0.9em
    text-shadow: 1px 1px 0px rgba(0, 0, 0, .4)

  .main
    text-align: center
    padding: 50px 0px 30px 0
    margin-top: -60px
    font-size: 14px
    max-width: 200px
    text-transform: uppercase
    font-weight: 200
    letter-spacing: 0.025em
    font-smoothing: antialiased
    line-height: 0.9em
    text-shadow: 1px 1px 0px rgba(0, 0, 0, .4)

  .adjust
    padding: 50px 0 0 29px

  .date, .location
    fill: rgba(255,255,255, 1)
    stroke: rgba(255,255,255, 1)
    stroke-width: 1px
    font-size: 12px
    text-anchor: middle
    text-transform: uppercase
    font-weight: 100
  	letter-spacing: 0.025em
  	font-smoothing: antialiased
  	line-height: 0.9em
    text-shadow: 1px 1px 0px rgba(0, 0, 0, .4)
"""

command: "echo {}"

render: (o) -> """
  <style>
      @-webkit-keyframes floatWeather{
         from{top: 10px}
         to{top: 0px}
      }
  </style>
  <div class="master">
    <div class="main">
        <text class="icon"></text>

        <div class="adjust">
        <text class="temp"></text>
        </div>
    </div>
    <div class='summary'></div>
  </div>
"""

svgNs: 'xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink"'

afterRender: (domEl) ->
  geolocation.getCurrentPosition (e) =>
    coords     = e.position.coords
    [lat, lon] = [coords.latitude, coords.longitude]
    @command   = @makeCommand(@apiKey, "#{lat},#{lon}")

    $(domEl).find('.location').prop('textContent', e.address.city)
    @refresh()


makeCommand: (apiKey, location) ->
  exclude  = "minutely,hourly,alerts,flags"
  "curl -sS 'https://api.forecast.io/forecast/#{apiKey}/#{location}?units=auto&exclude=#{exclude}'"

update: (output, domEl) ->
  data  = JSON.parse(output)
  today = data.daily?.data[0]

  return unless today?
  date  = @getDate today.time

  $(domEl).find('.temp').prop 'textContent',Math.round(today.temperatureMax)+'°'
  $(domEl).find('.summary').text today.summary
  $(domEl).find('.icon')[0]?.textContent = @getIcon(today)
  $(domEl).find('.date').prop('textContent',@dayMapping[date.getDay()])


dayMapping:
  0: 'Sunday'
  1: 'Monday'
  2: 'Tuesday'
  3: 'Wednesday'
  4: 'Thursday'
  5: 'Friday'
  6: 'Saturday'

iconMapping:
  "rain"                :"\uf019"
  "snow"                :"\uf01b"
  "fog"                 :"\uf014"
  "cloudy"              :"\uf013"
  "wind"                :"\uf021"
  "clear-day"           :"\uf00d"
  "mostly-clear-day"    :"\uf00c"
  "partly-cloudy-day"   :"\uf002"
  "clear-night"         :"\uf02e"
  "partly-cloudy-night" :"\uf031"
  "unknown"             :"\uf03e"

getIcon: (data) ->
  return @iconMapping['unknown'] unless data

  if data.icon.indexOf('cloudy') > -1
    if data.cloudCover < 0.25
      @iconMapping["clear-day"]
    else if data.cloudCover < 0.5
      @iconMapping["mostly-clear-day"]
    else if data.cloudCover < 0.75
      @iconMapping["partly-cloudy-day"]
    else
      @iconMapping["cloudy"]
  else
    @iconMapping[data.icon]

getDate: (utcTime) ->
  date  = new Date(0)
  date.setUTCSeconds(utcTime)
  date
