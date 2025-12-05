module Admin
  class CurrenciesController < ApplicationController
    helper_method :currencies, :currency

    def index
      authorize :view, Currency
    end

    def create
      authorize :create, currency

      currency.update(CurrencyHelper::CURRENCIES[currency_iso_param])

      redirect_to action: :index
    end

    # def update
    #   @product = Currency.find(params[:id])
    #   authorize :update, product

    #   if product.update(product_update_params)
    #     redirect_to action: :index
    #   else
    #     render :edit
    #   end
    # end

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
