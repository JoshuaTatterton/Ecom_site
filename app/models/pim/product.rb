# One per account record containing the system level config (not to be modified by Users)
# e.g. database configs or account feature toggles
module Pim
  class Product < PimRecord
    include AccountScoped
  end
end
