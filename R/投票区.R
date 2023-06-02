
# 投票区 ---------------------------------------------------------------------

get_precinct_chome <- function(file_precinct, boundary, regex_kansuji) {
  data <- read_csv(file_precinct,
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
             str_extract("^(.+丁目|全域)")) |> 
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
  
  data_banchi <- data |> 
    inner_join(boundary,
               by = join_by(都道府県名, 市町村名, 町, 丁目, 番地))
  
  boundary_chome <- boundary |> 
    nest(.by = c(都道府県名, 市町村名, 町, 丁目),
         .key = "境界")
  data_chome <- data |> 
    filter(is.na(番地) & 丁目 != "全域") |> 
    select(!番地) |> 
    left_join(boundary_chome,
              by = join_by(都道府県名, 市町村名, 町, 丁目)) |> 
    unnest(境界)
  
  boundary_machi <- boundary |> 
    nest(.by = c(都道府県名, 市町村名, 町),
         .key = "境界")
  data_machi <- data |> 
    filter(丁目 == "全域") |> 
    select(!c(番地, 丁目)) |> 
    left_join(boundary_machi,
              by = join_by(都道府県名, 市町村名, 町)) |> 
    unnest(境界)
  
  bind_rows(data_banchi,
            data_chome,
            data_machi) |> 
    st_as_sf() |> 
    st_make_valid() |> 
    group_by(市町村コード, 都道府県名, 市町村名, 投票区, 投票所, 所在地, 町, 丁目) |> 
    summarise(across(c(面積, 人口, 世帯数),
                     sum),
              .groups = "drop")
}

get_precinct <- function(precinct_chome) {
  precinct_chome |> 
    group_by(市町村コード, 都道府県名, 市町村名, 投票区, 投票所, 所在地) |> 
    summarise(across(c(面積, 人口, 世帯数),
                     sum),
              .groups = "drop")
}