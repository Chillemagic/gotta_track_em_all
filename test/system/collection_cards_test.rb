require "application_system_test_case"

class CollectionCardsTest < ApplicationSystemTestCase
  setup do
    @collection_card = collection_cards(:one)
  end

  test "visiting the index" do
    visit collection_cards_url
    assert_selector "h1", text: "Collection cards"
  end

  test "should create collection card" do
    visit collection_cards_url
    click_on "New collection card"

    fill_in "Card", with: @collection_card.card_id
    fill_in "Collection", with: @collection_card.collection_id
    click_on "Create Collection card"

    assert_text "Collection card was successfully created"
    click_on "Back"
  end

  test "should update Collection card" do
    visit collection_card_url(@collection_card)
    click_on "Edit this collection card", match: :first

    fill_in "Card", with: @collection_card.card_id
    fill_in "Collection", with: @collection_card.collection_id
    click_on "Update Collection card"

    assert_text "Collection card was successfully updated"
    click_on "Back"
  end

  test "should destroy Collection card" do
    visit collection_card_url(@collection_card)
    click_on "Destroy this collection card", match: :first

    assert_text "Collection card was successfully destroyed"
  end
end
