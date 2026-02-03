library(xml2)

# ==============================================================================
# Skrypt do generowania sitemap.xml i robots.txt
# dla strony: https://miszczyszyn.org
#
# Uruchomienie: po renderowaniu Quarto (quarto render)
#   source("indeksowanie.R")
#
# Skrypt automatycznie skanuje folder docs/ w poszukiwaniu plików .html
# i tworzy kompletną mapę witryny.
# ==============================================================================

# --- Konfiguracja ---
base_url    <- "https://miszczyszyn.org"
output_dir  <- "docs"

# Priorytety stron (strona główna najwyżej, posty niżej)
priority_map <- list(
  "index.html"        = "1.0",
  "posts.html"        = "0.8",
  "publications.html" = "0.8",
  "programming.html"  = "0.7",
  "photography.html"  = "0.7",
  "about.html"        = "0.6"
)
default_priority <- "0.5"

# Częstotliwość zmian
changefreq_map <- list(
  "index.html"        = "monthly",
  "posts.html"        = "weekly",
  "publications.html" = "monthly",
  "programming.html"  = "monthly",
  "photography.html"  = "monthly",
  "about.html"        = "monthly"
)
default_changefreq <- "yearly"

# Pliki/foldery do wykluczenia z sitemap
exclude_patterns <- c(
  "site_libs",
  "search.json",
  "listings.json",
  "404.html"
)

# --- Skanowanie stron ---
cat("Skanowanie folderu:", output_dir, "\n")

html_files <- list.files(
  path       = output_dir,
  pattern    = "\\.html$",
  recursive  = TRUE,
  full.names = FALSE
)

# Filtrowanie wykluczonych plików
for (pattern in exclude_patterns) {
  html_files <- html_files[!grepl(pattern, html_files, fixed = TRUE)]
}

cat("Znaleziono", length(html_files), "stron HTML\n")

# --- Tworzenie sitemap.xml ---
ns <- "http://www.sitemaps.org/schemas/sitemap/0.9"

# Nagłówek XML
sitemap_xml <- xml_new_root("urlset", xmlns = ns)

for (file in html_files) {
  # Pełny URL
  loc <- paste0(base_url, "/", file)

  # Data ostatniej modyfikacji (z pliku)
  file_path <- file.path(output_dir, file)
  lastmod <- format(file.info(file_path)$mtime, "%Y-%m-%dT%H:%M:%S+00:00")

  # Priorytet
  basename_file <- basename(file)
  if (file %in% names(priority_map)) {
    priority <- priority_map[[file]]
  } else if (basename_file %in% names(priority_map)) {
    priority <- priority_map[[basename_file]]
  } else {
    priority <- default_priority
  }

  # Częstotliwość zmian
  if (file %in% names(changefreq_map)) {
    changefreq <- changefreq_map[[file]]
  } else if (basename_file %in% names(changefreq_map)) {
    changefreq <- changefreq_map[[basename_file]]
  } else {
    changefreq <- default_changefreq
  }

  # Dodanie wpisu <url>
  url_node <- xml_add_child(sitemap_xml, "url")
  xml_add_child(url_node, "loc",        loc)
  xml_add_child(url_node, "lastmod",    lastmod)
  xml_add_child(url_node, "changefreq", changefreq)
  xml_add_child(url_node, "priority",   priority)
}

# Zapis sitemap.xml do folderu docs/
sitemap_path <- file.path(output_dir, "sitemap.xml")
write_xml(sitemap_xml, sitemap_path)
cat("Zapisano:", sitemap_path, "\n")

# --- Tworzenie robots.txt ---
robots <- c(
  "User-agent: *",
  "Allow: /",
  "",
  "# Blokowanie wewnętrznych zasobów Quarto",
  "Disallow: /site_libs/",
  "Disallow: /search.json",
  "Disallow: /listings.json",
  "",
  "# Mapa witryny",
  paste0("Sitemap: ", base_url, "/sitemap.xml")
)

robots_path <- file.path(output_dir, "robots.txt")
writeLines(robots, robots_path)
cat("Zapisano:", robots_path, "\n")

# Kopia robots.txt do katalogu głównego (Quarto kopiuje go do docs/ przy renderze)
writeLines(robots, "robots.txt")
cat("Zapisano: robots.txt (katalog główny)\n")

# --- Podsumowanie ---
cat("\n=== Podsumowanie sitemap ===\n")
for (file in html_files) {
  loc <- paste0(base_url, "/", file)
  cat(" ", loc, "\n")
}
cat("\nGotowe! Sitemap zawiera", length(html_files), "adresów URL.\n")

