RSpec.describe "Pagination Admin", type: :system do
  context "with 1 page of records" do
    scenario "contains a single link to page 1" do
      # Act
      visit admin_roles_path(Switch.current_account)

      # Assert
      within("ul.pagination") do
        first_page_link = admin_roles_path(Switch.current_account) + "?page[no]=1"
        expect(page).to have_selector("li.page-item.active a[href='#{first_page_link}']")
      end
    end

    scenario "inherits page size from visited url" do
      # Act
      visit admin_roles_path(Switch.current_account, page: { per: 5 })

      # Assert
      within("ul.pagination") do
        first_page_link = admin_roles_path(Switch.current_account) + "?page[per]=5&page[no]=1"
        expect(page).to have_selector("li.page-item.active a[href='#{first_page_link}']")
      end
    end
  end

  context "with 2 pages of records" do
    before(:each) do
      10.times { |i| Role.create(name: i.to_s) }
    end

    context "from first page" do
      scenario "contains link to self and next page" do
        # Act
        visit admin_roles_path(Switch.current_account)

        # Assert
        aggregate_failures do
          within("ul.pagination") do
            expect(all("li.page-item").count).to eq(3)
            base_page_link = admin_roles_path(Switch.current_account) + "?page[no]=%{page_no}"
            base_link_selector = "li.page-item%{extra_class} a[href='#{base_page_link}']"
            expect(page).to have_css(base_link_selector % { page_no: 1, extra_class: ".active" }, text: 1)
            expect(page).to have_css(base_link_selector % { page_no: 2, extra_class: "" }, text: 2)
            expect(page).to have_css(base_link_selector % { page_no: 2, extra_class: "#next" } + " svg")
          end
        end
      end
    end

    context "from second page" do
      scenario "contains link to self and previous page" do
        # Act
        visit admin_roles_path(Switch.current_account, page: { no: 2 })

        # Assert
        aggregate_failures do
          within("ul.pagination") do
            expect(all("li.page-item").count).to eq(3)
            base_page_link = admin_roles_path(Switch.current_account) + "?page[no]=%{page_no}"
            base_link_selector = "li.page-item%{extra_class} a[href='#{base_page_link}']"
            expect(page).to have_css(base_link_selector % { page_no: 1, extra_class: "#previous" } + " svg")
            expect(page).to have_css(base_link_selector % { page_no: 1, extra_class: "" }, text: 1)
            expect(page).to have_css(base_link_selector % { page_no: 2, extra_class: ".active" }, text: 2)
          end
        end
      end
    end
  end

  context "with 3 pages of records" do
    before(:each) do
      20.times { |i| Role.create(name: i.to_s) }
    end

    context "from first page" do
      scenario "contains numbered, next and last links" do
        # Act
        visit admin_roles_path(Switch.current_account)

        # Assert
        aggregate_failures do
          within("ul.pagination") do
            expect(all("li.page-item").count).to eq(5)
            base_page_link = admin_roles_path(Switch.current_account) + "?page[no]=%{page_no}"
            base_link_selector = "li.page-item%{extra_class} a[href='#{base_page_link}']"
            expect(page).to have_css(base_link_selector % { page_no: 1, extra_class: ".active" }, text: 1)
            expect(page).to have_css(base_link_selector % { page_no: 2, extra_class: "" }, text: 2)
            expect(page).to have_css(base_link_selector % { page_no: 3, extra_class: "" }, text: 3)
            expect(page).to have_css(base_link_selector % { page_no: 2, extra_class: "#next" } + " svg")
            expect(page).to have_css(base_link_selector % { page_no: 3, extra_class: "#last" } + " svg")
          end
        end
      end
    end

    context "from second page" do
      scenario "contains numbered, previous and next links" do
        # Act
        visit admin_roles_path(Switch.current_account, page: { no: 2 })

        # Assert
        aggregate_failures do
          within("ul.pagination") do
            expect(all("li.page-item").count).to eq(5)
            base_page_link = admin_roles_path(Switch.current_account) + "?page[no]=%{page_no}"
            base_link_selector = "li.page-item%{extra_class} a[href='#{base_page_link}']"
            expect(page).to have_css(base_link_selector % { page_no: 1, extra_class: "#previous" } + " svg")
            expect(page).to have_css(base_link_selector % { page_no: 1, extra_class: "" }, text: 1)
            expect(page).to have_css(base_link_selector % { page_no: 2, extra_class: ".active" }, text: 2)
            expect(page).to have_css(base_link_selector % { page_no: 3, extra_class: "" }, text: 3)
            expect(page).to have_css(base_link_selector % { page_no: 3, extra_class: "#next" } + " svg")
          end
        end
      end
    end

    context "from third page" do
      scenario "contains numbered, previous and first links" do
        # Act
        visit admin_roles_path(Switch.current_account, page: { no: 3 })

        # Assert
        aggregate_failures do
          within("ul.pagination") do
            expect(all("li.page-item").count).to eq(5)
            base_page_link = admin_roles_path(Switch.current_account) + "?page[no]=%{page_no}"
            base_link_selector = "li.page-item%{extra_class} a[href='#{base_page_link}']"
            expect(page).to have_css(base_link_selector % { page_no: 1, extra_class: "#first" } + " svg")
            expect(page).to have_css(base_link_selector % { page_no: 2, extra_class: "#previous" } + " svg")
            expect(page).to have_css(base_link_selector % { page_no: 1, extra_class: "" }, text: 1)
            expect(page).to have_css(base_link_selector % { page_no: 2, extra_class: "" }, text: 2)
            expect(page).to have_css(base_link_selector % { page_no: 3, extra_class: ".active" }, text: 3)
          end
        end
      end
    end
  end

  context "with 7 or more pages of records" do
    before(:each) do
      69.times { |i| Role.create(name: i.to_s) }
    end

    context "from first page" do
      scenario "contains numbered, buffer, next and last links" do
        # Act
        visit admin_roles_path(Switch.current_account)

        # Assert
        aggregate_failures do
          within("ul.pagination") do
            expect(all("li.page-item").count).to eq(6)
            base_page_link = admin_roles_path(Switch.current_account) + "?page[no]=%{page_no}"
            base_link_selector = "li.page-item%{extra_class} a[href='#{base_page_link}']"
            expect(page).to have_css(base_link_selector % { page_no: 1, extra_class: ".active" }, text: 1)
            expect(page).to have_css(base_link_selector % { page_no: 2, extra_class: "" }, text: 2)
            expect(page).to have_css(base_link_selector % { page_no: 3, extra_class: "" }, text: 3)
            expect(page).to have_css("li.page-item.disabled#many_higher a[href='#']", text: "...")
            expect(page).to have_css(base_link_selector % { page_no: 2, extra_class: "#next" } + " svg")
            expect(page).to have_css(base_link_selector % { page_no: 7, extra_class: "#last" } + " svg")
          end
        end
      end
    end

    context "from middle page" do
      scenario "contains numbered, buffer, previous, first, next and last links" do
        # Act
        visit admin_roles_path(Switch.current_account, page: { no: 4 })

        # Assert
        aggregate_failures do
          within("ul.pagination") do
            expect(all("li.page-item").count).to eq(11)
            base_page_link = admin_roles_path(Switch.current_account) + "?page[no]=%{page_no}"
            base_link_selector = "li.page-item%{extra_class} a[href='#{base_page_link}']"
            expect(page).to have_css(base_link_selector % { page_no: 1, extra_class: "#first" } + " svg")
            expect(page).to have_css(base_link_selector % { page_no: 3, extra_class: "#previous" } + " svg")
            expect(page).to have_css("li.page-item.disabled#many_lower a[href='#']", text: "...")
            expect(page).to have_css(base_link_selector % { page_no: 2, extra_class: "" }, text: 2)
            expect(page).to have_css(base_link_selector % { page_no: 3, extra_class: "" }, text: 3)
            expect(page).to have_css(base_link_selector % { page_no: 4, extra_class: ".active" }, text: 4)
            expect(page).to have_css(base_link_selector % { page_no: 5, extra_class: "" }, text: 5)
            expect(page).to have_css(base_link_selector % { page_no: 6, extra_class: "" }, text: 6)
            expect(page).to have_css("li.page-item.disabled#many_higher a[href='#']", text: "...")
            expect(page).to have_css(base_link_selector % { page_no: 5, extra_class: "#next" } + " svg")
            expect(page).to have_css(base_link_selector % { page_no: 7, extra_class: "#last" } + " svg")
          end
        end
      end
    end

    context "from last page" do
      scenario "contains numbered, buffer, previous and first links" do
        # Act
        visit admin_roles_path(Switch.current_account, page: { no: 7 })

        # Assert
        aggregate_failures do
          within("ul.pagination") do
            expect(all("li.page-item").count).to eq(6)
            base_page_link = admin_roles_path(Switch.current_account) + "?page[no]=%{page_no}"
            base_link_selector = "li.page-item%{extra_class} a[href='#{base_page_link}']"
            expect(page).to have_css(base_link_selector % { page_no: 1, extra_class: "#first" } + " svg")
            expect(page).to have_css(base_link_selector % { page_no: 6, extra_class: "#previous" } + " svg")
            expect(page).to have_css("li.page-item.disabled#many_lower a[href='#']", text: "...")
            expect(page).to have_css(base_link_selector % { page_no: 5, extra_class: "" }, text: 5)
            expect(page).to have_css(base_link_selector % { page_no: 6, extra_class: "" }, text: 6)
            expect(page).to have_css(base_link_selector % { page_no: 7, extra_class: ".active" }, text: 7)
          end
        end
      end
    end
  end

  context "exception handling" do
    scenario "defaults to page 1 when page is 0 or less" do
      # Act
      visit admin_roles_path(Switch.current_account, page: { no: 0 })

      # Assert
      aggregate_failures do
        # Should contain records
        within("tbody") do
          expect(page).to have_selector("tr")
        end
        # Should link to page 1 not page 0
        within("ul.pagination") do
          first_page_link = admin_roles_path(Switch.current_account) + "?page[no]=1"
          expect(page).to have_selector("li.page-item.active a[href='#{first_page_link}']")
        end
      end
    end

    scenario "defaults to page size 1 when per is 0 or less" do
      # Act
      visit admin_roles_path(Switch.current_account, page: { per: 0 })

      # Assert
      # Should contain record
      within("tbody") do
        expect(all("tr").count).to eq(1)
      end
    end

    scenario "links back to real pages when there are no records for page" do
      # Act
      visit admin_roles_path(Switch.current_account, page: { no: 100 })

      # Assert
      aggregate_failures do
        # Should not contain records
        within("tbody") do
          expect(page).not_to have_selector("tr")
        end
        # Should link to page 1 not page 0
        within("ul.pagination") do
          expect(all("li.page-item").count).to eq(3)
          base_page_link = admin_roles_path(Switch.current_account) + "?page[no]=%{page_no}"
          base_link_selector = "li.page-item%{extra_class} a[href='#{base_page_link}']"
          expect(page).to have_selector(base_link_selector % { page_no: 1, extra_class: "" })
          expect(page).to have_selector(base_link_selector % { page_no: 99, extra_class: "" })
          expect(page).to have_css("li.page-item.disabled#many_lower a[href='#']", text: "...")
        end
      end
    end
  end
end
