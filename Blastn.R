if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("bio3d")
install.packages("openxlsx")
install.packages("shiny")

library(bio3d)
library(openxlsx)
library(shiny)

query_file <- "/home/joonmarion/R/copia25geral.fasta"
subject_file <- "/home/joonmarion/R/cr01_fasta.fasta"

blastn_command <- paste0("blastn -query ", query_file, " -subject ", subject_file, " -outfmt 6")
blast_result <- system(blastn_command, intern = TRUE)

output_file <- "blast_results.tsv"

write.table(blast_result, file = output_file, sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE)

blast_data <- read.table(output_file, sep = "\t")

colnames(blast_data) <- paste0("v", 1:12)

downloadBlastData <- function() {
  temp_file <- tempfile(fileext = ".xlsx")
  write.xlsx(blast_data, temp_file, colNames = TRUE)  # Set colNames = TRUE to include column headers
  return(temp_file)
}

ui <- fluidPage(
  downloadLink("downloadButton", "Download Blast Data")
)

server <- function(input, output) {
  output$downloadButton <- downloadHandler(
    filename = function() {
      "blast_results.xlsx"
    },
    content = function(file) {
      blast_data_file <- downloadBlastData()
      file.copy(blast_data_file, file)
    }
  )
}

shinyApp(ui, server)
