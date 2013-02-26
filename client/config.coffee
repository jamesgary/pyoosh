exports.config =
  # See http://brunch.readthedocs.org/en/latest/config.html for documentation.
  files:
    javascripts:
      joinTo:
        'js/app.js':    /^app/
        'js/vendor.js': /^vendor/
      order:
        before: [
          'vendor/jquery-2.0.0b1.js'
          'vendor/bootstrap/js/bootstrap.min.js'
        ]
    stylesheets:
      joinTo:
        'css/app.css': /^(app|vendor)/
      order:
        before: [
          'vendor/bootstrap/css/bootstrap.min.css'
          'vendor/bootstrap/css/ootstrap-responsive.min.css'
        ]
