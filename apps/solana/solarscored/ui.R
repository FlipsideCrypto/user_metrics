# SolarScored leaderboard
fluidPage(
	title = 'SolarScored',
	tags$head(
		tags$link(rel = 'stylesheet', type = 'text/css', href = 'shiny.css'),
		tags$link(rel = 'stylesheet', href = 'https://fonts.googleapis.com/css?family=Roboto+Mono'),
		tags$link(rel = 'stylesheet', href = 'https://fonts.googleapis.com/css?family=Inter')
	),
	tags$style(
		type='text/css',
		'.shiny-output-error { visibility: hidden; size: 0.1em}',
		'.shiny-output-error:before { visibility: hidden; size: 0.1em}'
	),
	# LINK to mixpanel
	tags$head(tags$script(src = 'mixpanel.js')),
	# SUPPRESS loading warnings/errors
	withTags({
		header(
			class='top-banner',
			section(
				a(
					class='fs-logo'
					, href='https://www.flipsidecrypto.com'
					, img(src = 'newlogo.svg')
					, onclick = "mixpanel.track('lts-click-logo-icon')"
				)
				, section(
					class='socials'
					, a(class='twitter', target = '_blank', href='https://twitter.com/flipsidecrypto', 'Twitter', onclick = "mixpanel.track('lst-click-twitter-icon')")
					, a(class='linkedin', target = '_blank', href='https://www.linkedin.com/company/flipside-crypto', 'LinkedIn', onclick = "mixpanel.track('lts-click-linkedin-icon')")
					, a(class='discord', target = '_blank', href='https://flipsidecrypto.com/discord', 'Discord', onclick = "mixpanel.track('lts-click-discord-icon')")
					, a(href='https://app.flipsidecrypto.com/auth/signup/velocity', target = '_blank', 'Sign Up', onclick = "mixpanel.track('lts-click-signup-icon')")
				)
			)
		)
	}),
	useShinyjs(),
	fluidRow(class = 'titles', 'SolarScored Rankings'),
	fluidRow(class = 'description', 'Some descriptive stuff'),
	br(),
	fluidRow(class = 'description', textOutput('title_sentence')),
	br(),
	fluidRow(
		class = 'wrapper',
		column(
			5,
			fluidRow(class = 'choose', 'Select a score range (0 to 35) to subset addresses'),
			fluidRow(
				div(
					style = 'margin: auto; width: 90%;'
					, sliderInput(inputId = 'scorethreshold', label = NULL, min = 1, max = 35, value = c(5, 25), width = '100%')
				)
			)
			, fluidRow(
				a(
					downloadButton(
						'download_scores_metrics'
						, label = 'Download Scores & Metrics'
						, icon = icon('arrow-down')
						, onclick = "mixpanel.track('lts-download-scores')")
				)
			)
		)
		, column(
			7
			, plotlyOutput('scoreplot', height = '200px')
		)
	), # close wrapper
	br(),
	
	fluidRow(
		class = 'wrapper'
		, fluidRow(
			column(
				7
				, div(class = 'toppad', 'Enter an Address or pick one from the Leaderboard')
				, uiOutput('inputaddy')
				, column(
					5
					, div(class = 'userscore', 'Score'
					, br()
					, textOutput('user_score')
					, textOutput('vs_mean'))
				)
			)
		)
		, br()
		, 'Leaderboard Summary'
		, fluidRow(
			class = 'doesscroll'
			, tags$table(
				tags$tr(
					tags$th(
						'LONGEVITY'
						, div(class = 'catscore', uiOutput('activity'))
					)
					, tags$th(
						'ACTIVITY'
						, div(class = 'catscore', uiOutput('governance'))
					)
					, tags$th(
						'GOVERNANCE'
						, div(class = 'catscore', uiOutput('degeneracy'))
					)
					, tags$th(
						'BRIDGING'
						, div(class = 'catscore', uiOutput('cash_out_vs_hodl'))
					)
					, tags$th(
						'STAKING'
						, div(class = 'catscore', uiOutput('airdrops'))
					)
					, tags$th(
						'EXPLORING'
						, div(class = 'catscore', uiOutput('explorer'))
					)
				),
				tags$tr(
					tags$td(
						id = 'longevity_1_div'
						, div(
							class='outerDiv'
							, div(class = 'leftDiv', 'Newbie')
							, div(class = 'rightDiv', div(class='hidey', id = 'longevity_1_c', img(src = 'badge_1.svg', width = '20px', height = '20px')))
						)
						, br()
						, div(textOutput('longevity_1'))
					)
					, tags$td(
						id = 'activity_1_div'
						, div(
							class='outerDiv'
							, div(
								class = 'leftDiv'
								, 'Occasional'
							)
							, div(class = 'rightDiv', div(class='hidey', id = 'activity_1_c', img(src = 'badge_1.svg', width = '20px', height = '20px')))
						)
						, br()
						, div(textOutput('activity_1'))
					)
					, tags$td(
						id = 'governor_1_div'
						, div(
							class='outerDiv'
							, div(class = 'leftDiv', 'Gov Degen')
							, div(class = 'rightDiv', div(class='hidey', id = 'governor_1_c', img(src = 'badge_1.svg', width = '20px', height = '20px')))
						)
						, br()
						, div(textOutput('governor_1'))
					),
					tags$td(id = 'bridgor_1_div', 
						div(class='outerDiv', 
								div(class = 'leftDiv', 'Bridgor'), 
								div(class = 'rightDiv', div(class='hidey', id = 'bridgor_1_c', img(src = 'badge_1.svg', width = '20px', height = '20px')))),
						br(),
						div(textOutput('bridgor_1'))),
					tags$td(id = 'staker_1_div', 
						div(class='outerDiv', 
								div(class = 'leftDiv', 'Stakor'), 
								div(class = 'rightDiv', div(class='hidey', id = 'staker_1_c', img(src = 'badge_1.svg', width = '20px', height = '20px')))),
						br(),
						div(textOutput('staker_1'))),
					tags$td(id = 'explorer_1_div', 
						div(class='outerDiv', 
								div(class = 'leftDiv', 'Exploror'), 
								div(class = 'rightDiv', div(class='hidey', id = 'explorer_1_c', img(src = 'badge_1.svg', width = '20px', height = '20px')))),
						br(),
						div(textOutput('explorer_1')))
				),
				tags$tr(
					tags$td(
						id = 'longevity_2_div'
						, div(
							class='outerDiv'
							, div(class = 'leftDiv', 'Experienced')
							, div(class = 'rightDiv', div(class='hidey', id = 'longevity_2_c', img(src = 'badge_2.svg', width = '20px', height = '20px')))
						)
						, br()
						, div(textOutput('longevity_2'))
					)
					, tags$td(
						id = 'activity_2_div'
						, div(
							class='outerDiv'
							, div(
								class = 'leftDiv'
								, 'Active'
							)
							, div(class = 'rightDiv', div(class='hidey', id = 'activity_2_c', img(src = 'badge_2.svg', width = '20px', height = '20px')))
						)
						, br()
						, div(textOutput('activity_2'))
					)
					, tags$td(
						id = 'governor_2_div'
						, div(
							class='outerDiv'
							, div(class = 'leftDiv', 'Solana Activist')
							, div(class = 'rightDiv', div(class='hidey', id = 'governor_2_c', img(src = 'badge_2.svg', width = '20px', height = '20px')))
						)
						, br()
						, div(textOutput('governor_2'))
					),
					tags$td(id = 'bridgor_2_div', 
						div(class='outerDiv', 
								div(class = 'leftDiv', 'Bridgooor'), 
								div(class = 'rightDiv', div(class='hidey', id = 'bridgor_2_c', img(src = 'badge_2.svg', width = '20px', height = '20px')))),
						br(),
						div(textOutput('bridgor_2'))),
					tags$td(id = 'staker_2_div', 
						div(class='outerDiv', 
								div(class = 'leftDiv', 'Stakooor'), 
								div(class = 'rightDiv', div(class='hidey', id = 'staker_2_c', img(src = 'badge_2.svg', width = '20px', height = '20px')))),
						br(),
						div(textOutput('staker_2'))),
					tags$td(id = 'explorer_2_div', 
						div(class='outerDiv', 
								div(class = 'leftDiv', 'Explorooor'),
								div(class = 'rightDiv', div(class='hidey', id = 'explorer_2_c', img(src = 'badge_2.svg', width = '20px', height = '20px')))),
						br(),
						div(textOutput('explorer_2')))
				),
				tags$tr(
					tags$td(
						id = 'longevity_3_div'
						, div(
							class='outerDiv'
							, div(class = 'leftDiv', 'Grizzled Veteran')
							, div(class = 'rightDiv', div(class='hidey', id = 'longevity_3_c', img(src = 'badge_3.svg', width = '20px', height = '20px')))
						)
						, br()
						, div(textOutput('longevity_3'))
					)
					, tags$td(
						id = 'activity_3_div'
						, div(
							class='outerDiv'
							, div(
								class = 'leftDiv'
								, 'Unhinged'
							)
							, div(class = 'rightDiv', div(class='hidey', id = 'activity_3_c', img(src = 'badge_3.svg', width = '20px', height = '20px')))
						)
						, br()
						, div(textOutput('activity_3'))
					)
					, tags$td(
						id = 'governor_3_div'
						, div(
							class='outerDiv'
							, div(class = 'leftDiv', 'Rock the Vote')
							, div(class = 'rightDiv', div(class='hidey', id = 'governor_3_c', img(src = 'badge_3.svg', width = '20px', height = '20px')))
						)
						, br()
						, div(textOutput('governor_3'))
					),
					tags$td(id = 'bridgor_3_div', 
						div(class='outerDiv', 
								div(class = 'leftDiv', 'Bridgooooor'), 
								div(class = 'rightDiv', div(class='hidey', id = 'bridgor_3_c', img(src = 'badge_3.svg', width = '20px', height = '20px')))),
						br(),
						div(textOutput('bridgor_3'))),
					tags$td(id = 'staker_3_div', 
						div(class='outerDiv', 
								div(class = 'leftDiv', 'Stakooooor'), 
								div(class = 'rightDiv', div(class='hidey', id = 'staker_3_c', img(src = 'badge_3.svg', width = '20px', height = '20px')))),
						br(),
						div(textOutput('staker_3'))),
					tags$td(id = 'explorer_3_div', 
						div(class='outerDiv', 
								div(class = 'leftDiv', 'Explorooooor'), 
								div(class = 'rightDiv', div(class='hidey', id = 'explorer_3_c', img(src = 'badge_3.svg', width = '20px', height = '20px')))),
						br(),
						div(textOutput('explorer_3')))
				),
					) # close table
					) # close table row
	), # close wrapper
	lapply(score_criteria$metric_name, function(i) {
		
	  score.info <- score_criteria[metric_name == i]
		
	  tmp.title <- paste0(
	    score.info$score_description, '<hr>',
	    'Difficulty: ', c('Easier', 'Harder', 'Degen Only')[score.info$points], '<br>',
	    'Points Value: ', score.info$points, '<hr>',
	    'Data Metric Name: ', score.info$metric_name)
		
	  shinyBS::bsTooltip(id = i, 
	                     title = tmp.title)
	}),
	br(),
	
	fluidRow(class = 'wrapper',
					 div(class = 'boldwhite', 'Leaderboard for Selected Addresses'), br(),
					 div(class = 'subtitle', 'Click a row to explore an address. Click a column to sort by that Category.'),
					 reactableOutput('cat_scores_table'), br(),
					 fluidRow(class = 'downloadrow', a(downloadButton('download_all_data', 
																	 label = 'Download Raw Data by Address (~175MB)', icon = icon('arrow-down'), 
																	 onclick = "mixpanel.track('lts-download-all')")))),
	br(),br(),
	fluidRow(class = 'wrapper',
					 div(class = 'boldwhite', 'More About this App'),
					 br(),
					 div(class = 'disclaimer', "This app was created to showcase 15 behaviors that we associate with positive contribution to the Terra ecosystem.
							 These are certainly not the only ways that an address can contribute to the ecosystem, so we encourage you to DYOR. We've made all of
							 our data available, ether through the download links above, or if you want to go deeper, we have linked to every query used to create
							 this leadearboard in the table below. Note that there are ~700k addresses in the full data file as it includes addresses that scored 0 but still
							 had enough activity to show up in the calculation of at least one metric. The data refreshes once every two hours."),
					 br(),
					 div(class = 'disclaimer', 'We love geeking out on methodology and data, so if you have questions or ideas please visit us on our
							 discord. Thanks for stopping by SolarScored!'),
					 br(),
					 div(class = 'subtitle', 'Metric Details + Query Links'),
					 reactableOutput('metric_defs')
	),
	br(), br(), br(), br()
	
) # close fluid page










