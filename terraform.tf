terraform {
  # This enables a function that is part of the optional attributes experiment.
  # See https://www.terraform.io/language/expressions/type-constraints#experimental-optional-object-type-attributes for more information
  experiments = [
    module_variable_optional_attrs
  ]
}
