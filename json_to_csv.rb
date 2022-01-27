require 'json'
require 'csv'

def convert_json_to_csv(json_filename, output_filename)
  #Відкриваємо файл
  file = open(json_filename)
  #Зчитумо Json
  items = JSON.parse(file.read)
  #Отримуємо назви полів
  column_names = items.first.keys
  #Записуємо в csv
  csv_result = CSV.generate do |csv|
    #Рядок з з назвами полів
    csv << column_names
    #Записуэмо кожен елемент масиву в csv
    items.each { |item| csv << item.values }
  end
  #Записуємо csv в файл
  File.write(output_filename, csv_result)
end
