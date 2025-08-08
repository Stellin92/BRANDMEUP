// Import and register all your controllers from the importmap via controllers/**/*_controller
import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// app/javascript/controllers/index.js
// import { application } from "./application"
// import PreviewController from "./preview_controller"

<<<<<<< HEAD
// application.register("preview", PreviewController)
// // Test
=======
application.register("preview", PreviewController)

import MenuController from "./menu_controller"
application.register("menu", MenuController)
>>>>>>> saveo
