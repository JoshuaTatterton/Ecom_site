module Admin
  class ApplicationController < ::ApplicationController
    include UserSession
  end
end
