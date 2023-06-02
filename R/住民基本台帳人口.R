
# 住民基本台帳人口 ----------------------------------------------------------------

get_population <- function(file_population) {
  sheets <- excel_sheets(file_population) |> 
    keep(\(x) !x %in% c("総計", "字別人口"))
  
  sheets |> 
    map(\(sheet) {
      data <- read_excel(file_population,
                         sheet = sheet,
                         range = cellranger::cell_limits(ul = c(2, 2),
                                                         lr = c(NA, 13)),
                         col_names = expand_grid(col_number = 1:3,
                                                 col_name = c("年齢", "男", "女", "計")) |> 
                           str_glue_data("{col_name}{col_number}"),
                         col_types = "text") |> 
        mutate(町丁字 = 年齢1 |> 
                 str_extract("(?<=^（).+(?=）$)"),
               .before = 1) |> 
        fill(町丁字) |> 
        filter(between(row_number(), 3, 42),
               .by = 町丁字)
      
      get_data_number <- function(data, number) {
        number <- as.character(number)
        data |> 
          select(町丁字, ends_with(number)) |> 
          rename_with(\(x) str_remove(x, number))
      }
      
      bind_rows(get_data_number(data, 1),
                get_data_number(data, 2),
                get_data_number(data, 3)) |> 
        drop_na(年齢) |> 
        mutate(across(c(年齢, 男, 女, 計),
                      partial(parse_number,
                              na = "×"))) |> 
        arrange(as_factor(町丁字), 年齢)
    },
    .progress = TRUE) |> 
    list_rbind()
}
