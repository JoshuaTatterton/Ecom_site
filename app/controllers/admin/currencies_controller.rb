module Admin
  class CurrenciesController < ApplicationController
    helper_method :currencies, :currency

    def index
      authorize :view, Currency
    end

    # def new
    #   authorize :create, Currency
    # end

    # def create
    #   authorize :create, product

    #   if product.update(product_create_params)
    #     redirect_to action: :index
    #   else
    #     render :new
    #   end
    # end

    # def edit
    #   @product = Currency.find(params[:id])
    #   authorize :update, product
    # end

    # def update
    #   @product = Currency.find(params[:id])
    #   authorize :update, product

    #   if product.update(product_update_params)
    #     redirect_to action: :index
    #   else
    #     render :edit
    #   end
    # end

    # def destroy
    #   @product = Currency.find(params[:id])
    #   authorize :delete, product

    #   product.destroy

    #   redirect_to action: :index
    # end

    private

    # def product_create_params
    #   params.require(:pim_product).permit(:reference, :title, :description, :visible)
    # end

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
