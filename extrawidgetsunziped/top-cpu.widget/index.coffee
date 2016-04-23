command: "ps axro \"%cpu,ucomm,pid\" | awk 'FNR>1' | tail +1 | head -n 3 | sed -e 's/^[ ]*\\([0-9][0-9]*\\.[0-9][0-9]*\\)\\ /\\1\\%\\,/g' -e 's/\\ \\ *\\([0-9][0-9]*$\\)/\\,\\1/g'"

refreshFrequency: 2000

position:
  top: "50px"
  left: "2.5%"
  botton: "auto"
  right: "auto"
font: "'Helvetica Neue', sans-serif"
# IF YOU HAVE APPLE DEV ACCOUNT AND DOWNLOADED SAN FRANSICO FONT (SanFran is default system font but only those with dev account can use it for other things):
# font: "'SF UI Text', sans-serif"
font_color: "#FFF"
max_width:"370px"
z_index: 35

style: """
	top: #{@style.position.top}
	bottom: #{@style.position.bottom}
	right: #{@style.position.right}
	left: #{@style.position.left}
	max-width: #{@style.max_width}
	font-family: #{@style.font}
	color: #{@style.font_color}
	font-size: #{@style.font_size}
	font-smoothing: antialiased
	z-index: #{@style.z_index}

  .master
    position: relative
    animation-iteration-count: infinite
    animation-timing-function: ease
    animation-direction: alternate
    animation-name: floatTOPCPU
    animation-duration: 2s

  table
    border-collapse: collapse
    table-layout: fixed

    &:after
      content: 'CPU'
      position: absolute
      left: 0
      top: -35px
      font-size: 30px
      font-weight: 100

  td
    border: 1px solid #fff
    font-size: 24px
    font-weight: 100
    width: 120px
    max-width: 120px
    overflow: hidden
    text-shadow: 0 0 1px rgba(#fff, 0.4)

  .wrapper
    padding: 4px 6px 4px 6px
    position: relative

  .col1
    background: rgba(#f99, 0.3)

  .col2
    background: rgba(#ff9, 0.2)

  .col3
    background: rgba(#9f9, 0.1)

  p
    padding: 0
    margin: 0
    font-size: 11px
    font-weight: normal
    max-width: 100%
    color: #eee
    text-overflow: ellipsis
    text-shadow: none

  .pid
    position: absolute
    top: 2px
    right: 2px
    font-size: 11px
    font-weight: normal

"""


render: -> """
  <style>
    @-webkit-keyframes [floatTOPCPU]{
       from{top: 0px}
       to{top: 5px}
    }
  </style>
  <div class="master">
    <table>
      <tr>
        <td class='col1'></td>
        <td class='col2'></td>
        <td class='col3'></td>
      </tr>
    </table>
    <bartable>
      <tr>
        <td id="bar"></td>
        <tr>
    </bartable>
  </div>
"""

update: (output, domEl) ->
  processes = output.split('\n')
  table     = $(domEl).find('table')

  renderProcess = (cpu, name, id) ->
    "<div class='wrapper'>" +
      "#{cpu}<p>#{name}</p>" +
      "<div class='pid'>PID:<br>#{id}</div>" +
    "</div>"

  for process, i in processes
    args = process.split(',')
    table.find(".col#{i+1}").html renderProcess(args...)
