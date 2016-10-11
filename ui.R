library(ggvis)

# For dropdown menu
actionLink <- function(inputId, ...) {
  tags$a(href='javascript:void',
         id=inputId,
         class='action-button',
         ...)
}

shinyUI(fluidPage(
  titlePanel(
    a("SLE T cell Transcriptome Scatterplot", href="http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0141171", target = "_blank"),
    helpText("Note: while the data view will show only the specified",
               "number of observations, the summary will still be based",
               "on the full dataset.")
   ), 

  sidebarLayout(
    sidebarPanel(
      
      
      wellPanel(
        sliderInput("avgALL", "Expression Range (AVG FPKM)", 0, 16000, value = c(0, 16000), step = 2000),
        sliderInput("minavgAFF", "Minimum Affected Expression", 10, 1000, 100, step = 50),
        sliderInput("minavgCON", "Minimum Control Expression", 10, 1000, 100, step = 50),
        sliderInput("cv", "Coefficient of Variation (SD/AVG)", 0, 1, value = c(0, 1), step = .1),
        sliderInput("log", "Absolute Log2 Fold Change (AFF/CON)",0, 2, value = c(0.6,2), step = .2),
        sliderInput("LENmRNA", "mRNA Length Range", 100, 30000, value = c(100,30000), step = 500) 
      ),
      wellPanel(
        selectInput("xvar", "X-axis variable", axis_vars, selected = "avgCON"),
        selectInput("yvar", "Y-axis variable", axis_vars, selected = "avgAFF"),
        tags$small(paste0(
          " Peripheral T cells from 14 SLE patients and 4 healthy controls were subject",
          " to RNA purification and illumina sequencing. Reads were mapped using ",
          " TOPHAT and FPKM determined by CUFFLINKS. The raw sequence data has been ",
          " deposited at the Sequence Read Archive under Bioproject ",
          " Accession ID PRJNA293549."
        ))
      )
    ),
    mainPanel(
      ggvisOutput("plot1"),
      wellPanel(
        span("Number of genes selected:", textOutput("n_genes"))
      ),
      dataTableOutput(outputId="dt")
    )
  )  
))  