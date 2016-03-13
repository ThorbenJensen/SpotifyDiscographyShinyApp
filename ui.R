

shinyUI(fixedPage(
  br(),
  titlePanel("Spotify Artist Interactive Discography"),
  hr(),
  sidebarLayout(
    sidebarPanel(width=3,
      
      img(src="Spotify-logo.png", height = 97, width = 93),
      br(), br(),
      textInput("artist", "Enter Artist", placeholder="artist name..."),
      tags$head(tags$style(HTML('#run{background-color:#82bb40}'))),
      actionButton("run",label="Create Discography!", icon=icon("spotify")),
      br(), br(),
      p("Built using ", a("Shiny", href = "http://www.rstudio.com/shiny", target="_blank"), "from RStudio"),
      p("Data taken from the  ", a("Spotify", href = "https://developer.spotify.com/web-api/", target="_blank"), "API"),
      p("Created by James Thomson ", a("inspiration information", href = "http://myinspirationinformation.com/" , target="_blank"))
      
    ),
    mainPanel(
      #title
      #h3("Interactive Discography"),
      #hr(),
      fluidPage(column(width=3, offset=5,
                       conditionalPanel(condition="$('html').hasClass('shiny-busy')",
                                        p("Pulling from API.."),
                                        tags$img(src="busy.gif")
                       )                       
                       )),
      fluidPage(column(width=12, 
                       conditionalPanel(condition="!$('html').hasClass('shiny-busy')",
                                        h3(textOutput("artist")),
                                        #to style to d3 output pull in css
                                        tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "style.css")),
                                        #load D3JS library
                                        tags$script(src="https://d3js.org/d3.v3.min.js"),
                                        #load javascript
                                        tags$script(src="d3script.js"),
                                        #create div referring to div in the d3script
                                        tags$div(id="div_tree")
                       )                       
      ))
      
    )
  )
)) 