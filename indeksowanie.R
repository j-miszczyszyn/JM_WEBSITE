library(xml2)

# Tworzenie mapy witryny
sitemap <- read_xml("<urlset xmlns='http://www.sitemaps.org/schemas/sitemap/0.9'>
                       <url>
                         <loc>https://miszczyszyn.org</loc>
                       </url>
                     </urlset>")
write_xml(sitemap, "sitemap.xml")

# Tworzenie robots.txt z linkiem do mapy witryny
rules <- c(
  "User-agent: *",                               # Zezwól wszystkim botom na indeksowanie
  "Allow: /",                                    # Zezwól na indeksowanie wszystkich stron
  "Sitemap: https://miszczyszyn.org/sitemap.xml" # Ścieżka do mapy witryny
)
writeLines(rules, "robots.txt")