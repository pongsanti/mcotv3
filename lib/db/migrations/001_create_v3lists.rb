Sequel.migration do
  change do
    create_table(:v3lists) do
      String    :filename
      String    :ocr
      String    :normalized
      TrueClass :posted, default: false
    end
  end
end
