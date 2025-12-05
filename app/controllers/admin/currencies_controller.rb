module Admin
  class CurrenciesController < ApplicationController
    helper_method :currencies, :currency

    def index
      authorize :view, Currency
    end

    def create
      authorize :add, currency
      authorize :update, :currency_defaults if currency_default_param

      currency.update(default: currency_default_param, **CurrencyHelper::CURRENCIES[currency_iso_param])

      redirect_to action: :index
    end

    def update
      authorize :update, :currency_defaults
      @currency = Currency.find(params[:id])

      currency.update(default: currency_default_param)

      redirect_to action: :index
    end

    def destroy
      @currency = Currency.find(params[:id])
      authorize :remove, currency

      currency.destroy

      redirect_to action: :index
    end

    private

    def currency_iso_param
      params.require(:currency).permit(:iso).fetch(:iso)
    end

    def currency_default_param
      params.require(:currency).permit(:default).fetch(:default, false)
    end

    # def product_update_params
    #   params.require(:pim_product).permit(:title, :description, :visible)
    # end

    def currencies
      @currencies ||= Currency.order(id: :desc)
    end

    def currency
      @currency ||= Currency.new
    end
  end
end
