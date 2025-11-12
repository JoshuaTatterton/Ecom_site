# Include in a controller you want to use the `generic/_pagination` partial
#   Redefine the `base_scope` method with a selector that receives `.count`
#   Everything else is powered by { page: { per: 1, no: 1 } } params.
module Pagination
  extend ActiveSupport::Concern

  def self.included(base)
    base.class_eval do
      helper_method :page_uri, :page_number, :page_count
    end
  end

  def base_scope
    []
  end

  def page_count
    @page_count ||= (base_scope.count / page_limit.to_f).ceil
  end

  def page_uri
    @page_uri ||= URI.parse(request.original_fullpath)
  end

  def page_params
    params[:page] || {}
  end

  def page_limit
    @page_limit ||= [page_params.fetch(:per, 10).to_i, 1].max
  end

  def page_number
    @page_number ||= [page_params.fetch(:no, 1).to_i, 1].max
  end

  def page_offset
    @page_offset ||= page_limit * (page_number - 1)
  end
end
