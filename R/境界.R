
# 境界 ----------------------------------------------------------------------

get_boundary <- function(file_boundary, regex_kansuji) {
  read_sf(file_boundary) |> 
    select(PREF_NAME, CITY_NAME, S_NAME, AREA, KIHON3, JINKO, SETAI) |> 
    rename(都道府県名 = PREF_NAME,
           市町村名 = CITY_NAME,
           面積 = AREA,
           人口 = JINKO,
           世帯数 = SETAI) |> 
    mutate(町 = S_NAME |> 
             str_extract(str_glue("[^[{regex_kansuji}]丁目$]+")),
           丁目 = S_NAME |> 
             str_extract(str_glue("{regex_kansuji}丁目$")),
           番地 = KIHON3 |> 
             str_extract("^\\d{2}") |> 
             parse_number()) |> 
    group_by(都道府県名, 市町村名, 町, 丁目, 番地) |> 
    summarise(across(c(面積, 人口, 世帯数),
                     sum),
              .groups = "drop")
}
