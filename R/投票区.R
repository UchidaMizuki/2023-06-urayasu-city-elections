
# 投票区 ---------------------------------------------------------------------

get_precinct <- function(file_precinct, regex_kansuji) {
  tar_load(file_precinct)
  
  read_csv(file_precinct,
           locale = locale(encoding = "shift-jis"),
           col_types = cols(.default = "c")) |> 
    rename_with(\(x) str_remove_all(x, "\\s")) |> 
    mutate(対象地域 = 対象地域 |> 
             str_split(str_glue("・(?!{regex_kansuji}丁目)"))) |> 
    unnest(対象地域, 
           keep_empty = TRUE) |> 
    mutate(町 = 対象地域 |> 
             str_extract(str_glue("^[^丁目・]+(?={regex_kansuji}丁目|全域)")),
           丁目 = 対象地域 |> 
             str_remove(str_glue("^{町}")) |> 
             str_split(str_glue("[・、](?={regex_kansuji}丁目)")),
           .keep = "unused") |> 
    unnest(丁目, 
           keep_empty = TRUE) |> 
    mutate(番地 = 丁目 |> 
             str_extract("(?<=丁目).+") |> 
             str_split("、"),
           丁目 = 丁目 |> 
             str_extract("^.+丁目")) |> 
    unnest(番地,
           keep_empty = TRUE) |> 
    mutate(番地 = 番地 |> 
             stringi::stri_trans_nfkc(),
           番地 = 番地 |> 
             map(\(番地) {
               if (is.na(番地)) {
                 NA_integer_
               } else if (str_detect(番地, "^\\d+$")) {
                 parse_number(番地)
               } else if (str_detect(番地, "^\\d+~\\d+$")) {
                 data <- 番地 |> 
                   str_match("^(?<from>\\d+)~(?<to>\\d+)$")
                 seq(parse_number(data[, "from"]), parse_number(data[, "to"]))
               }
             })) |> 
    unnest(番地,
           keep_empty = TRUE)
}
