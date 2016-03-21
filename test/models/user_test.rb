require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # See fixtures for underlying data
  def test_sipping_point_calculation
    #   3 points for tipped event
    # + 2 points from invitees (1 pt per invite)
    # + 1 point from responding
    # + 3 points from showing up
    #----------------------------
    #   9 points for Bob
    assert_equal 9, users(:bob).sipping_points

    #   1 point for responding
    # + 3 points from showing up
    #----------------------------
    #   4 points for Jim
    assert_equal 4, users(:jim).sipping_points
  end

  # Poor Terry, he has no friends, so his event doesn't tip
  def test_failed_event_worth_no_points
    assert_equal 0, users(:lonely_terry).sipping_points
  end

  # Ensure that a user has an integer number of points, whether they've done
  # anything meaningful or not
  def test_boring_users_have_zero_points
    assert_equal 0, users(:no_point_pierce).sipping_points
  end

end
