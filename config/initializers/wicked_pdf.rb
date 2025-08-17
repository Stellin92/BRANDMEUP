# config/initializers/wicked_pdf.rb
WickedPdf.config = {
  exe_path: WickedPdf.binary_path, # wkhtmltopdf-binary fournit ce binaire
  layout: "pdf",                   # layout par défaut pour les PDFs
  dpi: 96
}
