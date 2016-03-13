library(shiny)
library(httr)
library(rjson)


################################
######## get artist ############
################################



getArtists<-function(artists) {
  
    out<-NULL
    for (i in c(1:length(artists))) {
 
      url<-paste0("https://api.spotify.com/v1/search?q=", gsub(" ", "%20", artists[i]), "&type=artist")
      search<-content(GET(url))
      temp<-data.frame(
        artist=search$artists$items[[1]]$name,
        artist_id=search$artists$items[[1]]$id,
        artist_pop=search$artists$items[[1]]$popularity
      )
      rownames(temp)<-NULL
      out<-rbind(out, temp)
    }
    
  return(out)
}



################################
######## get albums ############
################################




getArtistsAlbums<-function(getArtistsOutput, country="GB", albumType="album", cleanDups=TRUE) {
  
  
    
    albums<-data.frame(artist=NULL,artist_id=NULL,album=NULL, album_id=NULL)
    for (i in c(1:nrow(getArtistsOutput))) {
      url<-paste0("https://api.spotify.com/v1/artists/", getArtistsOutput[i,2], "/albums?album_type=", albumType, "&limit=50&country=", country)
      list<-content(GET(url))
      for (j in c(1:length(list$items))){
        temp<-data.frame(
          artist=getArtistsOutput[i,1],
          artist_id=getArtistsOutput[i,2], 
          album=list$items[[j]]$name,
          album_id=list$items[[j]]$id
        )
        albums<-rbind(albums, temp)
      }
    }  

  if (cleanDups==TRUE){albums<-albums[!duplicated(albums$album), ]}
  return(albums)
}


################################
####### get tracks #############
################################


getAlbumsTracks<-function(getArtistsAlbumsOutput) {
  
#   if (Sys.info()[1]=="Windows"){  
    
    albumtracks<-data.frame(artist=NULL,artist_id=NULL,album=NULL, album_id=NULL, track=NULL, track_id=NULL, track_number=NULL, track_length=NULL, preview_url=NULL)
    
    for (i in c(1:nrow(getArtistsAlbumsOutput))) {
      url<-paste0("https://api.spotify.com/v1/albums/", getArtistsAlbumsOutput[i,4], "/tracks?limit=50")
      list<-content(GET(url))
      
      for (j in c(1:length(list$items))){
        temp<-data.frame(
          artist=getArtistsAlbumsOutput[i,1],
          artist_id=getArtistsAlbumsOutput[i,2], 
          album=getArtistsAlbumsOutput[i,3], 
          album_id=getArtistsAlbumsOutput[i,4],          
          track=list$items[[j]]$name,
          track_id=list$items[[j]]$id,
          track_number=list$items[[j]]$track_number,
          track_length=format(.POSIXct(list$items[[j]]$duration_ms/1000,tz="GMT"), "%M:%S"),
          preview_url=ifelse(is.null(list$items[[j]]$preview_url), "NO PREVIEW", list$items[[j]]$preview_url)
        )
        albumtracks<-rbind(albumtracks, temp)
      }
    }  
  
  return(albumtracks)
}



################################
####### reformat data ##########
################################


jsonNestedData<-function(structure, values=NULL, top_label="Top") {
  
  if (is.null(values)) {
    
    #bottom level   
    labels<-data.frame(table(structure[,ncol(structure)-1]))
    for (i in c(1:nrow(labels))) {
      items<-structure[structure[,ncol(structure)-1]==labels[i,1],ncol(structure)]
      eval(parse(text=paste0(gsub(" ", "_",gsub("[[:punct:][:digit:]]","A",labels[i,1])),"<-list(name=\"", labels[i,1], "\", children=list(", paste0("list(name=as.character(items[", c(1:length(items)), "]))", collapse=","),  "))")))
    }
    
    #iterate through other levels
    for (c in c((ncol(structure)-2):1)) {
      labels<-data.frame(table(structure[,c]))        
      lookup<-data.frame(table(structure[,c], structure[,c+1]))
      lookup2<-lookup[lookup$Freq!=0,]
      for (i in c(1:nrow(labels))) {
        eval(parse(text=paste0(gsub(" ", "_",gsub("[[:punct:]]","",labels[i,1])),
                               "<-list(name=\"", 
                               labels[i,1], 
                               paste0("\", children=list(", 
                                      paste0(gsub(" ", "_", gsub("[[:punct:][:digit:]]","A",lookup2[lookup2$Var1==labels[i,1],2])), collapse=","), ")"),
                               ")")
        ))
      }
    }
    
    #final top level
    labels<-data.frame(table(structure[,1]))
    eval(parse(text=paste0("Top<-list(name=\"", top_label,"\" , children=list(", paste(gsub(" ", "_",gsub("[[:punct:]]","",labels[i,1])), collapse=","), ")",")")))           
    
  } else {
    
    
    
    #bottom level   
    labels<-data.frame(table(structure[,ncol(structure)-1]))
    for (i in c(1:nrow(labels))) {
      items<-structure[structure[,ncol(structure)-1]==labels[i,1],ncol(structure)]
      vals<-values[structure[,ncol(structure)-1]==labels[i,1]]
      eval(parse(text=paste0(gsub(" ", "_",gsub("[[:punct:][:digit:]]","A",labels[i,1])),"<-list(name=\"", labels[i,1], "\", children=list(", paste0("list(name=as.character(items[", c(1:length(items)), "]), value=vals[",c(1:length(items)),"])", collapse=","),  "))")))
    }
    
    #iterate through other levels
    for (c in c((ncol(structure)-2):1)) {
      labels<-data.frame(table(structure[,c]))        
      lookup<-data.frame(table(structure[,c], structure[,c+1]))
      lookup2<-lookup[lookup$Freq!=0,]
      for (i in c(1:nrow(labels))) {
        eval(parse(text=paste0(gsub(" ", "_",gsub("[[:punct:]]","",labels[i,1])),
                               "<-list(name=\"", 
                               labels[i,1], 
                               paste0("\", children=list(", 
                                      paste0(gsub(" ", "_",gsub("[[:punct:][:digit:]]","A", lookup2[lookup2$Var1==labels[i,1],2])), collapse=","), ")"),
                               ")")
        ))
      }
    }
    
    #final top level
    labels<-data.frame(table(structure[,1]))
    eval(parse(text=paste0("Top<-list(name=\"", top_label,"\" , children=list(", paste(gsub(" ", "_", labels[,1]), collapse=","), ")",")")))           
    
  }
  
  out<-list(totaltracks=nrow(structure), discog=Top)
  
  json<-toJSON(out)
  return(list(Type="json:nested", json=json))
}