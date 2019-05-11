shinyUI(
  fluidPage(
    titlePanel("News Disappeared: Does Your County Have a Local Paper?"),
    #theme = shinytheme("united"),
    theme = "style.css",
      tabsetPanel(
        tabPanel("State Map",
                 sidebarLayout(
                   sidebarPanel(
                     selectInput(inputId = "state_selection", label = "Select a State", 
                                 choices=states_all,
                                 selected="Tennessee"),
                     width=2
                   )
                   ,
                   mainPanel(
                     fluidRow(
                       box(
                         leafletOutput("mymap",width=1450)
                       )
                     ),
                     br(),
                     br(),
                     fluidRow(
                       #box(
                         tableOutput("maptable")
                       #)
                      ),
                     br(),
                     br(),
                     fluidRow(
                     verbatimTextOutput("default")
                     #,verbatimTextOutput("placeholder", placeholder = TRUE)
                     )
                   ) # end of mainPanel
                 ) #end of sidebarLayout       
                ),
        tabPanel("tile cartogram",
                 sidebarLayout(
                   sidebarPanel(
                     prettyRadioButtons("radio", label = h3("Choose Tile Data"),
                                  choices = list("Average Papers Per County" = 1, "Total Newspapers" = 2), 
                                  selected = 1),
                     width=2
                   )
                   ,
                   mainPanel(
                     fluidRow(
                       box(
                         plotlyOutput("tilemap",width=1050)
                       )
                     ),
                     fluidRow(
                         DT::dataTableOutput("tiletable")
                     )
                   )
                 )       
                ) ## end of second tabPanel
              ) ## of main TabsetPanel
            ) ## end of fluidPage
          ) ## end of Shiny UI
