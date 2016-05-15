Given(/^I wait for (\d+) seconds$/) do |arg|
  sleep arg.to_i
end