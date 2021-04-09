library(shiny)
library(glue)
library(DT)

shinyServer(function(input, output) {

   output$plot_dense <- renderPlotly({
       
       # Praproses data
       data_agg1 <- workers_clean %>% 
           filter(major_category == input$major1) %>% 
           select(major_category, total_earnings_female, total_earnings_male) %>% 
           pivot_longer(cols = -major_category, 
                        names_prefix = "total_earnings_", 
                        names_to = "gender", 
                        values_to = "total_earnings") 
       
       # visualisasi
       plot1 <- ggplot(data_agg1, aes(x = total_earnings)) +
           geom_density(aes(fill = gender)) +
           scale_fill_brewer(palette = "Set1") +
           scale_x_continuous(labels = dollar_format()) +
           labs(title = "Distribution of Total Income by Gender",
                x = NULL, 
                fill = NULL) +
           theme_minimal()
       
       # Interacive
       ggplotly(plot1, tooltip = "none") %>% 
           config(displayModeBar = F) %>% 
           layout(legend = list(
               orientation = "h", 
               y = -0.05
           )
           )
       
       
   })
   output$plot_line <- renderPlotly({
       
       #Praproses Data
       data_agg2 <- workers_clean %>% 
           filter(major_category == input$major1) %>% 
           group_by(year,major_category, minor_category) %>% 
           summarise(avg_percent = mean(percent_female)) %>% 
           ungroup()
       
       # Visualisasi
       plot2 <- ggplot(data_agg2, aes(x = year,
                                      y = avg_percent/100, 
                                      col = minor_category)) +
           geom_line() +
           geom_point(aes( text = glue("Minor Category: {minor_category}
                                    Average: {round(avg_percent,1)}%")))+
           theme_minimal() +
           theme(legend.position = "none") +
           scale_color_brewer(palette = "Set1") +
           scale_y_continuous(labels = percent_format()) +
           labs(title = "Average Percentage of Female Workers in each Minor Category Each Year", 
                y = NULL, 
                x = NULL)
       
       # Interactive
       ggplotly(plot2, tooltip = "text") %>% 
           config(displayModeBar = F)
   })
   
   output$data_job <- DT::renderDataTable({
       
       DT::datatable(workers_clean,options = list(scrollX = TRUE))
       
   })
   
   
   
   
   

})
