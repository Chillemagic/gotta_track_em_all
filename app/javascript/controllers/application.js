import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }

import UsernameCheckController from "./controllers/username_check_controller"
application.register("username-check", UsernameCheckController)
