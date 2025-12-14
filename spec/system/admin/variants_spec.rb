RSpec.describe "Variants Admin", type: :system do
  describe "#index" do
    scenario "viewing variants" do
      # Arrange
      product = Pim::Product.create(title: "Top", reference: "top", visible: true)
      s_variant = product.variants.create(
        reference: "top_small", title: "Small",
        position: 0
      )
      l_variant = product.variants.create(
        reference: "top_large", title: "Large",
        visible: true, position: 1
      )

      # Act
      visit admin_product_variants_path(Switch.current_account, product)

      # Assert
      aggregate_failures do
        within("tbody#variants") do
          within("tr:nth-child(1)") do
            expect(page).to have_content(s_variant.title)
            expect(page).to have_content(s_variant.reference)
            expect(page).not_to have_selector("svg.bi-check-circle")
            expect(page).to have_selector("svg.bi-ban")
            edit_path = edit_admin_product_variant_path(Switch.current_account, product, s_variant)
            expect(page).to have_selector("a[href='#{edit_path}']")
            delete_path = admin_product_variant_path(Switch.current_account, product, s_variant)
            expect(page).to have_selector("a[href='#{delete_path}'][data-turbo-method='delete']")
          end
          within("tr:nth-child(2)") do
            expect(page).to have_content(l_variant.title)
            expect(page).to have_content(l_variant.reference)
            expect(page).to have_selector("svg.bi-check-circle")
            expect(page).not_to have_selector("svg.bi-ban")
            edit_path = edit_admin_product_variant_path(Switch.current_account, product, l_variant)
            expect(page).to have_selector("a[href='#{edit_path}']")
            delete_path = admin_product_variant_path(Switch.current_account, product, l_variant)
            expect(page).to have_selector("a[href='#{delete_path}'][data-turbo-method='delete']")
          end
        end
      end
    end
  end
end