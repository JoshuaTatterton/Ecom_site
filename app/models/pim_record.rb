class PimRecord < ActiveRecord::Base
  primary_abstract_class

  connects_to database: { writing: :pim }
end
