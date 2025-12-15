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

  describe "#create" do
    scenario "can create a variant" do
      # Arrange
      product = Pim::Product.create(title: "Top", reference: "top")
      title = "Large"
      reference = "top_l"
      position = 1

      # Act
      visit new_admin_product_variant_path(Switch.current_account, product)

      within("form[action='#{admin_product_variants_path(Switch.current_account, product)}']") do
        find("input[name='pim_variant[title]']").fill_in(with: title)
        find("input[name='pim_variant[reference]']").fill_in(with: reference)
        find("label[for='pim_variant_visible']").click
        find("input[name='pim_variant[position]']").fill_in(with: position)

        find("input[type='submit']").click
      end

      # Assert
      aggregate_failures do
        expect(page).to have_content(title)
        created_variant = Pim::Variant.find_by(reference: reference)
        expect(created_variant.title).to eq(title)
        expect(created_variant.visible).to eq(true)
        expect(created_variant.position).to eq(position)
      end
    end
  end

  describe "#update" do
    scenario "can update a product" do
      # Arrange
      product = Pim::Product.create(title: "Top", reference: "top")
      variant = product.variants.create(title: "Lagre", reference: "top_l", visible: true, position: 0)

      new_title = "Large"
      new_position = 1

      # Act
      visit edit_admin_product_variant_path(Switch.current_account, product, variant)

      within("form[action='#{admin_product_variant_path(Switch.current_account, product, variant)}']") do
        find("input[name='pim_variant[title]']").fill_in(with: new_title)
        find("label[for='pim_variant_visible']").click
        find("input[name='pim_variant[position]']").fill_in(with: new_position)

        find("input[type='submit']").click
      end

      # Assert
      aggregate_failures do
        expect(page).to have_content(new_title)
        expect(variant.reload.title).to eq(new_title)
        expect(variant.visible).to eq(false)
        expect(variant.position).to eq(new_position)
      end
    end
  end
end