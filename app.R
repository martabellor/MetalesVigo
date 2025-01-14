library(shiny)
library(shinythemes)

# Define la interfaz de usuario
ui <- fluidPage(
  theme = shinytheme("cerulean"),
  titlePanel("Resultado de metales (Complejo Hospitalario de Vigo)"),
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Selecciona un archivo CSV", accept = ".csv"),
      style = "background-color: #f7f7f7; padding: 20px; border-radius: 10px;"
    ),
    mainPanel(
      fluidRow(
        column(12, h3("Control Interno (UM, MQ, WB)", style = "color: #2E86C1;"),
               tableOutput("control_interno"),
               tags$hr(style = "border-top: 2px solid #2E86C1;")),
        column(12, h3("Control Externo (CEXT)", style = "color: #28B463;"),
               tableOutput("control_externo"),
               tags$hr(style = "border-top: 2px solid #28B463;")),
        column(12, h3("Orina (0997)", style = "color: #D68910;"),
               tableOutput("orina"),
               tags$hr(style = "border-top: 2px solid #D68910;")),
        column(12, h3("Sangre Total (0280)", style = "color: #CB4335;"),
               tableOutput("sangre_total"),
               tags$hr(style = "border-top: 2px solid #CB4335;")),
        column(12, h3("Suero (0804)", style = "color: #8E44AD;"),
               tableOutput("suero"),
               tags$hr(style = "border-top: 2px solid #8E44AD;"))
      )
    )
  )
)

# Define el servidor
server <- function(input, output) {
  data <- reactive({
    req(input$file) # Asegura que el archivo está cargado
    
    # Lee el archivo CSV con delimitador punto y coma
    df <- read.csv(input$file$datapath, header = TRUE, sep = ";")
    
    # Verifica si el archivo tiene suficientes columnas y filas
    if (ncol(df) < 13) {
      return(data.frame(Mensaje = "El archivo CSV no tiene suficientes columnas."))
    }
    if (nrow(df) < 3) {
      return(data.frame(Mensaje = "El archivo CSV no tiene suficientes filas."))
    }
    
    # Filtra a partir de la fila 3 y selecciona las columnas 2, 4, 6 y 13
    filtered_df <- df[3:nrow(df), c(2, 4, 6, 13)]
    
    # Renombra las columnas seleccionadas
    colnames(filtered_df) <- c("Nº de muestra", "Cobre", "Zinc", "Plomo")
    
    # Convertir columnas a numéricas si es necesario
    filtered_df$Cobre <- as.numeric(as.character(filtered_df$Cobre))
    filtered_df$Zinc <- as.numeric(as.character(filtered_df$Zinc))
    filtered_df$Plomo <- as.numeric(as.character(filtered_df$Plomo))
    
    return(filtered_df)
  })
  
  output$control_interno <- renderTable({
    df <- data()
    control_interno_df <- df[grepl("^(UM|MQ|WB)", df[["Nº de muestra"]]), ]
    # Dividir Cobre y Zinc entre 10 para muestras MQ
    control_interno_df$Cobre <- ifelse(grepl("MQ", control_interno_df[["Nº de muestra"]]), control_interno_df$Cobre / 10, control_interno_df$Cobre)
    control_interno_df$Zinc <- ifelse(grepl("MQ", control_interno_df[["Nº de muestra"]]), control_interno_df$Zinc / 10, control_interno_df$Zinc)
    # Dividir Plomo entre 10 para muestras WB y ocultar Zinc y Cobre en WB
    control_interno_df$Plomo <- ifelse(grepl("WB", control_interno_df[["Nº de muestra"]]), control_interno_df$Plomo / 10, control_interno_df$Plomo)
    control_interno_df$Cobre <- ifelse(grepl("WB", control_interno_df[["Nº de muestra"]]), NA, control_interno_df$Cobre)
    control_interno_df$Zinc <- ifelse(grepl("WB", control_interno_df[["Nº de muestra"]]), NA, control_interno_df$Zinc)
    # Ocultar Plomo en muestras MQ
    control_interno_df$Plomo <- ifelse(grepl("MQ", control_interno_df[["Nº de muestra"]]), NA, control_interno_df$Plomo)
    control_interno_df
  }, bordered = TRUE, striped = TRUE, hover = TRUE)
  
  output$control_externo <- renderTable({
    df <- data()
    control_externo_df <- df[grepl("^CEXT", df[["Nº de muestra"]]), ]
    # Dividir Zinc por 1000 solo si la muestra contiene "OR"
    control_externo_df$Zinc <- ifelse(grepl("OR", control_externo_df[["Nº de muestra"]]), control_externo_df$Zinc / 1000, control_externo_df$Zinc)
    # Remover Zinc y Cobre de las muestras que contienen "WB"
    control_externo_df$Cobre <- ifelse(grepl("WB", control_externo_df[["Nº de muestra"]]), NA, control_externo_df$Cobre)
    control_externo_df$Zinc <- ifelse(grepl("WB", control_externo_df[["Nº de muestra"]]), NA, control_externo_df$Zinc)
    # Remover Plomo de las muestras que contienen "S" pero no de las que contienen "OR"
    control_externo_df$Plomo <- ifelse(grepl("S", control_externo_df[["Nº de muestra"]]) & !grepl("OR", control_externo_df[["Nº de muestra"]]), NA, control_externo_df$Plomo)
    # Ajustar nombres de columnas con las unidades correspondientes
    colnames(control_externo_df) <- c("Nº de muestra", "Cobre (µg/L)", "Zinc (mg/L para muestras con OR, µg/L para el resto)", "Plomo (µg/L)")
    control_externo_df
  }, bordered = TRUE, striped = TRUE, hover = TRUE)
  
  output$orina <- renderTable({
    df <- data()
    orina_df <- df[grepl("^0997", df[["Nº de muestra"]]), c("Nº de muestra", "Cobre", "Zinc")]
    orina_df$Zinc <- as.numeric(orina_df$Zinc) / 1000 # Convertir Zinc a ppm
    colnames(orina_df) <- c("Nº de muestra", "Cobre (µg/L)", "Zinc (ppm)")
    orina_df
  }, bordered = TRUE, striped = TRUE, hover = TRUE)
  
  output$sangre_total <- renderTable({
    df <- data()
    sangre_total_df <- df[grepl("^0280", df[["Nº de muestra"]]), c("Nº de muestra", "Plomo")]
    sangre_total_df$Plomo <- as.numeric(sangre_total_df$Plomo) / 10 # Dividir Plomo entre 10
    colnames(sangre_total_df) <- c("Nº de muestra", "Plomo (µg/dL)")
    sangre_total_df
  }, bordered = TRUE, striped = TRUE, hover = TRUE)
  
  output$suero <- renderTable({
    df <- data()
    suero_df <- df[grepl("^0804", df[["Nº de muestra"]]), c("Nº de muestra", "Cobre", "Zinc")]
    suero_df$Cobre <- as.numeric(suero_df$Cobre) / 10 # Dividir Cobre entre 10
    suero_df$Zinc <- as.numeric(suero_df$Zinc) / 10 # Dividir Zinc entre 10
    colnames(suero_df) <- c("Nº de muestra", "Cobre (µg/dL)", "Zinc (µg/dL)")
    suero_df
  }, bordered = TRUE, striped = TRUE, hover = TRUE)
}

# Ejecuta la aplicación Shiny
shinyApp(ui = ui, server = server)




