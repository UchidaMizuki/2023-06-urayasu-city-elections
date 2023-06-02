
# 境界 ----------------------------------------------------------------------

get_境界 <- function(file_境界) {
  tar_load(file_境界)
  
  data <- read_sf(file_境界) |> 
    select(PREF_NAME, CITY_NAME, S_NAME, AREA, KIHON3, JINKO, SETAI) |> 
    rename(都道府県名 = PREF_NAME,
           市町村名 = CITY_NAME,
           人口 = JINKO,
           世帯数 = SETAI) |> 
    mutate(町 = S_NAME |> 
             str_extract("[^[]丁目$]+"))
  
    # group_by(PREF, CITY, K_AREA, PREF_NAME, CITY_NAME, S_NAME, KIHON1, KIHON2, KIHON3) |>
    # summarise(across(c(AREA, JINKO, SETAI),
    #                  sum),
    #           .groups = "drop")
}
