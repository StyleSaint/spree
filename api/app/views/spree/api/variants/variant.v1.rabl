attributes *variant_attributes
node(:options_text) { |v| v.options_text }
child :option_values => :option_values do
  attributes *option_value_attributes
end

child(:images => :images) { extends "spree/api/images/show" }