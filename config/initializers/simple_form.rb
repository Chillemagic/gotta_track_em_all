# frozen_string_literal: true

SimpleForm.setup do |config|
  # Button class (already Tailwind)
  config.button_class = "relative inline-flex items-center rounded-md bg-sky-600 px-2.5 py-2 text-sm font-semibold text-white shadow-xs hover:bg-sky-500 focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-sky-600"

  # Boolean label class (tailwind switch)
  config.boolean_label_class = "ml-2 text-sm font-medium text-gray-700"

  config.label_text = lambda { |label, required, explicit_label| "#{label} #{required}" }
  config.boolean_style = :inline
  config.item_wrapper_tag = :div
  config.include_default_input_wrapper_class = false

  config.error_notification_class = "rounded bg-red-100 p-4 mb-4 text-red-700 text-sm"
  config.error_method = :to_sentence

  config.input_field_error_class = "ring-2 ring-red-500"
  config.input_field_valid_class = "ring-2 ring-green-500"

  # Vertical form (default)
  config.wrappers :vertical_form, class: "mb-4" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: "block text-sm font-medium text-gray-900 mb-1"
    b.use :input, class: "block w-full rounded-md border border-gray-300 bg-white px-2.5 py-2 text-base text-gray-900 placeholder-gray-400 shadow-sm focus:outline-none focus:ring-2 focus:ring-sky-600", error_class: "block w-full rounded-md border border-red-300 bg-white px-2.5 py-2 text-base text-red-900 placeholder-red-300 shadow-sm focus:outline-none focus:ring-2 focus:ring-red-600", valid_class: "ring-2 ring-green-500"
    b.use :full_error, wrap_with: { class: "mt-1 text-sm text-red-600" }
    b.use :hint, wrap_with: { class: "mt-2 text-sm text-gray-500" }
  end

  # Vertical boolean (checkbox/switch)
  config.wrappers :vertical_boolean, tag: "fieldset", class: "mb-4" do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :form_check_wrapper, class: "flex items-center" do |bb|
      bb.use :input, class: "h-4 w-4 text-sky-600 border-gray-300 rounded focus:ring-sky-600", error_class: "h-4 w-4 text-red-600 border-red-300 rounded focus:ring-red-600", valid_class: "ring-2 ring-green-500"
      bb.use :label, class: "ml-2 text-sm font-medium text-gray-700"
      bb.use :full_error, wrap_with: { class: "ml-6 text-sm text-red-600" }
      bb.use :hint, wrap_with: { class: "ml-6 text-sm text-gray-500" }
    end
  end

  # Vertical collection (radios/checkboxes)
  config.wrappers :vertical_collection, item_wrapper_class: "flex items-center mb-2", item_label_class: "ml-2 text-sm font-medium text-gray-700", tag: "fieldset", class: "mb-4" do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :legend_tag, tag: "legend", class: "block text-sm font-medium text-gray-900 mb-2" do |ba|
      ba.use :label_text
    end
    b.use :input, class: "h-4 w-4 text-sky-600 border-gray-300 rounded focus:ring-sky-600", error_class: "h-4 w-4 text-red-600 border-red-300 rounded focus:ring-red-600", valid_class: "ring-2 ring-green-500"
    b.use :full_error, wrap_with: { class: "mt-1 text-sm text-red-600" }
    b.use :hint, wrap_with: { class: "mt-2 text-sm text-gray-500" }
  end

  config.wrappers :vertical_collection_inline, item_wrapper_class: "inline-flex items-center mr-4", item_label_class: "ml-2 text-sm font-medium text-gray-700", tag: "fieldset", class: "mb-4" do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :legend_tag, tag: "legend", class: "block text-sm font-medium text-gray-900 mb-2" do |ba|
      ba.use :label_text
    end
    b.use :input, class: "h-4 w-4 text-sky-600 border-gray-300 rounded focus:ring-sky-600", error_class: "h-4 w-4 text-red-600 border-red-300 rounded focus:ring-red-600", valid_class: "ring-2 ring-green-500"
    b.use :full_error, wrap_with: { class: "mt-1 text-sm text-red-600" }
    b.use :hint, wrap_with: { class: "mt-2 text-sm text-gray-500" }
  end

  # File input
  config.wrappers :vertical_file, class: "mb-4" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :readonly
    b.use :label, class: "block text-sm font-medium text-gray-900 mb-1"
    b.use :input, class: "block w-full text-sm text-gray-700 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-sky-50 file:text-sky-700 hover:file:bg-sky-100", error_class: "block w-full text-sm text-red-700 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-red-50 file:text-red-700 hover:file:bg-red-100", valid_class: "ring-2 ring-green-500"
    b.use :full_error, wrap_with: { class: "mt-1 text-sm text-red-600" }
    b.use :hint, wrap_with: { class: "mt-2 text-sm text-gray-500" }
  end

  # Select input
  config.wrappers :vertical_select, class: "mb-4" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "block text-sm font-medium text-gray-900 mb-1"
    b.use :input, class: "block w-full rounded-md border border-gray-300 bg-white px-2.5 py-2 text-base text-gray-900 shadow-sm focus:outline-none focus:ring-2 focus:ring-sky-600", error_class: "block w-full rounded-md border border-red-300 bg-white px-2.5 py-2 text-base text-red-900 shadow-sm focus:outline-none focus:ring-2 focus:ring-red-600", valid_class: "ring-2 ring-green-500"
    b.use :full_error, wrap_with: { class: "mt-1 text-sm text-red-600" }
    b.use :hint, wrap_with: { class: "mt-2 text-sm text-gray-500" }
  end

  # Multi select
  config.wrappers :vertical_multi_select, class: "mb-4" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "block text-sm font-medium text-gray-900 mb-1"
    b.wrapper class: "flex flex-row justify-between items-center" do |ba|
      ba.use :input, class: "block w-full rounded-md border border-gray-300 bg-white px-2.5 py-2 text-base text-gray-900 shadow-sm focus:outline-none focus:ring-2 focus:ring-sky-600 mx-1", error_class: "block w-full rounded-md border border-red-300 bg-white px-2.5 py-2 text-base text-red-900 shadow-sm focus:outline-none focus:ring-2 focus:ring-red-600 mx-1", valid_class: "ring-2 ring-green-500"
    end
    b.use :full_error, wrap_with: { class: "mt-1 text-sm text-red-600" }
    b.use :hint, wrap_with: { class: "mt-2 text-sm text-gray-500" }
  end

  # Range input
  config.wrappers :vertical_range, class: "mb-4" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :readonly
    b.optional :step
    b.use :label, class: "block text-sm font-medium text-gray-900 mb-1"
    b.use :input, class: "w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer", error_class: "w-full h-2 bg-red-200 rounded-lg appearance-none cursor-pointer", valid_class: "ring-2 ring-green-500"
    b.use :full_error, wrap_with: { class: "mt-1 text-sm text-red-600" }
    b.use :hint, wrap_with: { class: "mt-2 text-sm text-gray-500" }
  end

  # --- HORIZONTAL (2-column) FORM WRAPPERS ---

  config.wrappers :horizontal_form, class: "grid grid-cols-1 sm:grid-cols-3 gap-4 mb-4 items-center" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: "text-sm font-medium text-gray-900"
    b.wrapper :grid_wrapper, class: "sm:col-span-2" do |ba|
      ba.use :input, class: "block w-full rounded-md border border-gray-300 bg-white px-2.5 py-2 text-base text-gray-900 shadow-sm focus:outline-none focus:ring-2 focus:ring-sky-600", error_class: "block w-full rounded-md border border-red-300 bg-white px-2.5 py-2 text-base text-red-900 shadow-sm focus:outline-none focus:ring-2 focus:ring-red-600", valid_class: "ring-2 ring-green-500"
      ba.use :full_error, wrap_with: { class: "mt-1 text-sm text-red-600" }
      ba.use :hint, wrap_with: { class: "mt-2 text-sm text-gray-500" }
    end
  end

  config.wrappers :horizontal_boolean, class: "grid grid-cols-1 sm:grid-cols-3 gap-4 mb-4 items-center" do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :grid_wrapper, class: "sm:col-span-2 sm:col-start-2" do |wr|
      wr.wrapper :form_check_wrapper, class: "flex items-center" do |bb|
        bb.use :input, class: "h-4 w-4 text-sky-600 border-gray-300 rounded focus:ring-sky-600", error_class: "h-4 w-4 text-red-600 border-red-300 rounded focus:ring-red-600", valid_class: "ring-2 ring-green-500"
        bb.use :label, class: "ml-2 text-sm font-medium text-gray-700"
        bb.use :full_error, wrap_with: { class: "ml-6 text-sm text-red-600" }
        bb.use :hint, wrap_with: { class: "ml-6 text-sm text-gray-500" }
      end
    end
  end

  config.wrappers :horizontal_collection, item_wrapper_class: "flex items-center mb-2", item_label_class: "ml-2 text-sm font-medium text-gray-700", class: "grid grid-cols-1 sm:grid-cols-3 gap-4 mb-4 items-center" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "text-sm font-medium text-gray-900"
    b.wrapper :grid_wrapper, class: "sm:col-span-2" do |ba|
      ba.use :input, class: "h-4 w-4 text-sky-600 border-gray-300 rounded focus:ring-sky-600", error_class: "h-4 w-4 text-red-600 border-red-300 rounded focus:ring-red-600", valid_class: "ring-2 ring-green-500"
      ba.use :full_error, wrap_with: { class: "mt-1 text-sm text-red-600" }
      ba.use :hint, wrap_with: { class: "mt-2 text-sm text-gray-500" }
    end
  end

  config.wrappers :horizontal_collection_inline, item_wrapper_class: "inline-flex items-center mr-4", item_label_class: "ml-2 text-sm font-medium text-gray-700", class: "grid grid-cols-1 sm:grid-cols-3 gap-4 mb-4 items-center" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "text-sm font-medium text-gray-900"
    b.wrapper :grid_wrapper, class: "sm:col-span-2" do |ba|
      ba.use :input, class: "h-4 w-4 text-sky-600 border-gray-300 rounded focus:ring-sky-600", error_class: "h-4 w-4 text-red-600 border-red-300 rounded focus:ring-red-600", valid_class: "ring-2 ring-green-500"
      ba.use :full_error, wrap_with: { class: "mt-1 text-sm text-red-600" }
      ba.use :hint, wrap_with: { class: "mt-2 text-sm text-gray-500" }
    end
  end

  config.wrappers :horizontal_file, class: "grid grid-cols-1 sm:grid-cols-3 gap-4 mb-4 items-center" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :readonly
    b.use :label, class: "text-sm font-medium text-gray-900"
    b.wrapper :grid_wrapper, class: "sm:col-span-2" do |ba|
      ba.use :input, class: "block w-full text-sm text-gray-700 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-sky-50 file:text-sky-700 hover:file:bg-sky-100", error_class: "block w-full text-sm text-red-700 file:mr-4 file:py-2 file:px-4 file:rounded-md file:border-0 file:text-sm file:font-semibold file:bg-red-50 file:text-red-700 hover:file:bg-red-100", valid_class: "ring-2 ring-green-500"
      ba.use :full_error, wrap_with: { class: "mt-1 text-sm text-red-600" }
      ba.use :hint, wrap_with: { class: "mt-2 text-sm text-gray-500" }
    end
  end

  config.wrappers :horizontal_select, class: "grid grid-cols-1 sm:grid-cols-3 gap-4 mb-4 items-center" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "text-sm font-medium text-gray-900"
    b.wrapper :grid_wrapper, class: "sm:col-span-2" do |ba|
      ba.use :input, class: "block w-full rounded-md border border-gray-300 bg-white px-2.5 py-2 text-base text-gray-900 shadow-sm focus:outline-none focus:ring-2 focus:ring-sky-600", error_class: "block w-full rounded-md border border-red-300 bg-white px-2.5 py-2 text-base text-red-900 shadow-sm focus:outline-none focus:ring-2 focus:ring-red-600", valid_class: "ring-2 ring-green-500"
      ba.use :full_error, wrap_with: { class: "mt-1 text-sm text-red-600" }
      ba.use :hint, wrap_with: { class: "mt-2 text-sm text-gray-500" }
    end
  end

  config.wrappers :horizontal_multi_select, class: "grid grid-cols-1 sm:grid-cols-3 gap-4 mb-4 items-center" do |b|
    b.use :html5
    b.optional :readonly
    b.use :label, class: "text-sm font-medium text-gray-900"
    b.wrapper :grid_wrapper, class: "sm:col-span-2" do |ba|
      ba.wrapper class: "flex flex-row justify-between items-center" do |bb|
        bb.use :input, class: "block w-full rounded-md border border-gray-300 bg-white px-2.5 py-2 text-base text-gray-900 shadow-sm focus:outline-none focus:ring-2 focus:ring-sky-600 mx-1", error_class: "block w-full rounded-md border border-red-300 bg-white px-2.5 py-2 text-base text-red-900 shadow-sm focus:outline-none focus:ring-2 focus:ring-red-600 mx-1", valid_class: "ring-2 ring-green-500"
      end
      ba.use :full_error, wrap_with: { class: "mt-1 text-sm text-red-600" }
      ba.use :hint, wrap_with: { class: "mt-2 text-sm text-gray-500" }
    end
  end

  config.wrappers :horizontal_range, class: "grid grid-cols-1 sm:grid-cols-3 gap-4 mb-4 items-center" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :readonly
    b.optional :step
    b.use :label, class: "text-sm font-medium text-gray-900"
    b.wrapper :grid_wrapper, class: "sm:col-span-2" do |ba|
      ba.use :input, class: "w-full h-2 bg-gray-200 rounded-lg appearance-none cursor-pointer", error_class: "w-full h-2 bg-red-200 rounded-lg appearance-none cursor-pointer", valid_class: "ring-2 ring-green-500"
      ba.use :full_error, wrap_with: { class: "mt-1 text-sm text-red-600" }
      ba.use :hint, wrap_with: { class: "mt-2 text-sm text-gray-500" }
    end
  end

  # Inline forms
  config.wrappers :inline_form, class: "w-full" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: "sr-only"
    b.use :input, class: "block w-full rounded-md border border-gray-300 bg-white px-2.5 py-2 text-base text-gray-900 shadow-sm focus:outline-none focus:ring-2 focus:ring-sky-600", error_class: "block w-full rounded-md border border-red-300 bg-white px-2.5 py-2 text-base text-red-900 shadow-sm focus:outline-none focus:ring-2 focus:ring-red-600", valid_class: "ring-2 ring-green-500"
    b.use :error, wrap_with: { class: "mt-1 text-sm text-red-600" }
    b.optional :hint, wrap_with: { class: "mt-2 text-sm text-gray-500" }
  end

  config.wrappers :inline_boolean, class: "w-full" do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :form_check_wrapper, class: "flex items-center" do |bb|
      bb.use :input, class: "h-4 w-4 text-sky-600 border-gray-300 rounded focus:ring-sky-600", error_class: "h-4 w-4 text-red-600 border-red-300 rounded focus:ring-red-600", valid_class: "ring-2 ring-green-500"
      bb.use :label, class: "ml-2 text-sm font-medium text-gray-700"
      bb.use :error, wrap_with: { class: "ml-6 text-sm text-red-600" }
      bb.optional :hint, wrap_with: { class: "ml-6 text-sm text-gray-500" }
    end
  end

  # Custom Boolean Switch
  config.wrappers :custom_boolean_switch, class: "mb-4" do |b|
    b.use :html5
    b.optional :readonly
    b.wrapper :form_check_wrapper, tag: "div", class: "flex items-center" do |bb|
      bb.use :input, class: "h-4 w-8 rounded-full bg-gray-200 checked:bg-sky-600 focus:ring-sky-600 transition duration-200 align-middle", error_class: "h-4 w-8 rounded-full bg-red-200 checked:bg-red-600 focus:ring-red-600 transition duration-200 align-middle", valid_class: "ring-2 ring-green-500"
      bb.use :label, class: "ml-2 text-sm font-medium text-gray-700"
      bb.use :full_error, wrap_with: { tag: "div", class: "ml-6 text-sm text-red-600" }
      bb.use :hint, wrap_with: { class: "ml-6 text-sm text-gray-500" }
    end
  end

  # Input Group (prepend/append)
  config.wrappers :input_group, class: "mb-4" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :label, class: "block text-sm font-medium text-gray-900 mb-1"
    b.wrapper :input_group_tag, class: "flex" do |ba|
      ba.optional :prepend
      ba.use :input, class: "block w-full rounded-md border border-gray-300 bg-white px-2.5 py-2 text-base text-gray-900 shadow-sm focus:outline-none focus:ring-2 focus:ring-sky-600", error_class: "block w-full rounded-md border border-red-300 bg-white px-2.5 py-2 text-base text-red-900 shadow-sm focus:outline-none focus:ring-2 focus:ring-red-600", valid_class: "ring-2 ring-green-500"
      ba.optional :append
      ba.use :full_error, wrap_with: { class: "mt-1 text-sm text-red-600" }
    end
    b.use :hint, wrap_with: { class: "mt-2 text-sm text-gray-500" }
  end

  # Floating Labels (Tailwind only supports this visually via custom classes or plugins, so just use defaults)
  config.wrappers :floating_labels_form, class: "relative mb-4" do |b|
    b.use :html5
    b.use :placeholder
    b.optional :maxlength
    b.optional :minlength
    b.optional :pattern
    b.optional :min_max
    b.optional :readonly
    b.use :input, class: "block w-full rounded-md border border-gray-300 bg-white px-2.5 pt-6 pb-2 text-base text-gray-900 placeholder-transparent shadow-sm focus:outline-none focus:ring-2 focus:ring-sky-600 peer"
    b.use :label, class: "absolute left-3 top-2 z-10 origin-[0] -translate-y-2 scale-75 transform px-1 text-gray-500 duration-300 peer-placeholder-shown:translate-y-2 peer-placeholder-shown:scale-100 peer-focus:-translate-y-2 peer-focus:scale-75"
    b.use :full_error, wrap_with: { class: "mt-1 text-sm text-red-600" }
    b.use :hint, wrap_with: { class: "mt-2 text-sm text-gray-500" }
  end

  config.wrappers :floating_labels_select, class: "relative mb-4" do |b|
    b.use :html5
    b.optional :readonly
    b.use :input, class: "block w-full rounded-md border border-gray-300 bg-white px-2.5 pt-6 pb-2 text-base text-gray-900 placeholder-transparent shadow-sm focus:outline-none focus:ring-2 focus:ring-sky-600 peer"
    b.use :label, class: "absolute left-3 top-2 z-10 origin-[0] -translate-y-2 scale-75 transform px-1 text-gray-500 duration-300 peer-placeholder-shown:translate-y-2 peer-placeholder-shown:scale-100 peer-focus:-translate-y-2 peer-focus:scale-75"
    b.use :full_error, wrap_with: { class: "mt-1 text-sm text-red-600" }
    b.use :hint, wrap_with: { class: "mt-2 text-sm text-gray-500" }
  end

  config.default_wrapper = :vertical_form

  config.wrapper_mappings = {
    boolean:       :vertical_boolean,
    check_boxes:   :vertical_collection,
    date:          :vertical_multi_select,
    datetime:      :vertical_multi_select,
    file:          :vertical_file,
    radio_buttons: :vertical_collection,
    range:         :vertical_range,
    time:          :vertical_multi_select,
    select:        :vertical_select
  }
end
