module Admin
  class VariantsController < ApplicationController
    include Pagination

    helper_method :product, :variants

    def index
      authorize :view, Pim::Variant
    end

    # def new
    #   authorize :create, Pim::Product
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
    #   @product = Pim::Product.find(params[:id])
    #   authorize :update, product
    # end

    # def update
    #   @product = Pim::Product.find(params[:id])
    #   authorize :update, product

    #   if product.update(product_update_params)
    #     redirect_to action: :index
    #   else
    #     render :edit
    #   end
    # end

    # def destroy
    #   @product = Pim::Product.find(params[:id])
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

    def variants
      @variants ||= base_scope.offset(page_offset).limit(page_limit)
    end

    def base_scope
      product.variants.order(position: :asc)
    end

    def product
      @product ||= Pim::Product.find(params[:product_id])
    end
  end
end
