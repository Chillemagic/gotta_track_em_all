# Card Identification Refactor — Session Summary

## Goal

Improve card-image identification so that:

- OpenAI performs the initial, cheaper identification.
- A user can request a more accurate Scrydex Vision retry when the result is wrong.
- The original uploaded image remains available for retrying.
- Background-job progress and results update the page through Turbo.
- Existing catalogue cards are reused instead of creating unwanted duplicates.

## Current implementation

- `CardsController#search` creates a temporary `Card`, attaches the uploaded image, and enqueues `IdentifyCardJob`.
- `IdentifyCardJob` downloads the Active Storage attachment, converts it to a Base64 data URL, and sends it to OpenAI.
- OpenAI returns identifying fields such as name, number, set, rarity, language, and staff marking.
- The job searches for an existing `Card` by name, number, and holo type.
- If no match exists, the temporary card is populated and `FetchCardInfoJob` fetches catalogue information and pricing.
- If a match exists, the temporary card is marked `duplicate` and the existing card ID is stored in `error_message`.

## Problems identified

### One model has two responsibilities

`Card` currently represents both:

1. A user's image-search operation.
2. A canonical card in the shared catalogue.

This creates confusing duplicate handling, image ownership, cleanup, authorization, and UI behavior.

### Existing-card matches are not presented correctly

When OpenAI identifies an existing card:

- the temporary card is not deleted;
- the browser remains on the temporary card's URL;
- the matched card ID is stored in an error field;
- the broadcast renders the temporary card rather than the matched card;
- pricing updates occur on the canonical card while the page is subscribed to the temporary card.

Deleting the temporary card immediately would not solve this, because the browser would then point to a missing record.

### Turbo only updates part of the page

The page subscribes to `card_<id>`, but the model callback only replaces `_card_info`. The separate `_card_search_status` partial has no stable replacement target and is not broadcast. Initial `api_tcg_status` and `tcg_dex_status` values can also be `nil`, leaving the heading blank during OpenAI identification.

### Pricing changes do not update `Card`

Creating a `PriceHistory` does not trigger `Card#after_update_commit`, so price information needs its own broadcast or another deliberate refresh mechanism.

## Agreed design: `SearchAttempt`

Introduce a model dedicated to the user's search operation.

```text
SearchAttempt
├── belongs to User
├── optionally belongs to Card
├── owns the uploaded image
├── stores OpenAI/Scrydex identification output
├── tracks provider, status, and errors
└── broadcasts search progress and resolution

Card
├── represents canonical catalogue data
├── is shared by multiple search attempts
└── owns catalogue details and pricing history
```

Suggested fields:

```ruby
create_table :search_attempts do |t|
  t.references :user, null: false, foreign_key: true
  t.references :card, null: true, foreign_key: true

  t.string :status, null: false, default: "pending"
  t.string :provider, null: false, default: "openai"

  t.string :identified_name
  t.string :identified_number
  t.string :identified_set_name
  t.string :identified_rarity
  t.string :identified_language
  t.boolean :identified_staff

  t.text :error_message
  t.timestamps
end
```

Suggested initial statuses:

```ruby
enum :status, {
  pending: "pending",
  identifying: "identifying",
  matched: "matched",
  creating_card: "creating_card",
  failed: "failed"
}, prefix: true
```

The exact status list can later include Scrydex-specific retry states if useful.

## Intended workflow

```text
Upload image
    ↓
Create SearchAttempt and attach image
    ↓
Open /search_attempts/:id and subscribe through Turbo
    ↓
OpenAI identifies image and updates SearchAttempt
    ↓
Search canonical Cards
   ├── Match found → assign search_attempt.card and mark matched
   └── No match → create Card, assign it, fetch catalogue data, then mark matched
    ↓
Render search_attempt.card
```

The original upload stays on `SearchAttempt`, which makes a paid Scrydex retry natural and avoids attaching user photographs to shared catalogue records.

## Turbo UI approach

The search-result page should subscribe to the attempt:

```erb
<%= turbo_stream_from @search_attempt %>
<%= render "search_attempts/result", search_attempt: @search_attempt %>
```

The result partial needs a stable target:

```erb
<div id="<%= dom_id(search_attempt) %>">
  <% if search_attempt.status_pending? ||
        search_attempt.status_identifying? ||
        search_attempt.status_creating_card? %>
    <h1>Searching for your card…</h1>
  <% elsif search_attempt.status_failed? %>
    <h1>We couldn't identify that card</h1>
  <% elsif search_attempt.status_matched? %>
    <h1>Match found!</h1>
    <%= render "cards/card_info", card: search_attempt.card %>
    <%= link_to "View card", card_path(search_attempt.card) %>
  <% end %>
</div>
```

`SearchAttempt` should broadcast that partial after committed updates. Every success and failure path in a background job must persist a terminal status so that the page cannot remain stuck on “Searching.”

Once a canonical card is assigned, ongoing catalogue/pricing updates must either:

- navigate the user to the canonical card page and subscribe to that card; or
- ensure the result page also receives broadcasts caused by changes to its assigned card.

Navigating or linking to the canonical card page is the simpler first implementation.

## Image handling findings

- Active Storage is already used via `has_one_attached :image`.
- Cloudinary is configured as an Active Storage service.
- OpenAI accepts image input as a reachable URL or Base64 data URL.
- Base64 conversion inside the background job avoids public-URL and expiry problems:

```ruby
encoded = Base64.strict_encode64(attempt.image.download)
content_type = attempt.image.blob.content_type.presence || "image/jpeg"
image = "data:#{content_type};base64,#{encoded}"
```

- The controller and job argument counts must remain consistent. The current direction is to enqueue only the `SearchAttempt` ID.
- `image_processing` 1.14.0 is installed, Rails loads `ImageProcessing`, and the configured processor is `vips`. Long-running web and job processes must be restarted after dependency changes.

## Scrydex retry direction

After the initial result settles, show a user-triggered “Retry with Scrydex” action when:

- the attempt has an attached image;
- it is not currently processing;
- Scrydex has not already been requested or exhausted.

The endpoint should be authenticated, authorize ownership of the attempt, and prevent duplicate paid requests. A dedicated Scrydex job/service should update the same `SearchAttempt`, use the returned exact Scrydex card ID when available, assign/create the canonical `Card`, and broadcast the result.

Do not use pricing availability to determine retry-button visibility; pricing and identification are independent operations.

## Recommended implementation order

1. Generate `SearchAttempt`, its migration, associations, attachment, statuses, and validations.
2. Add `SearchAttemptsController` routes/actions for creation and result display.
3. Change the upload form to create a `SearchAttempt` instead of a temporary `Card`.
4. Refactor `IdentifyCardJob` to accept a search-attempt ID and persist identification output there.
5. Resolve an existing `Card` or create a new canonical card, then assign it to the attempt.
6. Add the Turbo result partial and committed update broadcasts.
7. Adapt `FetchCardInfoJob` completion/failure handling for attempts that are waiting on a newly created card.
8. Add tests for successful existing matches, new cards, failures, authorization, and Turbo broadcasts.
9. Implement the Scrydex retry endpoint, paid-call guard, job/service, and button.
10. Add retention/cleanup rules for old attempts and their uploaded images.

## Important tests

- Upload creates a `SearchAttempt`, not a disposable `Card`.
- Missing image fails without calling an API.
- OpenAI output is saved on the attempt.
- Existing card is assigned without creating another card.
- Unknown card creates exactly one canonical card.
- Job failures set `failed` and update the UI.
- Turbo replaces the expected result target.
- Users cannot retry another user's attempt.
- Repeated Scrydex clicks produce at most one paid call.
- A Scrydex result resolves to the correct canonical card.

## Session portability

The conversation was originally exported to `/home/chille/Downloads/codex-session-image_id.md`.

A Codex CLI JSONL session can likely be resumed on another machine by copying it to the equivalent `~/.codex/sessions/YYYY/MM/DD/` path and running:

```bash
codex resume -C /path/to/gotta_track_em_all <session-id>
```

This is an internal-file workaround rather than a documented migration guarantee. The Git repository, uncommitted work, dependencies, configuration, and environment variables must be transferred separately. Do not place API keys or other secrets in Git or handoff documents.
