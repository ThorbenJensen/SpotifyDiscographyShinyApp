

shinyServer(
  function(input, output, session) {
        
    #event handler for when action button is clicked
  	observeEvent(input$run,{
      
  	  #extract artist from text input
  		artist<-input$artist
  		#hit apis to gather tracks
      tracks<-try(getAlbumsTracks(getArtistsAlbums(getArtists(artist))), silent=TRUE)
      
      #if the above has errored return error message
  		if(inherits(tracks, "try-error")){
  		  
  		    output$artist<-renderText(paste0("Artist Error: ", artist))
  		    session$sendCustomMessage(type="jsondata","")
  		  
  		    } else {
  		  
  		    #else process the data  
  		    output$artist<-renderText(paste0("Discography: ", tracks$artist[1]))
    		  #format data
    		  json<-jsonNestedData(structure=tracks[,c(1,3,5)], values=tracks[,9], top_label="Discography")
      		var_json<-json$json
      		#push data into d3script
      		session$sendCustomMessage(type="jsondata",var_json)
  		}

  		})

  }
)