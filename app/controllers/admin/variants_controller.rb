module Admin
  class VariantsController < ApplicationController
    include Pagination

    helper_method :product, :variant, :variants

    def index
      authorize :view, Pim::Variant
    end

    def new
      authorize :create, Pim::Variant
    end

    def create
      authorize :create, variant

      if variant.update(variant_create_params)
        redirect_to action: :index
      else
        render :new
      end
    end

    def edit
      @variant = product.variants.find(params[:id])
      authorize :update, variant
    end

    def update
      @variant = product.variants.find(params[:id])
      authorize :update, variant

      if variant.update(variant_update_params)
        redirect_to action: :index
      else
        render :edit
      end
    end

    # def destroy
    #   @product = Pim::Product.find(params[:id])
    #   authorize :delete, product

    #   product.destroy

    #   redirect_to action: :index
    # end

    private

    def variant_create_params
      params.require(:pim_variant).permit(:reference, :title, :visible, :position)
    end

    def variant_update_params
      params.require(:pim_variant).permit(:title, :visible, :position)
    end

    def variant
      @variant ||= product.variants.new
    end

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
