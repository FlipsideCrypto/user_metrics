function(input, output, session) {
	
	plotly.style <- list(
		fig_bgcolor = 'rgb(255, 255, 255)', 
		plot_bgcolor = 'rgba(0, 0, 0, 0)', 
		paper_bgcolor = 'rgba(0, 0, 0, 0)',
		font = list(
			color = '#FFF', family = 'Roboto Mono')
	)
	
	output$inputaddy <- renderUI({
		url.addy <- parseQueryString(session$clientData$url_search)
		print('url.addy')
		print(url.addy)
		
		if(length(url.addy) > 0) {
			default.addy <- names(url.addy)[1]
		} else {
			default.addy <- NA
		}
		
		if(is.na(default.addy)) {
			textInput(
				inputId = 'addy'
				, label = NULL
				, width = '100%'
				, placeholder = 'a Solana address'
			)
		} else {
			textInput(
				inputId = 'addy'
				, label = NULL
				, width = '100%'
				, value = default.addy
			)
		}
		
	})
	
	# observeEvent(input$address, {
	# 	if(!is.null(input$address)) {
	# 		if(substr(input$address, 1, 5) == 'terra') {
	# 			updateTextInput(session, 'addy', value = input$address)
	# 		}
	# 	}
	# })
	
	observeEvent(input$addy, {
		if(!is.null(input$address)) {
			if(input$addy == input$address) {
				updateActionButton(session = session, inputId = 'connect', label = 'Disconnect')
			} else {
				updateActionButton(session = session, inputId = 'connect', label = 'Connect Wallet')
			}
		}
	})
	
	inRangeScores <- reactive(
		df[ total_score >= input$scorethreshold[1] & total_score <= input$scorethreshold[2]]
	)
	inRangeMetricScores <- reactive(
		df[ total_score >= input$scorethreshold[1] & total_score <= input$scorethreshold[2]]
		# metric.score.data[`Total Score` >= input$scorethreshold[1] & `Total Score` <= input$scorethreshold[2]]
	)
	
	output$title_sentence <- renderText({
		paste0('Rankings for ',
					#  format(n.scores, big.mark = ','),
					 ' Solana addresses scored across 21 metrics in 7 categories.')
	})
	
	output$scoreplot <- renderPlotly({
		plot.data <- df %>% group_by(total_score) %>% summarize( N=n() ) %>% as.data.table()
		plot.data <- plot.data[ total_score >= input$scorethreshold[1] & total_score <= input$scorethreshold[2]]
		
		plot.data[, color_group := ifelse(total_score >= input$scorethreshold[1] & total_score <= input$scorethreshold[2], 'in', 'out')]
		
		fig <- plot_ly(
			data = plot.data[total_score > 0]
			, x = ~total_score
			, y = ~N
			, color = ~color_group
			, type = 'bar'
			, colors = c('#5494F8', '#dddddd')
		)

		# fig <- fig %>% add_annotations(
		# 	x=28,
		# 	y=80000,
		# 	xref = 'x',
		# 	yref = 'y',
		# 	text = paste0(format(nrow(df), big.mark=',', scientific=FALSE), ' <br>addresses selected'),
		# 	xanchor = 'right',
		# 	showarrow = F,
		# 	font = list(size = 20, color = '#5494F8', family = 'Roboto Mono')
		# )
		
		fig <- fig %>% layout(
			xaxis = list(
				title = ''
				, showgrid = FALSE
				, fixedrange = TRUE
				, color = '#C4CDD5'
			)
			, yaxis = list(
				title = ''
				, showticklabels = TRUE
				, showgrid = TRUE
				, fixedrange = TRUE
				, gridwidth = 0.5
				, color = '#C4CDD5'
				, gridcolor = '#202933'
			)
			, showlegend = FALSE
			, plot_bgcolor = plotly.style$plot_bgcolor
			, paper_bgcolor = plotly.style$paper_bgcolor
		) %>%
		plotly::config(displayModeBar = FALSE) %>%
		plotly::config(modeBarButtonsToRemove = c('zoomIn2d', 'zoomOut2d'))

		fig
	})
	
	# lapply(unique(score_criteria$category), function(tmp.category) {
	#   cat.name.fix <- tolower(gsub(x = tmp.category, pattern = ' ', '_', fixed = TRUE))
	#   output[[cat.name.fix]] <- renderText({
	#     if(is.null(input$addy) | input$addy == '') {
	#       paste0('avg score: ', sprintf('%.1f', round(mean(inRangeScores()[[tmp.category]]), 1)))
	#     } else {
	#       paste0('score: ',
	#              scores[address == input$addy][[tmp.category]],
	#              ' (avg ', 
	#              sprintf('%.1f', round(mean(inRangeScores()[[tmp.category]]), 1)),
	#              ')')
	#     }
	#   })
	# })
	
	lapply(score_criteria$metric_name, function(metric) {
	  output[[metric]] <- renderText({
	    paste0(format(sum(inRangeMetricScores()[[metric]] > 0), big.mark=',', scientific=FALSE), ' addresses')
	  })
	})
	
	# now change the colors of the score boxes:
	observeEvent(input$addy, {
		
	  lapply(score_criteria$metric_name, function(tmp.metric) {
	    # change.class <- metric.score.data[address == input$addy][[tmp.metric]] > 0
	    change.class <- df[user_address == input$addy][[tmp.metric]] > 0

	    if(length(change.class) == 0) change.class <- FALSE
		print('tmp.metric')
		print(tmp.metric)
		print(change.class)
	    toggleClass(id = paste0(tmp.metric, '_div'), 
	                class = 'bright',
	                condition = change.class)
	    toggleClass(id = paste0(tmp.metric, '_c'), 
	                class = 'showey',
	                condition = change.class)
			
	  })
	})
	
	output$user_score <- renderText({
		print('input$addy')
		print(input$addy)
		if(!length(input$addy)) {
			paste0(0, '/42')
		} else {
			cur <- df[ (user_address == input$addy) ]
			score <- ifelse(nrow(cur) > 0, cur$total_score[1], 0)
			paste0(score, '/42')
		}
	})
	
	
	
	output$vs_mean <- renderText({paste0('vs. Mean Score of ', round(mean(inRangeScores()[['total_score']]), 1))})
	
	getTableData <- reactive(inRangeScores()[order(-total_score)][1:500])
	
	output$cat_scores_table <- renderReactable({
		reactable(
			getTableData()[, list(
				address = paste0(substr(user_address, 1, 12), '...')
				, score = total_score
				, longevity = longevity
				, activity = activity
				, governor = governor
				, bridgor = bridgor
				, staker = staker
				, explorer = explorer
			)]
			, onClick = 'select'
			, selection = 'single'
			, rowStyle = JS(
				"function(rowInfo) {
					if (rowInfo && rowInfo.selected) {
						return { backgroundColor: '#172852' }
					}
				}"
			), defaultColDef = colDef( headerStyle = list(background = '#10151A') )
			, borderless = TRUE
			, outlined = FALSE
			, columns = list(
				address = colDef(name = 'Address', minWidth = 165, align = 'left'),
				score   = colDef(name = 'Score', align = 'right'),
				longevity     = colDef(name = 'longevity', align = 'right'),
				activity     = colDef(name = 'activity.', align = 'right'),
				governor   = colDef(name = 'governor.', align = 'right'),
				bridgor  = colDef(name = 'bridgor', align = 'right'),
				staker     = colDef(name = 'staker', align = 'right'),
				explorer     = colDef(name = 'explorer', align = 'right')
			)
		)
	})
	
	#observing the row selected in the table
	# to change the input address 
	tableSelected <- reactive(getReactableState('cat_scores_table', 'selected', session))
	
	
	output$selected <- renderPrint({
		print(getTableData()[tableSelected()]$address)
	})
	
	observeEvent(tableSelected(), {
		new.addy <- getTableData()[tableSelected()]$address
		if(length(new.addy) == 1) {
			updateTextInput(session, 'addy', value = new.addy)
		}
	})
	
	
	observeEvent(input$clearaddy, {
		updateTextInput(session, 'addy', value = '')
	})
	
	output$download_scores_metrics <- downloadHandler(
		filename = function() {
			paste('scores_', input$scorethreshold[1], '_to_', input$scorethreshold[2], '_', Sys.Date(), '.csv', sep='')
		},
		content = function(file) {
			to.download <- merge(inRangeScores(), inRangeMetricScores(), by = c('address', 'Total Score'))
			write.csv(to.download, file)
		}
	)
	
	addTooltip(session, id = 'net_from_shuttle_cex', 
						 title = paste0(
							 'Received more from Bridges or CEXs than sent (or 0 sent) in the last 90 days', '<hr>',
							 'Difficulty: Easier', '<br>',
							 'Points Value: 1', '<hr>',
							 'Data Metric Name: net_from_shuttle_cex'), 
						 placement = 'bottom', trigger = 'hover',
						 options = NULL)
	
	
	# table with links to queries:
	output$metric_defs <- renderReactable({
		
		reactable(score_criteria[, list(score_name, metric_name, points, score_description, velocity_query)],
		          defaultColDef = colDef(
		            #align = 'center',
		            headerStyle = list(background = '#10151A')
		          ),
		          defaultPageSize = 15,
		          pagination = FALSE,
		          borderless = TRUE,
		          outlined = FALSE,
		          #maxWidth = 100, 
		          columns = list(
		            score_name = colDef(name = 'Score Name', maxWidth = 150, align = 'left'),
		            metric_name = colDef(name = 'Metric Name', align = 'left'),
		            points = colDef(name = 'Points', maxWidth = 75, align = 'right'),
		            score_description = colDef(name = 'Score Description', align = 'left'),
		            velocity_query = colDef(name = 'Query', maxWidth = 75, align = 'left', cell = function(velocity_query) {
		              # Render as a link
		              url <- sprintf(paste0(velocity_query))
		              htmltools::tags$a(href = url, target = '_blank', 'link', onclick = "mixpanel.track('ae-click-velocity-link')")
		            }))
		)
	})
	
	output$make_toggle_button <- renderUI({
		actionButton(
			inputId = 'toggle_button',
			label = 'Show Table')
	})
	
	observeEvent(input$toggle_button, {
		
		toggleElement(
			id = 'metric_defs'
		)
		
		if(input$toggle_button[1] %% 2 == 0) {
			# change to collapse
			updateActionButton(inputId = 'toggle_button', label = 'Hide Table')
		} else {
			# change to expand
			updateActionButton(inputId = 'toggle_button', label = 'Show Table')
		}
		
	})
	
	output$download_all_data <- downloadHandler(
		filename <- function() {
			#'all_data.csv'
			ifelse(Sys.info()[['user']] == 'rstudio-connect',           
						 '/rstudio-data/lunatics_all_data.csv',
						 'all_data.csv')
		},
		
		content <- function(file) {
			file.copy('all_data.csv', file)
		},
		contentType = 'csv'
	)

}









