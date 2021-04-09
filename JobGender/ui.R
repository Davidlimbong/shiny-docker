library(shiny)
library(shinydashboard)
library(DT)

shinyUI(
    
    dashboardPage(skin = "black",
        dashboardHeader(title = "Job Gender"),
        dashboardSidebar(
            sidebarMenu(
                menuItem(text = "Dashboard", tabName = "menu1", icon = icon("dashboard")),
                menuItem(text = "Data", tabName = "menu2", icon = icon("th"))
            )
        ),
        dashboardBody(
            tabItems(
                tabItem(tabName = "menu1",
                        fluidRow(
                            valueBox(value = workers_clean$occupation %>% 
                                         unique() %>% 
                                         length(),
                                     subtitle = "Total of Occupations" , 
                                     icon = icon("address-card")
                            ),
                            # jumlah minor category
                            valueBox(value = workers_clean$minor_category %>% 
                                         unique() %>% 
                                         length(), 
                                     subtitle = "Total of Minor Category", 
                                     icon = icon("user"), 
                                     color = "orange"),
                            # jumlah major category
                            valueBox(value = workers_clean$major_category %>%
                                          unique() %>% 
                                          length(), 
                                      subtitle = "Total of Major Category",
                                      icon =icon("address-card"), color = "red")
                        ),
                        fluidRow(
                            box(width = 4,
                                selectInput(inputId = "major1", 
                                            label = "Major Category", 
                                            choices = unique(workers_clean$major_category), 
                                            selected = "Sales and Office")
                            )
                            
                        ),
                        fluidRow(
                            box(
                                plotlyOutput(outputId = "plot_dense")
                            ),
                            box(
                              plotlyOutput(outputId = "plot_line")  
                            )
                        )
                       
                        ),
                tabItem(tabName = "menu2",
                        fluidRow(
                            box(width = 12,
                                DT::dataTableOutput("data_job")
                            )
                        )
                        )
            )
        )
    )


)
