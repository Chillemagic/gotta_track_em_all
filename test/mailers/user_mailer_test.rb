require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "welcome renders both formats with a signature and login link" do
    user = User.new(email: "welcome@example.com", first_name: "Test",
      username: "trainer", trainer_type: "pokescientist")

    email = UserMailer.with(user: user).welcome

    assert_equal [ user.email ], email.to
    assert_equal [ "mail@trackem.tech" ], email.from
    assert_equal "Welcome to GTEA", email.subject
    assert email.multipart?

    [ email.html_part, email.text_part ].each do |part|
      assert_not_nil part
      assert_includes part.body.decoded, "Welcome trainer, Test"
      assert_includes part.body.decoded, "Gotta Track Em All"
      assert_includes part.body.decoded, "http://example.com/users/sign_in"
    end
  end
end
