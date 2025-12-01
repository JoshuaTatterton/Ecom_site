module Admin
  class ProductsController < ApplicationController
    include Pagination

    helper_method :products, :product

    def index
      authorize :view, Pim::Product
    end

    def new
      authorize :create, Pim::Product
    end

    def create
      authorize :create, product

      if product.update(product_params)
        redirect_to action: :index
      else
        render :new
      end
    end

    def edit
      @product = Pim::Product.find(params[:id])
      authorize :update, product
    end

    def update
      @product = Pim::Product.find(params[:id])
      authorize :update, product

      if product.update(product_params)
        redirect_to action: :index
      else
        render :edit
      end
    end

    def destroy
      @product = Pim::Product.find(params[:id])
      authorize :delete, product

      product.destroy

      redirect_to action: :index
    end

    private

    def product_params
      params.require(:pim_product).permit(:title, :reference, :description, :visible)
    end

    def products
      @products ||= base_scope.offset(page_offset).limit(page_limit)
    end

    def base_scope
      Pim::Product.order(id: :desc)
    end

    def product
      @product ||= Pim::Product.new
    end
  end
end
