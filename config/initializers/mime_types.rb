# Serve .webmanifest with the proper content type
Mime::Type.register "application/manifest+json", :webmanifest
