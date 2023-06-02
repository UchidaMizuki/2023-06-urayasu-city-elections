source("data-raw/setup.R")

# 境界 ----------------------------------------------------------------------

# 出典: 2020年国勢調査 小地域 (町丁・字等) 境界データ
file <- file_temp()
curl_download("https://www.e-stat.go.jp/gis/statmap-search/data?dlserveyId=B002005212020&code=12227&coordSys=1&format=shape&downloadType=5&datum=2011",
              destfile = file)
zip::unzip(file, 
           exdir = "data-raw/境界")
