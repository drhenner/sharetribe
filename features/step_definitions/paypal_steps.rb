# coding: utf-8

Then("I expect transaction with PayPal test to pass") do
  navigation = FeatureTests::Navigation
  data = FeatureTests::Data
  login = FeatureTests::Action::Login
  listing_actions = FeatureTests::Action::Listing
  paypal_actions = FeatureTests::Action::Paypal
  onboarding_wizard = FeatureTests::Section::OnboardingWizard

  marketplace = data.create_marketplace(payment_gateway: :paypal)
  admin = data.create_member(username: "paypal_admin", marketplace_id: marketplace[:id], admin: true)
  member = data.create_member(username: "paypal_buyer", marketplace_id: marketplace[:id], admin: false)

  navigation.navigate_in_marketplace!(ident: marketplace[:ident])

  # Connect Paypal for marketplace and seller
  login.login_as(admin[:username], admin[:password])
  paypal_actions.connect_marketplace_paypal
  paypal_actions.connect_seller_paypal

  # Add new listing
  listing_actions.add_new_listing("Snowman for sale: ☃")
  onboarding_wizard.dismiss_dialog

  # Member buys the listing
  login.logout_and_login_as(member[:username], member[:password])
  paypal_actions.request_listing("Snowman for sale: ☃")

  # Adming accepts request
  login.logout_and_login_as(admin[:username], admin[:password])
  paypal_actions.accept_listing_request

  # Member marks the payment completed
  login.logout_and_login_as(member[:username], member[:password])
  paypal_actions.buyer_mark_completed

  # Admin skips feedback
  login.logout_and_login_as(admin[:username], admin[:password])
  paypal_actions.seller_mark_completed

  expect(page).to have_content("Completed")
end
