#
# Developed by : Rahul Singhania
# 
#Load the packages
library(shiny)
library(dplyr)
library(DT)
library(shinythemes)
library(emojifont)

#Read the movie data from a csv file
moviedata <- readxl::read_excel("Movie.xlsx")
attach(moviedata)

#Read the TV data from a csv file
tvdata <- readxl::read_excel("TV.xlsx")
attach(tvdata)

#Extract Max Runtime for a movie, to be used later as an upper limit in input options
max_rt <- max(moviedata$Runtime_Min)

ui <- fluidPage(
  #Application Theme
  theme = shinytheme("spacelab"),
  # Application title
  titlePanel("Bored Panda"),
  h5("Made with", emoji("heart")," by Rahul"),
  br(),
  br(),
  br(),
  sidebarLayout(
    sidebarPanel(
      h3("Search Parameters"),  
      selectInput(inputId = "choice",
                  label = "Movie/TV Show",
                  choices = c("Movie" = 1,
                              "TV Show" = 2
                              ),
                  selected = 1
                  
      ),
      selectInput(inputId = "rating",
                  label = "IMDB Rating",
                  choices = c("1 and above" = 1.0,
                              "2 and above" = 2.0,
                              "3 and above" = 3.0,
                              "4 and above" = 4.0,
                              "5 and above" = 5.0,
                              "6 and above" = 6.0,
                              "7 and above" = 7.0,
                              "8 and above" = 8.0,
                              "9 and above" = 9.0),
                  selected = 8.0
      ),
      h5("Select the year range to search within a range of years"),
      
      numericInput(inputId = "styear",
                  label = "Start Year",
                  min = 1950,
                  max = 2018,
                  value = 1950,
                  step = 1
                  ),
      
      numericInput(inputId = "enyear",
                   label = "End Year",
                   min = 1950,
                   max = 2018,
                   value = 2018,
                   step = 1
                   ),
      
      checkboxInput( inputId = "get_year",
                     label = "Apply",
                     value = FALSE
      ),
      
      selectInput(inputId = "genre",
                  label = "Genre",
                  choices = c(
                  "Action",
                  "Adult",
                  "Adventure",
                  "Animation",
                  "Biography",
                  "Comedy",
                  "Crime",
                  "Documentary",
                  "Drama",
                  "Family",
                  "Fantasy",
                  "FilmNoir",
                  "GameShow",
                  "History",
                  "Horror",
                  "Music",
                  "Musical",
                  "Mystery",
                  "News",
                  "RealityTV",
                  "Romance",
                  "SciFi",
                  "Short",
                  "Sport",
                  "TalkShow",
                  "Thriller",
                  "War",
                  "Western"
                  ),
                multiple = TRUE  
                ),
      checkboxInput( inputId = "get_genre",
                     label = "Apply",
                     value = FALSE
      ),
      
      numericInput(inputId = "rt",
                   label = "Max Runtime",
                   min = 0,
                   max = max_rt,
                   value = 200,
                   step = 1
      ),
      width = 2
    ),
    mainPanel(
      dataTableOutput(outputId = "dispTable"),
      width = 10
    )
  )
)


server <- function(input, output) {
  
  output$dispTable <- renderDataTable({
    x <- moviedata
    #Choose between TV Show Data and Movie Data
    if(input$choice==1)
    {
      col = c(1,2,3,4,5,6,7,8,9,10)
      x <- moviedata
    }
    else
    {
      col = c(1,2,3,4,5,6,7,9)
      x<- tvdata
    }
    #If range of year of release is mentioned
    if(input$get_year)
    {
      #If genre is mentioned
      if(input$get_genre)
      {
        #Filter the data
        moviedata_genre <- dplyr::filter(x, grepl(input$genre, x$Genre))
        #Subset the data
        moviedata_genre_year<- moviedata_genre[moviedata_genre$Year>=input$styear & moviedata_genre$Year<=input$enyear & moviedata_genre$Rating>=input$rating & moviedata_genre$Runtime_Min<=input$rt,col]
        #Render
        DT::datatable(data = moviedata_genre_year, 
                      options = list(pageLength = 15), 
                      rownames = FALSE
                      ) 
      }
      #If genre is not avaialble
      else
      {
        #Subset the data
        moviedata_year<- x[x$Year>=input$styear & x$Year<=input$enyear & x$Rating>=input$rating & x$Runtime_Min<=input$rt,col]
        #Render the data
        DT::datatable(data = moviedata_year, 
                      options = list(pageLength = 15), 
                      rownames = FALSE) 
      }
    }
    #If range of release year is not mentioned
    else
    {
      #If genre is mentioned
      if(input$get_genre)
      {
        #Filter the data
        moviedata_genre <- dplyr::filter(x, grepl(input$genre, x$Genre))
        #Subset the data
        moviedata_genre<- moviedata_genre[moviedata_genre$Rating>=input$rating & moviedata_genre$Runtime_Min<=input$rt,col]
        #Render the data
        DT::datatable(data = moviedata_genre, 
                      options = list(pageLength = 15), 
                      rownames = FALSE) 
      }
      #Genre not mentioned
      else
      {
        #Subset the data
        moviedataOut<- x[x$Rating>=input$rating & x$Runtime_Min<=input$rt,col]
        #Render the data
        DT::datatable(data = moviedataOut, 
                      options = list(pageLength = 15), 
                      rownames = FALSE) 
      }
    }
  })
  
}

shinyApp(ui = ui, server = server)

