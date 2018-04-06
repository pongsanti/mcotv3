Sequel.migration do
  change do
    create_table(:v3_lists) do
      String    :filename
      String    :ocr
      String    :normalized
      TrueClass :posted, default: false
      TrueClass :valid, default: true
    end
  end
end
