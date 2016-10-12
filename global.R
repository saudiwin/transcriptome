
# Variables that can be put on the x and y axes
axis_vars <- c(
	"avgCON" = "avgCON",
	"avgAFF" = "avgAFF",
	"log(a/c)" = "log(a/c)",
	"CV" = "CV",
	"N048" = "N048",
	"N068" = "N068",
	"N090" = "N090",
	"N098" = "N098",
	"L005" = "L005",
	"L137" = "L137",
	"L101" = "L101",
	"L062" = "L062",
	"L149" = "L149",
	"L140" = "L140",
	"L031" = "L031",
	"L072" = "L072",
	"L133" = "L133",
	"L074" = "L074",
	"L078" = "L078",
	"L102" = "L102",
	"L115" = "L115",
	"L027" = "L027",
	"avgAll" = "avgAll",
	"LENmRNA" = "LENmRNA"




)

# Helper functions from Rstudio Shiny's ref files for RSQLite

sqlitePath <- "SHINY.db"
table <- "GED_AB"

saveData <- function(data) {
  # Connect to the database
  db <- dbConnect(SQLite(), sqlitePath)
  # Construct the update query by looping over the data fields
  query <- sprintf(
    "INSERT INTO %s (%s) VALUES ('%s')",
    table, 
    paste(names(data), collapse = ", "),
    paste(data, collapse = "', '")
  )
  # Submit the update query and disconnect
  dbGetQuery(db, query)
  dbDisconnect(db)
}

loadData <- function() {
  # Connect to the database
  db <- dbConnect(SQLite(), sqlitePath)
  # Construct the fetching query
  query <- sprintf("SELECT * FROM %s", table)
  # Submit the fetch query and disconnect
  data <- dbGetQuery(db, query)
  dbDisconnect(db)
  data
}
