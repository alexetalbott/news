shinyServer(function(input, output, session) {
  
  output$mymap <- renderLeaflet({
    
    mapdata <- data %>% filter(state_name == input$state_selection) 
    
    map_this<- tm_shape(mapdata, projection = 2163) + 
      tm_borders() + 
      tm_fill(col = "county_papercount_group",
              id = "county",
              popup.vars = c("Pop.: " = "population",
                             "Newspapers: " = "county_newspaper_quantity_2019",
                             "Avg. Circulation: " = "avg_circulation_2019")) + 
      tm_style("albatross")
    
    tmap_leaflet(map_this)
  })

  output$maptable <- renderTable({

    tabledata <- state_stats %>% filter(state_name == input$state_selection) %>% 
      mutate(
        total_newspapers_per_state = round(total_newspapers_per_state,0),
        state_counties_zero_papers = round(state_counties_zero_papers,0)
      ) %>%
      rename(
        State = state_name,
        'Average Newspapers Per County' = avg_newspapers_per_county_by_state,
        'Total Newspapers' = total_newspapers_per_state,
        'How Many Counties with Zero Newspapers?' = state_counties_zero_papers
      )

    
    tabledata
  })
  
  ## tab 2
  output$tilemap <- renderPlotly({
  plot_this <- plot_ly(tiles_sf, split = ~name, text=~paste(name,":",round(tilegramValue,1)), hoveron="fills",hoverinfo="text", showlegend=FALSE)
  plot_this
  })
  
  output$tiletable <- DT::renderDataTable({
    
    tabledata <- state_stats %>% 
      rename(
        State = state_name,
        'Average Newspapers Per County' = avg_newspapers_per_county_by_state,
        'Total Newspapers' = total_newspapers_per_state,
        'How Many Counties with Zero Newspapers?' = state_counties_zero_papers
      )
    
    
    tabledata
  })
  

  
})
