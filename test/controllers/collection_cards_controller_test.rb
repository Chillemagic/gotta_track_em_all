require "test_helper"

class CollectionCardsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @collection_card = collection_cards(:one)
  end

  test "should get index" do
    get collection_cards_url
    assert_response :success
  end

  test "should get new" do
    get new_collection_card_url
    assert_response :success
  end

  test "should create collection_card" do
    assert_difference("CollectionCard.count") do
      post collection_cards_url, params: { collection_card: { card_id: @collection_card.card_id, collection_id: @collection_card.collection_id } }
    end

    assert_redirected_to collection_card_url(CollectionCard.last)
  end

  test "should show collection_card" do
    get collection_card_url(@collection_card)
    assert_response :success
  end

  test "should get edit" do
    get edit_collection_card_url(@collection_card)
    assert_response :success
  end

  test "should update collection_card" do
    patch collection_card_url(@collection_card), params: { collection_card: { card_id: @collection_card.card_id, collection_id: @collection_card.collection_id } }
    assert_redirected_to collection_card_url(@collection_card)
  end

  test "should destroy collection_card" do
    assert_difference("CollectionCard.count", -1) do
      delete collection_card_url(@collection_card)
    end

    assert_redirected_to collection_cards_url
  end
end
