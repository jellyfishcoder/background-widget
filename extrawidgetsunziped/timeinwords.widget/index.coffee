#
# Time in Words widget for Übersicht
# Raphael Hanneken
# behoernchen.github.io
#


#
# Adjust the styles as you like
#
style =
	# Define the maximum width of the widget.
	width: "100%"

	# Define the position, where to display the time.
	# Set properties you don't need to "auto"
	# By default posistions it in the middle using text center later
	position:
		top:    "auto"
		bottom: "15%"
		left:   "0%"
		right: "auto"


	# Font properties
	font:            "'Helvetica Neue', sans-serif"
	# IF YOU HAVE APPLE DEV ACCOUNT AND DOWNLOADED SAN FRANSICO FONT (SanFran is default system font but only those with dev account can use it for other things):
	# font:          "'SF UI Text', sans-serif"
	font_color:      "#F5F5F5"
	font_size:       "6vw"
	font_weight:     "100"
	letter_spacing:  "0.025em"
	line_height:     ".9em"

	# Text shadow
	text_shadow:
		blur: 		"0px"
		x_offset: "1px"
		y_offset: "1px"
		color:    "rgba(0, 0, 0, .4)"

	# Misc
	text_align:     "center"
  text_transform: "uppercase"

	z_index: 45


# Get the current hour as word.
command: "ruby background.widget/extra-widgets/timeinwords.widget/hours.rb"

# Lower the frequency for more accuracy.
refreshFrequency: (1000 * 3) # (1000 * n) seconds, 3 sec by default

# HTML content to render
render: (o) -> """
	<div id="content">
		<span id="hours"></span>
		<span id="minutes"></span>
	</div>
"""

# Run every refreshFrequency and updates the html content
update: (output, dom) ->
	$(dom).find("#hours").html(output)
	@run("ruby background.widget/extra-widgets/timeinwords.widget/minutes.rb", (err, output) ->
			$(dom).find('#minutes').html(output)
	)

# CSS style sheet
style: """
	top: #{@style.position.top}
	bottom: #{@style.position.bottom}
	right: #{@style.position.right}
	left: #{@style.position.left}
	width: #{@style.width}
	font-family: #{@style.font}
	color: #{@style.font_color}
	font-weight: #{@style.font_weight}
	text-align: #{@style.text_align}
	text-transform: #{@style.text_transform}
	font-size: #{@style.font_size}
	letter-spacing: #{@style.letter_spacing}
	font-smoothing: antialiased
	text-shadow: #{@style.text_shadow.x_offset} #{@style.text_shadow.y_offset} #{@style.text_shadow.blur} #{@style.text_shadow.color}
	line-height: #{@style.line_height}
	z-index: #{@style.z_index}

"""
