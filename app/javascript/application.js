// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@popperjs/core"
import "bootstrap"

import { Application } from "@hotwired/stimulus"

export const application = Application.start()

import PreviewController from "./controllers/preview_controller"
application.register("preview", PreviewController)
// import "./controllers"

import ModalController from "./controllers/modal_controller.js";
application.register("modal", ModalController)
