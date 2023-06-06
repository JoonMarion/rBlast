# Verifica se o pacote "BiocManager" está instalado. Caso contrário, instala o pacote "BiocManager"
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")

# Instala o pacote "bio3d" utilizando a função install() do pacote "BiocManager"
BiocManager::install("bio3d")

# Instala o pacote "openxlsx" e "shiny" utilizando a função install.packages().
install.packages("openxlsx")
install.packages("shiny")

# Carrega os pacotes "bio3d", "openxlsx" e "shiny" para uso no código
library(bio3d)
library(openxlsx)
library(shiny)

# Define os caminhos dos arquivos de query/elemento de transposição e subject/cromossomo
query_file <- "/home/joonmarion/R/copia25geral.fasta"
subject_file <- "/home/joonmarion/R/cr01_fasta.fasta"

# Cria um comando blastn concatenando os caminhos dos arquivos de consulta e assunto
blastn_command <- paste0("blastn -query ", query_file, " -subject ", subject_file, " -outfmt 6")
# Executa o comando utilizando a função system() e armazena o resultado em blast_result
blast_result <- system(blastn_command, intern = TRUE)

# Define o nome do arquivo de saída do resultado do blast
output_file <- "blast_results.tsv"

# Escreve o resultado do blast no arquivo de saída no formato de tabela separada por tabulação
write.table(blast_result, file = output_file, sep = "\t", quote = FALSE, row.names = FALSE, col.names = FALSE)

# Lê o arquivo de saída do blast e armazena os dados na variável blast_data 
blast_data <- read.table(output_file, sep = "\t")

# Define os nomes das colunas do blast_data adicionando o prefixo "v" seguido de números de 1 a 12
colnames(blast_data) <- paste0("v", 1:12)

# Define uma função chamada downloadBlastData() que cria um arquivo temporário com extensão ".xlsx" 
# Escreve os dados do blast_data nesse arquivo utilizando a função write.xlsx(). 
# A opção colNames = TRUE é usada para incluir os cabeçalhos de coluna.
downloadBlastData <- function() {
  temp_file <- tempfile(fileext = ".xlsx")
  write.xlsx(blast_data, temp_file, colNames = TRUE)
  return(temp_file)
}

# Define a interface do aplicativo Shiny, com uma página fluida contendo um link de download 
# com o texto "Download Blast Data".
ui <- fluidPage(
  downloadLink("downloadButton", "Download Blast Data")
)
# Define a função do servidor para o aplicativo Shiny. Nessa função, é definido o manipulador
# de download para o botão downloadButton. O manipulador especifica o nome do arquivo de download 
# como "blast_results.xlsx" e define a função content para copiar o arquivo gerado pela função 
# downloadBlastData() para o arquivo final de download.
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

# Cria e executa o aplicativo Shiny com a interface definida em ui e a função do servidor 
# definida em server.
shinyApp(ui, server)
