library(ggvis)
library(dplyr)
library(RSQLite)

# db <- src_sqlite("SHINY.db")
# GED_AB <- tbl(db, "GED_AB")

shinyServer(function(input, output, session) {
  

  # make the dataset its own reactive function to handle updates to the SQL table
  # On every input$submit click, first update the SQL table, then query the table and return
  
  GED_AB <- eventReactive(input$submit,({
    if(!is.null(input$datapath)) {
      read.csv(inFile$datapath, header=input$header, sep=input$sep, 
               quote=input$quote) %>% saveData()
    }
    output_db <- loadData() %>% as.tbl
    return(output_db)
  }),ignoreNULL = FALSE)

  genes <- reactive({
    	minavgALL <- input$avgALL[1]
    	maxavgALL <- input$avgALL[2]
    	minavgCON <- input$minavgCON
    	minavgAFF <- input$minavgAFF
    	minCV <- input$cv[1]
    	maxCV <- input$cv[2]
    	minLENmRNA <- input$LENmRNA[1]
    	maxLENmRNA <- input$LENmRNA[2]
 	    minLOG <- input$log[1]  
 	    maxLOG <- input$log[2]  

    m <- GED_AB() %>%
      filter(
        avgAll >= minavgALL,
        avgAll <= maxavgALL,
        avgCON >= minavgCON,
        avgAFF >= minavgAFF,
        CV >= minCV,
        CV <= maxCV,
        LENmRNA >= minLENmRNA,
        LENmRNA <= maxLENmRNA,
        abs(`log(a/c)`) >= minLOG,
        abs(`log(a/c)`) <= maxLOG) %>%
           arrange(avgAFF)

      m <- as.data.frame(m)

  })

  gene_tooltip <- function(x) {
    if (is.null(x)) return(NULL)
    if (is.null(x$pureENSG)) return(NULL)

    all_genes <- isolate(genes())
    gene <- all_genes[all_genes$pureENSG == x$pureENSG, ]
    paste0("<b>", gene$Symbol, "</b><br>", gene$pureENSG, "<br>",
           "AvgCON: ", gene$avgCON, "<br>", "avgAFF: ", gene$avgAFF,
           "<br>", "log(a/c): ", round(gene$`log(a/c)`,2))
  }

  vis <- reactive({
    xvar_name <- names(axis_vars)[axis_vars == input$xvar]
    yvar_name <- names(axis_vars)[axis_vars == input$yvar]

    xvar <- prop("x", as.symbol(input$xvar))
    yvar <- prop("y", as.symbol(input$yvar))

    genes %>%
      ggvis(x = xvar, y = yvar) %>%
      layer_points(size := 75, size.hover := 200, fill:= 490,
        fillOpacity := 0.4, fillOpacity.hover := 0.7, stroke := "black", strokeWidth := .2,
        key := ~pureENSG) %>%
      add_tooltip(gene_tooltip, "hover") %>%
      add_axis("x", title = xvar_name) %>%
      add_axis("y", title = yvar_name) 
  })

  vis %>% bind_shiny("plot1")

  output$n_genes <- renderText({ nrow(genes()) })

  output$dt <- renderDataTable(genes()[,1:5])
  
  
  # add a server-side download handler
  
  output$downloadData <- downloadHandler(
    
    # This function returns a string which tells the client
    # browser what name to use when saving the file.
    filename = 'transcriptome_data.csv',
    
    # This function should write data to a file given to it by
    # the argument 'file'.
    content = function(file) {
      # Write to a file specified by the 'file' argument
      # Reactive dependency on the filtered data file via the genes function
      # Note that downloadHandler only works in a real browser window
      
      write.csv(genes(), file,
                  row.names = FALSE)
    })
})
