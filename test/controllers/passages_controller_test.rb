require "test_helper"

class PassagesControllerTest < ActionDispatch::IntegrationTest
  test "show renders default reading view" do
    get root_path
    assert_response :success
  end

  test "show renders with corpus/scripture/division" do
    get reading_path(corpus_slug: "bible", scripture_slug: "genesis", division_number: 1)
    assert_response :success
    assert_select ".scripture-text"
  end

  test "show with translation param" do
    get reading_path(corpus_slug: "bible", scripture_slug: "genesis", division_number: 1, t: [ "KJV" ])
    assert_response :success
  end

  test "show with parallel mode" do
    get reading_path(corpus_slug: "bible", scripture_slug: "genesis", division_number: 1, parallel: "1", t: %w[KJV WLC])
    assert_response :success
  end

  test "show with diff mode" do
    get reading_path(corpus_slug: "bible", scripture_slug: "genesis", division_number: 1, diff: "1", t: %w[KJV WLC])
    assert_response :success
  end

  test "jump resolves valid reference" do
    get jump_path(ref: "Genesis 1:1")
    assert_redirected_to reading_path(corpus_slug: "bible", scripture_slug: "genesis", division_number: 1)
  end

  test "jump redirects back for invalid reference" do
    get jump_path(ref: "Nonexistent 99:99")
    assert_redirected_to root_path
  end

  test "prev/next navigation links present" do
    get reading_path(corpus_slug: "bible", scripture_slug: "genesis", division_number: 1)
    assert_response :success
    # Chapter 1 should have a next link to chapter 2
    assert_select "a[href*='genesis/2']"
  end

  test "standard view renders range translations once at the anchor" do
    summary, range = create_range_segment("Range summary covering verses 1 and 2.")

    get reading_path(corpus_slug: "bible", scripture_slug: "genesis", division_number: 1, t: [ "AISUM" ])
    assert_response :success
    # Range label appears (anchor)
    assert_match "v. 1–2 · range translation", @response.body
    # Continuation note appears for verse 2
    assert_match "↑ part of v. 1–2 above", @response.body
  ensure
    range&.destroy
    summary&.destroy
  end

  test "parallel view renders range translation once with continuation note" do
    summary, range = create_range_segment("Range summary.")

    get reading_path(corpus_slug: "bible", scripture_slug: "genesis", division_number: 1, parallel: "1", t: %w[AISUM WLC])
    assert_response :success
    assert_match "part of v. 1–2 above", @response.body
  ensure
    range&.destroy
    summary&.destroy
  end

  test "diff view falls back to side-by-side when either translation has a range segment" do
    summary, range = create_range_segment("Range summary.")

    get reading_path(corpus_slug: "bible", scripture_slug: "genesis", division_number: 1, diff: "1", t: %w[AISUM KJV])
    assert_response :success
    assert_match "Range translation — verse-level diff not available", @response.body
  ensure
    range&.destroy
    summary&.destroy
  end

  private

  def create_range_segment(text)
    summary = Translation.create!(
      abbreviation: "AISUM",
      name: "AI Summary",
      language: "English",
      edition_type: "critical",
      corpus: corpora(:bible)
    )

    segment = TranslationSegment.create!(
      translation: summary,
      scripture: scriptures(:genesis),
      start_passage: passages(:genesis_one_one),
      end_passage: passages(:genesis_one_two),
      start_position: 1,
      end_position: 2,
      text: text
    )

    [ summary, segment ]
  end
end
