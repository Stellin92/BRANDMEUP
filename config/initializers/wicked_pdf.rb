WickedPdf.config ||= {}
WickedPdf.config.merge!(
  layout: "pdf",
  dpi: 96,
  enable_local_file_access: true
)

# En dev/test seulement, on renseigne le chemin du binaire si on le connaît.
if Rails.env.development? || Rails.env.test?
  # Si le gem wkhtmltopdf-binary expose binary_path, on l’utilise.
  if WickedPdf.respond_to?(:binary_path)
    WickedPdf.config[:exe_path] = WickedPdf.binary_path
  else
    # Sinon on tente de deviner un chemin courant
    guessed = %w[/usr/local/bin/wkhtmltopdf /usr/bin/wkhtmltopdf].find { |p| File.exist?(p) }
    WickedPdf.config[:exe_path] = guessed if guessed
    # (si rien n’est trouvé, WickedPDF utilisera 'wkhtmltopdf' via le PATH)
  end
end
