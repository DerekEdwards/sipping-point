#
# Module SippingPoints is responsible for holding the mapping between actions
# and a user's in-app sipping points.
# 
# Gamified components (Event, RSVP) will inherently have a SP value, but a user
# only counts those points towards themself if the relevant event has tipped
#
# @author Aaron Magil <abmagil@gmail.com>
# @note I'm not super happy with how much this module knows about the internals
#   of the gamified classes. I'm considering making it a service module which
#   takes in a user and spits back answers. This would make it more
#   self-contained...
module SippingPoints
  module Event
    TIPPED = {
       true => 3,
      false => 0
    }
    ATTENDEE = 1
  end

  module Rsvp
    RESPONDED = 1
  end

  module Attendance
    # We need to use ::Rsvp to access the model Rsvp, instead of the module we
    # define here. We're using that to couple it to the constants defined in
    # that file.  See Rsvp#sipping_points for usage
    REPORT = {
      ::Rsvp::SHOWED =>  3,
      ::Rsvp::FLAKED => -6,
                 nil =>  0
    }
  end
end