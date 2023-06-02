source("data-raw/setup.R")

# 投票率 ---------------------------------------------------------------------

user_agent <- "uchidamizuki@vivaldi.net"

dir <- "data-raw/投票率"
dir_create(dir)

url <- "https://www.city.urayasu.lg.jp"
session <- bow(url,
               user_agent = user_agent) 

scrape_table <- function(path) {
  session |> 
    nod(path) |> 
    scrape(content = "text/html; charset=UTF-8") |> 
    html_element("table") |> 
    html_table() |> 
    drop_na(投票区)
}

# 令和5年4月9日 千葉県議会議員選挙
table <- scrape_table("shisei/senkyo/kekka/kengikai/1009456/1009464.html")
write_excel_csv(table, path(dir, "令和5年4月9日_千葉県議会議員選挙", ext = "csv"))

# 令和5年4月23日 浦安市議会議員選挙
table <- scrape_table("shisei/senkyo/kekka/gikai/1009443/1009650.html")
write_excel_csv(table, path(dir, "令和5年4月23日_浦安市議会議員選挙", ext = "csv"))

# 令和5年4月23日 衆議院議員選挙
table <- scrape_table("shisei/senkyo/kekka/shugiin/1020761/1020769.html")
write_excel_csv(table, path(dir, "令和5年4月23日_衆議院議員選挙", ext = "csv"))

# 投票率_年代別 -----------------------------------------------------------------

dir_create("data-raw/投票率_年代別")

pdf <- pdf_text("https://www.city.urayasu.lg.jp/_res/projects/default_project/_page_/001/038/333/040710.pdf")

# 投票率: 令和4年7月10日 参議院議員選挙
table <- pdf[11:12] |> 
  str_split("\\n+") |>
  list_c() |> 
  str_match(str_c("(\\d+)\\.([^\\s]+)", str_dup("\\s+([\\d,\\.]+)", 9))) |> 
  as_tibble(.name_repair = ~c(".", 
                              "投票区", "投票所名", 
                              "有権者数（男）", "有権者数（女）", "有権者数（計）", 
                              "投票者数（男）", "投票者数（女）", "投票者数（計）", 
                              "投票率（男）", "投票率（女）", "投票率（計）")) |> 
  select(!.) |> 
  drop_na(投票区)
write_excel_csv(table, path("data-raw/投票率/令和4年7月10日_参議院議員選挙", ext = "csv"))

# 投票率 年代別: 令和4年7月10日 参議院議員選挙
table <- pdf[[13]] |> 
  str_split_1("\\n+") |> 
  str_match(str_c("([^\\s]+)", str_dup("\\s+([\\d,\\.%]+)", 9))) |> 
  as_tibble(.name_repair = ~c(".", 
                              "年代", 
                              "有権者数（男）", "有権者数（女）", "有権者数（計）", 
                              "投票者数（男）", "投票者数（女）", "投票者数（計）", 
                              "投票率（男）", "投票率（女）", "投票率（計）")) |> 
  select(!.) |> 
  drop_na(年代)
write_excel_csv(table, path("data-raw/投票率_年代別/令和4年7月10日_参議院議員選挙", ext = "csv"))
