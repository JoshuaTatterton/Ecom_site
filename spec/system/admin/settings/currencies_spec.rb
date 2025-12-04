RSpec.describe "Currencies Admin", type: :system do
  describe "#index" do
    scenario "viewing currencies" do
      # Arrange
      gbp = Currency.create({ default: true }.merge(CurrencyHelper::CURRENCIES["GBP"]))
      usd = Currency.create(CurrencyHelper::CURRENCIES["USD"])

      # Act
      visit admin_currencies_path(Switch.current_account)

      # Assert
      aggregate_failures do
        within("tbody#currencies") do
          within("tr:nth-child(1)") do
            expect(page).to have_content(usd.name)
            expect(page).to have_content(usd.iso)
            expect(page).to have_content(usd.code)
            expect(page).to have_content(usd.symbol)
            expect(page).not_to have_selector("svg.bi-check-circle")
          end
          within("tr:nth-child(2)") do
            expect(page).to have_content(gbp.name)
            expect(page).to have_content(gbp.iso)
            expect(page).to have_content(gbp.code)
            expect(page).to have_content(gbp.symbol)
            expect(page).to have_selector("svg.bi-check-circle")
          end
        end
      end
    end
  end

  # describe "#create" do
  #   scenario "can create a product" do
  #     # Arrange
  #     title = "Sweet"
  #     reference = "sweet"
  #     description = "This sweet product"

  #     # Act
  #     visit new_admin_product_path(Switch.current_account)

  #     within("form[action='#{admin_products_path(Switch.current_account)}']") do
  #       find("input[name='pim_product[title]']").fill_in(with: title)
  #       find("input[name='pim_product[reference]']").fill_in(with: reference)
  #       find("label[for='pim_product_visible']").click
  #       find("textarea[name='pim_product[description]']").fill_in(with: description)

  #       find("input[type='submit']").click
  #     end

  #     # Assert
  #     aggregate_failures do
  #       expect(page).to have_content("Sweet")
  #       created_product = Pim::Product.find_by(reference: reference)
  #       expect(created_product.title).to eq(title)
  #       expect(created_product.visible).to eq(true)
  #       expect(created_product.description).to eq(description)
  #     end
  #   end
  # end

  # describe "#update" do
  #   scenario "can update a product" do
  #     # Arrange
  #     product = Pim::Product.create(title: "Sweet", reference: "sweet", visible: true)

  #     # Act
  #     visit edit_admin_product_path(Switch.current_account, product.id)

  #     within("form[action='#{admin_product_path(Switch.current_account, product.id)}']") do
  #       find("input[name='pim_product[title]']").fill_in(with: "Sweeter")
  #       find("label[for='pim_product_visible']").click
  #       find("input[type='submit']").click
  #     end

  #     # Assert
  #     aggregate_failures do
  #       expect(page).to have_content("Sweeter")
  #       expect(product.reload.title).to eq("Sweeter")
  #       expect(product.visible).to eq(false)
  #     end
  #   end
  # end

  # describe "#destroy" do
  #   scenario "can destroy a product" do
  #     # Arrange
  #     product = Pim::Product.create(title: "Sweet", reference: "sweet")

  #     visit admin_products_path(Switch.current_account)

  #     # Act
  #     within("tr#product_#{product.id}") do
  #       find("a[href='#{admin_product_path(Switch.current_account, product.id)}']").click
  #     end

  #     # Assert
  #     aggregate_failures do
  #       expect(page).not_to have_content(product.title)
  #       expect(Pim::Product.find_by(id: product.id)).to eq(nil)
  #     end
  #   end
  # end
end
