import { application } from "controllers/application"
import AvailabilityCalendarController from "controllers/availability_calendar_controller"
application.register("availability-calendar", AvailabilityCalendarController)

import ProfileController from "controllers/profile_controller"

application.register("profile", ProfileController)
