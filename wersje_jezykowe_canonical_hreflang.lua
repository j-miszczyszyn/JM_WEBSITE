-- Dodaje do nagłówka każdej podstrony adres kanoniczny oraz odnośniki hreflang
-- łączące wersję polską (https://miszczyszyn.org/...) z angielską (https://miszczyszyn.org/en/...).
local adres_pl = "https://miszczyszyn.org/"
local adres_en = "https://miszczyszyn.org/en/"

function Meta(meta)
  if not quarto.doc.is_format("html") then
    return meta
  end
  local plik = quarto.doc.input_file
  local katalog = quarto.project.directory
  if plik == nil or katalog == nil then
    return meta
  end
  plik = plik:gsub("\\", "/")
  katalog = katalog:gsub("\\", "/")
  if plik:sub(1, #katalog) ~= katalog then
    return meta
  end
  local sciezka = plik:sub(#katalog + 2):gsub("%.qmd$", ".html"):gsub("%.md$", ".html")
  if sciezka == "index.html" then
    sciezka = ""
  end
  local jezyk = "pl"
  if meta.lang ~= nil then
    jezyk = pandoc.utils.stringify(meta.lang)
  end
  local kanoniczny = adres_pl .. sciezka
  if jezyk == "en" then
    kanoniczny = adres_en .. sciezka
  end
  quarto.doc.include_text("in-header",
    '<link rel="canonical" href="' .. kanoniczny .. '">\n' ..
    '<link rel="alternate" hreflang="pl" href="' .. adres_pl .. sciezka .. '">\n' ..
    '<link rel="alternate" hreflang="en" href="' .. adres_en .. sciezka .. '">\n' ..
    '<link rel="alternate" hreflang="x-default" href="' .. adres_pl .. sciezka .. '">')
  return meta
end
